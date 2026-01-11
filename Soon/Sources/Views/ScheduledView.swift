import SwiftUI

struct ScheduledView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // Status badge
            if sessionManager.state.isCountdown {
                Label("Starting soon!", systemImage: "clock.arrow.circlepath")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.2))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            } else {
                Label("Locked in", systemImage: "lock.fill")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }

            // Countdown timer
            VStack(spacing: 4) {
                Text(formatTime(sessionManager.timeUntilStart))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(sessionManager.state.isCountdown ? .orange : .primary)

                if let session = sessionManager.currentSession {
                    Text("Starts at \(formatStartTime(session.scheduledStart))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            // Task
            if let session = sessionManager.currentSession {
                VStack(spacing: 4) {
                    Text("Working on:")
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                    Text(session.task)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            Spacer()

            // Guilt-free message
            Text(sessionManager.guiltFreeMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .animation(.easeInOut, value: sessionManager.guiltFreeMessage)

            Spacer()

            // Cancel button
            Button {
                sessionManager.cancelSession()
            } label: {
                Text("Cancel")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.bottom)
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = max(0, Int(interval))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func formatStartTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ScheduledView()
        .environmentObject({
            let manager = SessionManager(modelContainer: try! ModelContainer(for: FocusSession.self))
            return manager
        }())
        .frame(width: 320, height: 400)
}
