import Foundation

enum AppConstants {
    static let appName = "PuffFree"
    static let appVersion = "1.0.0"
    static let appGroupIdentifier = "group.com.pufffree.app"
    static let widgetKind = "PuffFreeWidget"

    enum UserDefaults {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let quitDateKey = "quitDate"
        static let dailyCheckInReminderHour = "dailyCheckInReminderHour"
    }

    enum Motivations: CaseIterable {
        case health
        case money
        case family
        case fitness
        case appearance
        case freedom
        case smell
        case energy

        var title: String {
            switch self {
            case .health: return "Better Health"
            case .money: return "Save Money"
            case .family: return "For My Family"
            case .fitness: return "Improve Fitness"
            case .appearance: return "Look Better"
            case .freedom: return "Break Free"
            case .smell: return "Smell Better"
            case .energy: return "More Energy"
            }
        }

        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .money: return "dollarsign.circle.fill"
            case .family: return "figure.2.and.child.holdinghands"
            case .fitness: return "figure.run"
            case .appearance: return "sparkles"
            case .freedom: return "bird.fill"
            case .smell: return "nose"
            case .energy: return "bolt.fill"
            }
        }
    }

    enum MotivationalQuotes {
        static let quotes: [(quote: String, author: String)] = [
            ("The secret of getting ahead is getting started.", "Mark Twain"),
            ("It does not matter how slowly you go as long as you do not stop.", "Confucius"),
            ("Every moment is a fresh beginning.", "T.S. Eliot"),
            ("You are stronger than your cravings.", "PuffFree"),
            ("The best time to quit was yesterday. The next best time is now.", "PuffFree"),
            ("Your lungs are thanking you right now.", "PuffFree"),
            ("One craving at a time. One victory at a time.", "PuffFree"),
            ("Freedom tastes better than any puff ever did.", "PuffFree"),
            ("Your body is a miracle of healing. Let it work.", "PuffFree"),
            ("The chains of habit are too light to be felt until they are too heavy to be broken.", "Warren Buffett"),
            ("Quitting is not giving up. It is choosing to stop something that is no longer serving you.", "PuffFree"),
            ("Breathe deep. You earned these lungs.", "PuffFree")
        ]

        static var random: (quote: String, author: String) {
            quotes.randomElement() ?? quotes[0]
        }

        static func forDay(_ day: Int) -> (quote: String, author: String) {
            quotes[day % quotes.count]
        }
    }
}
