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

    /// Daily support nudges at common high-risk craving windows (the post-waking
    /// surge and the mid-afternoon slump), personalized with the user's reason for
    /// quitting. This is the contextual, "we're with you when it's hard" loop that
    /// keeps the app present during vulnerable moments — not just a fixed reminder.
    func scheduleCravingSupportNotifications(motivation: String) {
        let reason = motivation.trimmingCharacters(in: .whitespaces).isEmpty
            ? "your health"
            : motivation.lowercased()

        let nudges: [(id: String, hour: Int, title: String, body: String)] = [
            ("craving-support-morning", 9,
             "You've got this",
             "Mornings are when cravings hit hardest. Take three slow breaths — you quit for \(reason)."),
            ("craving-support-afternoon", 15,
             "Beat the afternoon dip",
             "The mid-afternoon slump is a classic trigger. A glass of water and a 2-minute walk will pass the urge.")
        ]

        for n in nudges {
            let content = UNMutableNotificationContent()
            content.title = n.title
            content.body = n.body
            content.sound = .default
            content.categoryIdentifier = "craving-support"

            var dateComponents = DateComponents()
            dateComponents.hour = n.hour

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: n.id, content: content, trigger: trigger)
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
