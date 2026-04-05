import Foundation
import UserNotifications

final class NotificationManager: @unchecked Sendable {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleMilestoneNotification(title: String, body: String, afterHours: Int) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "milestone"

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(afterHours * 3600),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "milestone-\(afterHours)h",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleDailyCheckInReminder(hour: Int = 20, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today? Take a moment to reflect on your progress."
        content.sound = .default
        content.categoryIdentifier = "checkin"

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily-checkin",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleMotivationalNotifications() {
        let messages = [
            ("Stay Strong!", "Every craving you resist makes you stronger. You've got this!"),
            ("Proud of You", "Remember why you started this journey. Your future self thanks you."),
            ("Health Win", "Your body is healing more every hour. Keep going!"),
            ("Money Saved", "Think about what you can do with all the money you're saving."),
            ("Breathe Easy", "Your lungs are getting healthier with every passing moment.")
        ]

        for (index, message) in messages.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = message.0
            content.body = message.1
            content.sound = .default

            var dateComponents = DateComponents()
            dateComponents.hour = [9, 12, 15, 18, 10][index]
            dateComponents.weekday = index + 1

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: true
            )

            let request = UNNotificationRequest(
                identifier: "motivation-\(index)",
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request)
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func scheduleAllMilestoneNotifications(quitDate: Date) {
        let hoursSinceQuit = Calendar.current.dateComponents(
            [.hour], from: quitDate, to: Date()
        ).hour ?? 0

        for milestone in MilestoneType.allCases {
            let hoursUntil = milestone.hoursRequired - hoursSinceQuit
            if hoursUntil > 0 {
                scheduleMilestoneNotification(
                    title: "Milestone Unlocked!",
                    body: milestone.celebrationMessage,
                    afterHours: hoursUntil
                )
            }
        }
    }
}
