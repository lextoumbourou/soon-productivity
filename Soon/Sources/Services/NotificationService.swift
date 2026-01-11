import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }

    func scheduleSessionStart(session: FocusSession) {
        // Warning notification (2 minutes before)
        if session.timeUntilStart > 120 {
            let warningContent = UNMutableNotificationContent()
            warningContent.title = "2 minutes until focus"
            warningContent.body = "Get ready: \(session.task)"
            warningContent.sound = .default

            let warningTime = session.scheduledStart.addingTimeInterval(-120)
            let warningTrigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: warningTime),
                repeats: false
            )

            let warningRequest = UNNotificationRequest(
                identifier: "\(session.id.uuidString)-warning",
                content: warningContent,
                trigger: warningTrigger
            )

            UNUserNotificationCenter.current().add(warningRequest)
        }

        // Start notification
        let startContent = UNMutableNotificationContent()
        startContent.title = "Go time!"
        startContent.body = session.task
        startContent.sound = UNNotificationSound.defaultCritical

        let startTrigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: session.scheduledStart),
            repeats: false
        )

        let startRequest = UNNotificationRequest(
            identifier: "\(session.id.uuidString)-start",
            content: startContent,
            trigger: startTrigger
        )

        UNUserNotificationCenter.current().add(startRequest)
    }

    func scheduleSessionEnd(session: FocusSession) {
        let content = UNMutableNotificationContent()
        content.title = "Focus session complete!"
        content.body = "How did it go? \(session.task)"
        content.sound = .default
        content.categoryIdentifier = "SESSION_COMPLETE"

        guard let actualStart = session.actualStart else { return }

        let endTime = actualStart.addingTimeInterval(TimeInterval(session.durationMinutes * 60))
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: endTime),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "\(session.id.uuidString)-end",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func showCompletionNotification(session: FocusSession) {
        let content = UNMutableNotificationContent()
        content.title = "Session logged"
        content.body = "\(session.reflection?.emoji ?? "✓") \(session.task)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "\(session.id.uuidString)-logged",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotifications(for sessionId: UUID) {
        let identifiers = [
            "\(sessionId.uuidString)-warning",
            "\(sessionId.uuidString)-start",
            "\(sessionId.uuidString)-end"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}
