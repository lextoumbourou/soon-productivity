import Foundation

enum SessionState: Equatable {
    case idle
    case scheduled(session: UUID)
    case countdown(session: UUID)  // Last 30 seconds before start
    case active(session: UUID)
    case reflection(session: UUID)

    var isIdle: Bool {
        if case .idle = self { return true }
        return false
    }

    var isScheduled: Bool {
        if case .scheduled = self { return true }
        return false
    }

    var isCountdown: Bool {
        if case .countdown = self { return true }
        return false
    }

    var isActive: Bool {
        if case .active = self { return true }
        return false
    }

    var isReflection: Bool {
        if case .reflection = self { return true }
        return false
    }

    var sessionId: UUID? {
        switch self {
        case .idle:
            return nil
        case .scheduled(let session),
             .countdown(let session),
             .active(let session),
             .reflection(let session):
            return session
        }
    }
}
