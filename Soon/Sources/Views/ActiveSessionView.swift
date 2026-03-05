import SwiftUI
import SwiftData

struct ActiveSessionView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showEndConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Active indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(.orange)
                    .frame(width: 8, height: 8)
                    .modifier(PulseAnimation())

                Text("Focus mode")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.1))
            .clipShape(Capsule())

            // Time remaining
            VStack(spacing: 4) {
                Text(formatTime(sessionManager.timeRemaining))
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.orange)

                Text("remaining")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Progress ring
            if let session = sessionManager.currentSession {
                let progress = 1 - (sessionManager.timeRemaining / Double(session.durationMinutes * 60))

                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.2), lineWidth: 6)

                    Circle()
                        .trim(from: 0, to: min(max(progress, 0), 1))
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                }
                .frame(width: 60, height: 60)
            }

            // Task list
            if let session = sessionManager.currentSession {
                VStack(spacing: 8) {
                    ForEach(session.tasks) { task in
                        TaskCheckRow(
                            task: task,
                            isCurrent: session.currentTask?.id == task.id
                        ) {
                            sessionManager.toggleTask(task.id)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()

            // End early button (with friction)
            Button {
                showEndConfirmation = true
            } label: {
                Text("End early")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.bottom)
            .confirmationDialog(
                "End session early?",
                isPresented: $showEndConfirmation,
                titleVisibility: .visible
            ) {
                Button("End and reflect", role: .destructive) {
                    sessionManager.endSession()
                }
                Button("Keep going", role: .cancel) {}
            } message: {
                Text("You still have \(formatTime(sessionManager.timeRemaining)) left. Are you sure?")
            }
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct TaskCheckRow: View {
    let task: TaskItem
    let isCurrent: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? .green : (isCurrent ? .orange : .secondary))
                    .font(.system(size: 18))

                Text(task.title)
                    .font(.subheadline)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : (isCurrent ? .primary : .primary))

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isCurrent && !task.isCompleted ? Color.orange.opacity(0.1) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.2 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

#Preview {
    ActiveSessionView()
        .environmentObject({
            let manager = SessionManager(modelContainer: try! ModelContainer(for: FocusSession.self))
            return manager
        }())
        .frame(width: 320, height: 400)
}
