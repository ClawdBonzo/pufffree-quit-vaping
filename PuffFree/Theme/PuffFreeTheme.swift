import SwiftUI

enum PuffFreeTheme {

    // MARK: - Phoenix Brand Colors
    static let emberOrange  = Color(hex: "E85D04")
    static let emberRed     = Color(hex: "C0392B")
    static let smokeTeal    = Color(hex: "0D9B6B")
    static let phoenixGold  = Color(hex: "FFD700")
    static let ashGray      = Color(hex: "6B7280")

    // Legacy aliases
    static let accentTeal   = smokeTeal
    static let accentMint   = Color(hex: "34D399")

    // MARK: - Primary Gradient (Ember → Teal Smoke → Phoenix Gold)
    static let primaryGradient = LinearGradient(
        colors: [emberOrange, smokeTeal, phoenixGold],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Specialized Gradients
    static let emberGradient = LinearGradient(
        colors: [Color(hex: "C0392B"), Color(hex: "E85D04"), Color(hex: "F97316")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let smokeGradient = LinearGradient(
        colors: [Color(hex: "0D9B6B"), Color(hex: "06B6D4")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let goldGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "FFD700"), Color(hex: "FFF9C4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let phoenixGradient = LinearGradient(
        colors: [Color(hex: "E85D04"), Color(hex: "0D9B6B"), Color(hex: "FFD700")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let flameGradient = LinearGradient(
        colors: [Color(hex: "FFD700"), Color(hex: "F97316"), Color(hex: "E85D04"), Color(hex: "C0392B")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Background Colors (deep volcanic dark)
    static let backgroundPrimary   = Color(hex: "080A0F")
    static let backgroundSecondary = Color(hex: "0E1118")
    static let backgroundCard      = Color(hex: "141C28")
    static let backgroundElevated  = Color(hex: "1C2635")

    // MARK: - Text Colors
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary  = Color.white.opacity(0.4)

    // MARK: - Semantic Colors
    static let success = Color(hex: "34D399")
    static let warning = Color(hex: "FBBF24")
    static let danger  = Color(hex: "F87171")
    static let info    = Color(hex: "60A5FA")

    // MARK: - Gradient Presets
    static let cardGradient = LinearGradient(
        colors: [backgroundCard, backgroundCard.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let celebrationGradient = LinearGradient(
        colors: [Color(hex: "E85D04"), Color(hex: "FFD700"), Color(hex: "0D9B6B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let healthGradient = LinearGradient(
        colors: [Color(hex: "10B981"), Color(hex: "06B6D4")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let savingsGradient = LinearGradient(
        colors: [Color(hex: "F59E0B"), Color(hex: "FFD700")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Milestone Colors
    static let milestoneGreen  = Color(hex: "34D399")
    static let milestoneTeal   = Color(hex: "0D9B6B")
    static let milestoneBlue   = Color(hex: "60A5FA")
    static let milestonePurple = Color(hex: "A78BFA")
    static let milestoneGold   = Color(hex: "FFD700")

    // MARK: - Mood Colors
    static let moodGreat      = Color(hex: "34D399")
    static let moodGood       = Color(hex: "60A5FA")
    static let moodNeutral    = Color(hex: "FBBF24")
    static let moodStruggling = Color(hex: "FB923C")
    static let moodTerrible   = Color(hex: "F87171")
}

// MARK: - Glass Card Style

struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.15
    var borderColor: Color = .white
    var glowColor: Color = .clear

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [borderColor.opacity(0.25), borderColor.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: glowColor.opacity(0.25), radius: 14, y: 4)
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 0.15) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }

    func emberGlassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            opacity: 0.12,
            borderColor: PuffFreeTheme.emberOrange,
            glowColor: PuffFreeTheme.emberOrange
        ))
    }

    func goldGlassCard(cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassCardModifier(
            cornerRadius: cornerRadius,
            opacity: 0.12,
            borderColor: PuffFreeTheme.phoenixGold,
            glowColor: PuffFreeTheme.phoenixGold
        ))
    }
}
