import SwiftUI
import SwiftData

struct HistoryView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var sessions: [FocusSession] = []

    var body: some View {
        VStack(spacing: 0) {
            // Stats header
            statsHeader
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Session list
            if sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(sessions, id: \.id) { session in
                            SessionRow(session: session)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            loadSessions()
        }
    }

    private var statsHeader: some View {
        HStack(spacing: 24) {
            StatItem(
                value: "\(sessionsThisWeek)",
                label: "This week"
            )

            Divider()
                .frame(height: 32)

            StatItem(
                value: "\(Int(completionRate * 100))%",
                label: "Completion"
            )

            Divider()
                .frame(height: 32)

            StatItem(
                value: "\(totalMinutesThisWeek)",
                label: "Minutes"
            )
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()

            Image(systemName: "clock")
                .font(.system(size: 36))
                .foregroundStyle(.tertiary)

            Text("No sessions yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Schedule your first focus session to get started")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
    }

    private var sessionsThisWeek: Int {
        sessionManager.sessionsThisWeek().count
    }

    private var completionRate: Double {
        sessionManager.completionRate()
    }

    private var totalMinutesThisWeek: Int {
        sessionManager.sessionsThisWeek()
            .filter { $0.status == .completed }
            .reduce(0) { $0 + $1.durationMinutes }
    }

    private func loadSessions() {
        sessions = sessionManager.fetchSessionHistory()
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.orange)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct SessionRow: View {
    let session: FocusSession

    var body: some View {
        HStack(spacing: 12) {
            // Reflection emoji
            Text(session.reflection?.emoji ?? "•")
                .font(.title3)

            // Session details
            VStack(alignment: .leading, spacing: 2) {
                Text(session.task)
                    .font(.subheadline)
                    .lineLimit(1)

                Text(formatDate(session.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            // Duration
            Text("\(session.durationMinutes)m")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    HistoryView()
        .environmentObject(SessionManager(modelContainer: try! ModelContainer(for: FocusSession.self)))
        .frame(width: 320, height: 400)
}
