import Foundation
import SwiftData

// Individual task item within a focus session
struct TaskItem: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool

    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
    }
}

@Model
final class FocusSession {
    var id: UUID
    var taskData: Data?  // Encoded [TaskItem] array
    var delayMinutes: Int
    var durationMinutes: Int
    var scheduledStart: Date
    var actualStart: Date?
    var endTime: Date?
    var status: SessionStatus
    var reflection: Reflection?
    var createdAt: Date

    // Computed: decode tasks from taskData
    var tasks: [TaskItem] {
        get {
            guard let data = taskData else { return [] }
            return (try? JSONDecoder().decode([TaskItem].self, from: data)) ?? []
        }
        set {
            taskData = try? JSONEncoder().encode(newValue)
        }
    }

    // Backward compat: first task title
    var task: String {
        tasks.first?.title ?? ""
    }

    // Current uncompleted task
    var currentTask: TaskItem? {
        tasks.first { !$0.isCompleted }
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }

    var totalCount: Int {
        tasks.count
    }

    init(
        tasks taskTitles: [String],
        delayMinutes: Int,
        durationMinutes: Int
    ) {
        self.id = UUID()
        self.delayMinutes = delayMinutes
        self.durationMinutes = durationMinutes
        self.scheduledStart = Date().addingTimeInterval(TimeInterval(delayMinutes * 60))
        self.status = .scheduled
        self.createdAt = Date()

        // Convert strings to TaskItems
        let items = taskTitles.map { TaskItem(title: $0) }
        self.taskData = try? JSONEncoder().encode(items)
    }

    // Convenience init for single task (backward compat)
    convenience init(
        task: String,
        delayMinutes: Int,
        durationMinutes: Int
    ) {
        self.init(tasks: [task], delayMinutes: delayMinutes, durationMinutes: durationMinutes)
    }

    func toggleTask(_ taskId: UUID) {
        var currentTasks = tasks
        if let index = currentTasks.firstIndex(where: { $0.id == taskId }) {
            currentTasks[index].isCompleted.toggle()
            tasks = currentTasks
        }
    }

    var scheduledEnd: Date {
        scheduledStart.addingTimeInterval(TimeInterval(durationMinutes * 60))
    }

    var isStarted: Bool {
        actualStart != nil
    }

    var timeUntilStart: TimeInterval {
        scheduledStart.timeIntervalSinceNow
    }

    var timeRemaining: TimeInterval {
        guard let actualStart = actualStart else {
            return TimeInterval(durationMinutes * 60)
        }
        let expectedEnd = actualStart.addingTimeInterval(TimeInterval(durationMinutes * 60))
        return expectedEnd.timeIntervalSinceNow
    }

    func start() {
        actualStart = Date()
        status = .active
    }

    func complete(with reflection: Reflection) {
        endTime = Date()
        self.reflection = reflection
        status = .completed
    }

    func skip() {
        endTime = Date()
        status = .skipped
        reflection = .skipped
    }
}

enum SessionStatus: String, Codable {
    case scheduled
    case active
    case completed
    case skipped
}

enum Reflection: String, Codable {
    case madeProgress
    case startedLate
    case skipped

    var emoji: String {
        switch self {
        case .madeProgress: return "✅"
        case .startedLate: return "⚠️"
        case .skipped: return "❌"
        }
    }

    var label: String {
        switch self {
        case .madeProgress: return "Made progress"
        case .startedLate: return "Started late"
        case .skipped: return "Skipped"
        }
    }
}
