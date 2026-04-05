import SwiftUI

enum PuffFreeTheme {
    // MARK: - Primary Colors
    static let primaryGradient = LinearGradient(
        colors: [Color("AccentTeal"), Color("AccentMint")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentTeal = Color("AccentTeal")
    static let accentMint = Color("AccentMint")

    // MARK: - Background Colors
    static let backgroundPrimary = Color(hex: "0A0E1A")
    static let backgroundSecondary = Color(hex: "121829")
    static let backgroundCard = Color(hex: "1A2038")
    static let backgroundElevated = Color(hex: "222845")

    // MARK: - Text Colors
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary = Color.white.opacity(0.4)

    // MARK: - Semantic Colors
    static let success = Color(hex: "34D399")
    static let warning = Color(hex: "FBBF24")
    static let danger = Color(hex: "F87171")
    static let info = Color(hex: "60A5FA")

    // MARK: - Gradient Presets
    static let cardGradient = LinearGradient(
        colors: [backgroundCard, backgroundCard.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let celebrationGradient = LinearGradient(
        colors: [
            Color(hex: "F59E0B"),
            Color(hex: "EF4444"),
            Color(hex: "8B5CF6"),
            Color(hex: "06B6D4")
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let healthGradient = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let savingsGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "F97316")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Milestone Colors
    static let milestoneGreen = Color(hex: "34D399")
    static let milestoneTeal = Color(hex: "2DD4BF")
    static let milestoneBlue = Color(hex: "60A5FA")
    static let milestonePurple = Color(hex: "A78BFA")
    static let milestoneGold = Color(hex: "FBBF24")

    // MARK: - Mood Colors
    static let moodGreat = Color(hex: "34D399")
    static let moodGood = Color(hex: "60A5FA")
    static let moodNeutral = Color(hex: "FBBF24")
    static let moodStruggling = Color(hex: "FB923C")
    static let moodTerrible = Color(hex: "F87171")
}

// MARK: - Glass Card Style
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.15

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 0.15) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }
}
