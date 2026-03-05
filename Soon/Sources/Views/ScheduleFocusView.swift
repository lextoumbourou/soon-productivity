import SwiftUI
import SwiftData

struct ScheduleFocusView: View {
    @EnvironmentObject var sessionManager: SessionManager

    @State private var tasks: [String] = [""]
    @State private var selectedDelay: Int = 10
    @State private var selectedDuration: Int = 25
    @FocusState private var focusedTaskIndex: Int?

    private let delayOptions = [0, 5, 10, 20]
    private let durationOptions = [10, 25, 50]

    private var validTasks: [String] {
        tasks.map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 20) {
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
                    .padding(.top, 20)

                    // Task list input
                    VStack(spacing: 8) {
                        ForEach(tasks.indices, id: \.self) { index in
                            HStack(spacing: 8) {
                                Image(systemName: "circle")
                                    .foregroundStyle(.tertiary)
                                    .font(.system(size: 14))

                                TextField("Task \(index + 1)", text: $tasks[index])
                                    .textFieldStyle(.plain)
                                    .focused($focusedTaskIndex, equals: index)
                                    .onSubmit {
                                        if !tasks[index].trimmingCharacters(in: .whitespaces).isEmpty {
                                            addTask()
                                            focusedTaskIndex = tasks.count - 1
                                        }
                                    }

                                if tasks.count > 1 {
                                    Button {
                                        removeTask(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.tertiary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(8)
                        }

                        // Add task button
                        Button {
                            addTask()
                            focusedTaskIndex = tasks.count - 1
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add task")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 4)
                    }
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
                }
            }

            // Lock it in button - fixed at bottom
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
            .disabled(validTasks.isEmpty)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }

    private func addTask() {
        tasks.append("")
    }

    private func removeTask(at index: Int) {
        tasks.remove(at: index)
        if tasks.isEmpty {
            tasks = [""]
        }
    }

    private func scheduleSession() {
        guard !validTasks.isEmpty else { return }

        sessionManager.scheduleSession(
            tasks: validTasks,
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
