import SwiftUI
import SwiftData

struct ReflectionView: View {
    @EnvironmentObject var sessionManager: SessionManager

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Completion icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            // Message
            VStack(spacing: 8) {
                Text("Session complete!")
                    .font(.title2)
                    .fontWeight(.bold)

                if let session = sessionManager.currentSession {
                    Text(session.task)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            // Question
            Text("How did it go?")
                .font(.headline)
                .padding(.top)

            // Reflection options
            VStack(spacing: 12) {
                ReflectionButton(
                    reflection: .madeProgress,
                    action: { complete(with: .madeProgress) }
                )

                ReflectionButton(
                    reflection: .startedLate,
                    action: { complete(with: .startedLate) }
                )

                ReflectionButton(
                    reflection: .skipped,
                    action: { complete(with: .skipped) }
                )
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private func complete(with reflection: Reflection) {
        sessionManager.completeSession(with: reflection)
    }
}

struct ReflectionButton: View {
    let reflection: Reflection
    let action: () -> Void

    private var color: Color {
        switch reflection {
        case .madeProgress: return .green
        case .startedLate: return .orange
        case .skipped: return .red
        }
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(reflection.emoji)
                    .font(.title2)

                Text(reflection.label)
                    .font(.body)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.1))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ReflectionView()
        .environmentObject({
            let manager = SessionManager(modelContainer: try! ModelContainer(for: FocusSession.self))
            return manager
        }())
        .frame(width: 320, height: 400)
}
