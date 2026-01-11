import SwiftUI

struct ScheduleFocusView: View {
    @EnvironmentObject var sessionManager: SessionManager

    @State private var task: String = ""
    @State private var selectedDelay: Int = 10
    @State private var selectedDuration: Int = 25

    private let delayOptions = [5, 10, 20]
    private let durationOptions = [10, 25, 50]

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Main prompt
            VStack(spacing: 8) {
                Text("In")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                // Delay picker
                HStack(spacing: 12) {
                    ForEach(delayOptions, id: \.self) { delay in
                        DelayButton(
                            minutes: delay,
                            isSelected: selectedDelay == delay
                        ) {
                            selectedDelay = delay
                        }
                    }
                }

                Text("I will work on:")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Task input
            TextField("What's the task?", text: $task)
                .textFieldStyle(.roundedBorder)
                .font(.title3)
                .padding(.horizontal)

            // Duration
            VStack(spacing: 8) {
                Text("For")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(durationOptions, id: \.self) { duration in
                        DurationButton(
                            minutes: duration,
                            isSelected: selectedDuration == duration
                        ) {
                            selectedDuration = duration
                        }
                    }
                }
            }

            Spacer()

            // Lock it in button
            Button {
                scheduleSession()
            } label: {
                HStack {
                    Image(systemName: "lock.fill")
                    Text("Lock it in")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(task.trimmingCharacters(in: .whitespaces).isEmpty)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func scheduleSession() {
        let trimmedTask = task.trimmingCharacters(in: .whitespaces)
        guard !trimmedTask.isEmpty else { return }

        sessionManager.scheduleSession(
            task: trimmedTask,
            delayMinutes: selectedDelay,
            durationMinutes: selectedDuration
        )

        // Close popover
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closePopover()
        }
    }
}

struct DelayButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes)")
                .font(.system(size: 28, weight: .bold))
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .fill(isSelected ? Color.orange : Color(nsColor: .controlBackgroundColor))
                }
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .overlay {
            Text("min")
                .font(.caption2)
                .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                .offset(y: 20)
        }
    }
}

struct DurationButton: View {
    let minutes: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(minutes) min")
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.orange.opacity(0.2) : Color(nsColor: .controlBackgroundColor))
                }
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ScheduleFocusView()
        .environmentObject(SessionManager(modelContainer: try! ModelContainer(for: FocusSession.self)))
        .frame(width: 320, height: 400)
}
