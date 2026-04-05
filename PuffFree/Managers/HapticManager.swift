import UIKit

enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    static func celebration() {
        Task {
            impact(.heavy)
            try? await Task.sleep(for: .milliseconds(100))
            notification(.success)
            try? await Task.sleep(for: .milliseconds(100))
            impact(.light)
        }
    }
}
