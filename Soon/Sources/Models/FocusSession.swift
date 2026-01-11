import Foundation
import SwiftData

@Model
final class FocusSession {
    var id: UUID
    var task: String
    var delayMinutes: Int
    var durationMinutes: Int
    var scheduledStart: Date
    var actualStart: Date?
    var endTime: Date?
    var status: SessionStatus
    var reflection: Reflection?
    var createdAt: Date

    init(
        task: String,
        delayMinutes: Int,
        durationMinutes: Int
    ) {
        self.id = UUID()
        self.task = task
        self.delayMinutes = delayMinutes
        self.durationMinutes = durationMinutes
        self.scheduledStart = Date().addingTimeInterval(TimeInterval(delayMinutes * 60))
        self.status = .scheduled
        self.createdAt = Date()
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
