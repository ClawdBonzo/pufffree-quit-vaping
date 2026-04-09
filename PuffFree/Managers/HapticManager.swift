import UIKit

/// All haptic feedback is dispatched on the main actor — UIKit generators require the main thread.
@MainActor
enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// Plays a layered haptic sequence: heavy → success → light.
    /// Runs on MainActor so UIKit calls stay on the main thread.
    static func celebration() {
        Task { @MainActor in
            impact(.heavy)
            try? await Task.sleep(for: .milliseconds(100))
            notification(.success)
            try? await Task.sleep(for: .milliseconds(100))
            impact(.light)
        }
    }
}
