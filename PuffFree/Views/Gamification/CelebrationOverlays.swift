import SwiftUI

// MARK: - Level Up Celebration

struct LevelUpCelebrationView: View {
    let newLevel: PlayerLevel
    let onDismiss: () -> Void

    @State private var scale: CGFloat    = 0.4
    @State private var opacity: Double   = 0
    @State private var glowPulse         = false
    @State private var burstVisible      = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            // Dim backdrop
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Particle background
            PhoenixParticleField(intensity: 1.4)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 24) {
                // Ember burst + level icon
                ZStack {
                    if burstVisible { EmberBurstView(particleCount: 16) }

                    // Glow rings
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [PuffFreeTheme.phoenixGold.opacity(0.35), .clear],
                                center: .center, startRadius: 0, endRadius: 75
                            )
                        )
                        .frame(width: 150, height: 150)
                        .scaleEffect(glowPulse ? 1.25 : 1.0)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: glowPulse)

                    Circle()
                        .fill(PuffFreeTheme.emberOrange.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .scaleEffect(glowPulse ? 1.2 : 0.9)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.15), value: glowPulse)

                    Image(systemName: newLevel.icon)
                        .font(.system(size: 52))
                        .foregroundStyle(PuffFreeTheme.goldGradient)
                        .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.8), radius: 16)
                }
                .frame(height: 150)

                // Text
                VStack(spacing: 10) {
                    Text("LEVEL UP!")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(PuffFreeTheme.phoenixGradient)
                        .shadow(color: PuffFreeTheme.emberOrange.opacity(0.6), radius: 10)

                    Text("You reached \(newLevel.title)")
                        .font(.headline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                // Action Button
                Button { dismiss() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.callout)
                        Text("Ignite!")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(PuffFreeTheme.emberGradient)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: PuffFreeTheme.emberOrange.opacity(0.5), radius: 12, y: 4)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "0E1118").opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [PuffFreeTheme.phoenixGold.opacity(0.5), PuffFreeTheme.emberOrange.opacity(0.2)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .shadow(color: PuffFreeTheme.emberOrange.opacity(0.3), radius: 30, y: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(maxWidth: 320)
            // Accessibility
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Level up! You reached \(newLevel.title).")
            .accessibilityAddTraits(.isModal)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                scale = 1; opacity = 1
            }
            if !reduceMotion { glowPulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { burstVisible = true }
            HapticManager.celebration()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { dismiss() }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) { opacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onDismiss() }
    }
}

// MARK: - Badge Unlock Celebration

struct BadgeUnlockCelebrationView: View {
    let badge: Badge
    let onDismiss: () -> Void

    @State private var scale: CGFloat  = 0.4
    @State private var opacity: Double = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0
    @State private var burstVisible    = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            PhoenixParticleField(intensity: 1.0)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 22) {
                // Badge with flame rings
                ZStack {
                    if burstVisible { EmberBurstView(particleCount: 14) }

                    // Outer pulse ring — gold
                    Circle()
                        .stroke(PuffFreeTheme.phoenixGold.opacity(0.3), lineWidth: 2)
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: ringScale)

                    // Mid fill — ember
                    Circle()
                        .fill(PuffFreeTheme.emberOrange.opacity(0.12))
                        .frame(width: 110, height: 110)

                    // Inner circle
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    PuffFreeTheme.phoenixGold.opacity(0.3),
                                    Color(hex: "1C1000").opacity(0.9)
                                ],
                                center: .center, startRadius: 0, endRadius: 55
                            )
                        )
                        .frame(width: 90, height: 90)

                    Image(systemName: badge.icon)
                        .font(.system(size: 44))
                        .foregroundStyle(PuffFreeTheme.goldGradient)
                        .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.8), radius: 14)
                }
                .frame(height: 160)

                // Text
                VStack(spacing: 8) {
                    Text("BADGE UNLOCKED!")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(PuffFreeTheme.goldGradient)

                    Text(badge.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(badge.badgeDescription)
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                Button { dismiss() } label: {
                    Text("Claim It!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(PuffFreeTheme.goldGradient)
                        .foregroundColor(Color(hex: "1A0A00"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.5), radius: 12, y: 4)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(hex: "0E1118").opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(PuffFreeTheme.phoenixGold.opacity(0.3), lineWidth: 1.5)
                    )
            )
            .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.25), radius: 30, y: 8)
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(maxWidth: 320)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Badge unlocked: \(badge.title). \(badge.badgeDescription)")
            .accessibilityAddTraits(.isModal)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.65)) {
                scale = 1; opacity = 1
            }
            if !reduceMotion {
                withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                    ringScale = 1.15; ringOpacity = 1
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { burstVisible = true }
            HapticManager.notification(.warning)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { dismiss() }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.25)) { opacity = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { onDismiss() }
    }
}

// MARK: - Streak Milestone Celebration (Phoenix Rising)

struct StreakMilestoneCelebrationView: View {
    let streakDays: Int
    let onDismiss: () -> Void

    @State private var scale: CGFloat    = 0.3
    @State private var opacity: Double   = 0
    @State private var flamePulse        = false
    @State private var ring1Scale: CGFloat = 1.0
    @State private var ring2Scale: CGFloat = 1.0
    @State private var ring3Scale: CGFloat = 1.0
    @State private var burstVisible      = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var milestoneLabel: String {
        switch streakDays {
        case 1:   return "First Day Free!"
        case 3:   return "3-Day Warrior!"
        case 7:   return "7-Day Champion!"
        case 14:  return "Two Weeks Strong!"
        case 30:  return "30-Day Phoenix!"
        case 60:  return "Two Month Legend!"
        case 100: return "Century Club!"
        case 180: return "Half-Year Hero!"
        case 365: return "One Year LEGEND!"
        default:  return "\(streakDays)-Day Streak!"
        }
    }

    var subtitleText: String {
        streakDays >= 30 ? "You have risen from the ashes." :
        streakDays >= 7  ? "The phoenix in you burns bright." :
                           "Keep that flame alive."
    }

    var body: some View {
        ZStack {
            // Full-screen dramatic backdrop
            Color(hex: "060308").opacity(0.92)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // High-intensity particle field
            PhoenixParticleField(intensity: 2.0)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Radial ember glow from center
            RadialGradient(
                colors: [PuffFreeTheme.emberOrange.opacity(0.25), .clear],
                center: .center, startRadius: 0, endRadius: 250
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 28) {
                // Phoenix flame centerpiece
                ZStack {
                    if burstVisible { EmberBurstView(particleCount: 20) }

                    // Three expanding pulse rings
                    Circle()
                        .stroke(PuffFreeTheme.phoenixGold.opacity(0.12), lineWidth: 1.5)
                        .frame(width: 200, height: 200)
                        .scaleEffect(ring3Scale)
                        .animation(reduceMotion ? nil : .easeOut(duration: 2.0).repeatForever(autoreverses: false), value: ring3Scale)

                    Circle()
                        .stroke(PuffFreeTheme.emberOrange.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 160, height: 160)
                        .scaleEffect(ring2Scale)
                        .animation(reduceMotion ? nil : .easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(0.5), value: ring2Scale)

                    Circle()
                        .stroke(PuffFreeTheme.phoenixGold.opacity(0.35), lineWidth: 2)
                        .frame(width: 120, height: 120)
                        .scaleEffect(ring1Scale)
                        .animation(reduceMotion ? nil : .easeOut(duration: 2.0).repeatForever(autoreverses: false).delay(1.0), value: ring1Scale)

                    // Inner glow fill
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    PuffFreeTheme.emberOrange.opacity(0.4),
                                    Color.clear
                                ],
                                center: .center, startRadius: 0, endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(flamePulse ? 1.15 : 1.0)
                        .animation(reduceMotion ? nil : .easeInOut(duration: 0.85).repeatForever(autoreverses: true), value: flamePulse)

                    // Flame stack
                    ZStack {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 68, weight: .bold))
                            .foregroundStyle(PuffFreeTheme.flameGradient)
                            .blur(radius: 6)
                            .opacity(0.6)

                        Image(systemName: "flame.fill")
                            .font(.system(size: 68, weight: .bold))
                            .foregroundStyle(PuffFreeTheme.flameGradient)
                            .shadow(color: PuffFreeTheme.emberOrange, radius: 20)
                    }
                    .scaleEffect(flamePulse ? 1.08 : 0.96)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.75).repeatForever(autoreverses: true), value: flamePulse)
                }
                .frame(width: 220, height: 220)

                // Streak number + label
                VStack(spacing: 6) {
                    Text("\(streakDays)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(PuffFreeTheme.goldGradient)
                        .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.6), radius: 12)

                    Text("Days Smoke-Free")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textTertiary)
                        .textCase(.uppercase)
                        .tracking(2)
                }

                // Milestone title + subtitle
                VStack(spacing: 6) {
                    Text(milestoneLabel)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(PuffFreeTheme.phoenixGradient)
                        .multilineTextAlignment(.center)

                    Text(subtitleText)
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // CTA
                Button { dismiss() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                        Text("Rise Higher!")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PuffFreeTheme.goldGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.6), radius: 16, y: 4)
                }
            }
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
            // Accessibility
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Streak milestone: \(milestoneLabel) \(streakDays) days smoke-free.")
            .accessibilityAddTraits(.isModal)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                scale = 1; opacity = 1
            }
            if !reduceMotion {
                flamePulse = true
                withAnimation { ring1Scale = 1.5; ring2Scale = 1.5; ring3Scale = 1.6 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { burstVisible = true }
            HapticManager.celebration()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { dismiss() }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) { opacity = 0; scale = 0.9 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
    }
}

// MARK: - Quest Completion Toast

struct QuestCompletionToastView: View {
    let quest: Quest
    let xpGained: Int
    let onDismiss: () -> Void

    @State private var offset: CGFloat  = 120
    @State private var opacity: Double  = 0
    @State private var shimmerPos: CGFloat = -0.4
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(PuffFreeTheme.emberOrange.opacity(0.18))
                        .frame(width: 40, height: 40)
                    Image(systemName: quest.type.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(PuffFreeTheme.flameGradient)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quest Complete!")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textTertiary)
                    Text(quest.type.rawValue)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("XP")
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.textTertiary)
                    Text("+\(xpGained)")
                        .font(.headline)
                        .fontWeight(.black)
                        .foregroundStyle(PuffFreeTheme.goldGradient)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "141C28"))
                    // Shimmer sweep
                    RoundedRectangle(cornerRadius: 18)
                        .fill(
                            LinearGradient(
                                colors: [.clear, PuffFreeTheme.phoenixGold.opacity(0.08), .clear],
                                startPoint: UnitPoint(x: shimmerPos - 0.25, y: 0),
                                endPoint: UnitPoint(x: shimmerPos + 0.25, y: 1)
                            )
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [PuffFreeTheme.emberOrange.opacity(0.4), PuffFreeTheme.phoenixGold.opacity(0.15)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: PuffFreeTheme.emberOrange.opacity(0.2), radius: 12, y: 4)
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
            .offset(y: offset)
            .opacity(opacity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Quest complete: \(quest.type.rawValue). Plus \(xpGained) experience points.")
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0; opacity = 1
            }
            if !reduceMotion {
                withAnimation(.linear(duration: 1.2).delay(0.2)) {
                    shimmerPos = 1.4
                }
            }
            HapticManager.selection()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 0.3)) { offset = 100; opacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
            }
        }
    }
}

#Preview {
    StreakMilestoneCelebrationView(streakDays: 30) {}
        .preferredColorScheme(.dark)
}
