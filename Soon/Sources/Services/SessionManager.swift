import Foundation
import SwiftData
import Combine
import AppKit

@MainActor
class SessionManager: ObservableObject {
    @Published var state: SessionState = .idle
    @Published var currentSession: FocusSession?
    @Published var timeUntilStart: TimeInterval = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var guiltFreeMessage: String = ""

    private var modelContainer: ModelContainer
    private var timer: Timer?
    private var countdownThreshold: TimeInterval = 30 // seconds before start to show countdown
    
    // Callbacks for updating menu bar
    var onUpdateMenuBarIcon: ((SessionState) -> Void)?
    var onUpdateMenuBarTitle: ((String) -> Void)?

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        checkForActiveSession()
    }

    var modelContext: ModelContext {
        modelContainer.mainContext
    }

    // MARK: - Session Lifecycle

    func scheduleSession(task: String, delayMinutes: Int, durationMinutes: Int) {
        scheduleSession(tasks: [task], delayMinutes: delayMinutes, durationMinutes: durationMinutes)
    }

    func scheduleSession(tasks: [String], delayMinutes: Int, durationMinutes: Int) {
        let session = FocusSession(
            tasks: tasks,
            delayMinutes: delayMinutes,
            durationMinutes: durationMinutes
        )

        modelContext.insert(session)
        try? modelContext.save()

        currentSession = session
        state = .scheduled(session: session.id)
        timeUntilStart = session.timeUntilStart

        // Schedule notifications
        NotificationService.shared.scheduleSessionStart(session: session)

        // Start timer
        startTimer()

        updateMenuBarIcon()
        updateMenuBarTitle(timeUntilStart)
    }

    func cancelSession() {
        guard let session = currentSession else { return }

        NotificationService.shared.cancelNotifications(for: session.id)
        modelContext.delete(session)
        try? modelContext.save()

        reset()
    }

    func startSession() {
        guard let session = currentSession else { return }

        session.start()
        try? modelContext.save()

        state = .active(session: session.id)
        timeRemaining = session.timeRemaining

        // Show start overlay with first task
        OverlayWindowController.shared.showStartOverlay(task: session.currentTask?.title ?? session.task)

        updateMenuBarIcon()
        updateMenuBarTitle(timeRemaining)
    }

    func endSession() {
        guard let session = currentSession else { return }

        state = .reflection(session: session.id)
        stopTimer()
        updateMenuBarIcon()
        onUpdateMenuBarTitle?("")
    }

    func completeSession(with reflection: Reflection) {
        guard let session = currentSession else { return }

        session.complete(with: reflection)
        try? modelContext.save()

        NotificationService.shared.showCompletionNotification(session: session)

        reset()
    }

    func skipSession() {
        guard let session = currentSession else { return }

        session.skip()
        try? modelContext.save()

        reset()
    }

    // MARK: - Timer Management

    private func startTimer() {
        stopTimer()

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let session = currentSession else { return }

        switch state {
        case .scheduled, .countdown:
            timeUntilStart = session.timeUntilStart
            updateGuiltFreeMessage()
            updateMenuBarTitle(timeUntilStart)

            if timeUntilStart <= 0 {
                // Time to start!
                startSession()
            } else if timeUntilStart <= countdownThreshold && state.isScheduled {
                // Enter countdown mode
                state = .countdown(session: session.id)
                updateMenuBarIcon()
            }

        case .active:
            timeRemaining = session.timeRemaining
            updateMenuBarTitle(timeRemaining)

            if timeRemaining <= 0 {
                endSession()
            }

        default:
            break
        }
    }

    private func updateGuiltFreeMessage() {
        let minutes = Int(timeUntilStart) / 60
        let seconds = Int(timeUntilStart) % 60

        if timeUntilStart > 60 {
            guiltFreeMessage = "You've got \(minutes):\(String(format: "%02d", seconds)) to chill."
        } else if timeUntilStart > 0 {
            guiltFreeMessage = "\(Int(timeUntilStart)) seconds of freedom left..."
        } else {
            guiltFreeMessage = "Go time!"
        }
    }

    // MARK: - State Recovery

    private func checkForActiveSession() {
        let scheduled = SessionStatus.scheduled
        let active = SessionStatus.active
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.status == scheduled || $0.status == active },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        guard let sessions = try? modelContext.fetch(descriptor),
              let session = sessions.first else {
            return
        }

        currentSession = session

        if session.status == .active {
            state = .active(session: session.id)
            timeRemaining = session.timeRemaining
            startTimer()
        } else if session.status == .scheduled {
            if session.timeUntilStart <= 0 {
                // Should have started already
                startSession()
            } else {
                state = .scheduled(session: session.id)
                timeUntilStart = session.timeUntilStart
                startTimer()
            }
        }

        updateMenuBarIcon()
    }

    private func reset() {
        stopTimer()
        currentSession = nil
        state = .idle
        timeUntilStart = 0
        timeRemaining = 0
        guiltFreeMessage = ""
        updateMenuBarIcon()
        onUpdateMenuBarTitle?("")
    }

    private func updateMenuBarIcon() {
        onUpdateMenuBarIcon?(state)
    }

    private func updateMenuBarTitle(_ interval: TimeInterval) {
        let totalSeconds = max(0, Int(interval))
        let formatted = String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)

        guard let session = currentSession else {
            onUpdateMenuBarTitle?(formatted)
            return
        }

        let total = session.totalCount
        let completed = session.completedCount

        if total > 1 {
            // Multiple tasks: show current task + progress
            if let current = session.currentTask {
                let truncated = current.title.count > 15 ? String(current.title.prefix(12)) + "..." : current.title
                onUpdateMenuBarTitle?("\(formatted) · \(truncated) (\(completed)/\(total))")
            } else {
                // All done
                onUpdateMenuBarTitle?("\(formatted) · Done! (\(total)/\(total))")
            }
        } else if let task = session.currentTask {
            // Single task: original behavior
            let truncated = task.title.count > 20 ? String(task.title.prefix(17)) + "..." : task.title
            onUpdateMenuBarTitle?("\(formatted) · \(truncated)")
        } else {
            onUpdateMenuBarTitle?(formatted)
        }
    }

    // MARK: - Task Management

    func toggleTask(_ taskId: UUID) {
        guard let session = currentSession else { return }
        session.toggleTask(taskId)
        try? modelContext.save()
        objectWillChange.send()

        // Update menu bar to reflect new current task
        if state.isActive {
            updateMenuBarTitle(timeRemaining)
        }
    }

    // MARK: - History

    func fetchSessionHistory() -> [FocusSession] {
        let completed = SessionStatus.completed
        let skipped = SessionStatus.skipped
        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { $0.status == completed || $0.status == skipped },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func sessionsThisWeek() -> [FocusSession] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let completed = SessionStatus.completed
        let skipped = SessionStatus.skipped

        let descriptor = FetchDescriptor<FocusSession>(
            predicate: #Predicate { session in
                session.createdAt >= startOfWeek &&
                (session.status == completed || session.status == skipped)
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func completionRate() -> Double {
        let sessions = sessionsThisWeek()
        guard !sessions.isEmpty else { return 0 }

        let completed = sessions.filter { $0.status == .completed }.count
        return Double(completed) / Double(sessions.count)
    }
}
