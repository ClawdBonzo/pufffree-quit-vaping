import SwiftUI

// MARK: - Level Up Celebration

struct LevelUpCelebrationView: View {
    let newLevel: PlayerLevel
    @State private var isVisible = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                // Confetti-like elements
                ZStack {
                    ForEach(0..<8, id: \.self) { index in
                        Image(systemName: "star.fill")
                            .font(.system(size: 20))
                            .foregroundColor(PuffFreeTheme.accentTeal)
                            .offset(
                                x: CGFloat(cos(Double(index) * .pi / 4) * 80),
                                y: CGFloat(sin(Double(index) * .pi / 4) * 80) - 60
                            )
                            .opacity(isVisible ? 0 : 1)
                    }
                }

                // Level Icon
                Image(systemName: newLevel.icon)
                    .font(.system(size: 64))
                    .foregroundColor(Color(hex: newLevel.color))

                // Text
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)

                    Text("You reached \(newLevel.title)")
                        .font(.headline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                // Action Button
                Button {
                    withAnimation {
                        onDismiss()
                    }
                } label: {
                    Text("Celebrate!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color(hex: newLevel.color))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(32)
            .background(PuffFreeTheme.backgroundCard)
            .cornerRadius(16)
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(maxWidth: 300)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }

            HapticManager.notification(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Badge Unlock Celebration

struct BadgeUnlockCelebrationView: View {
    let badge: Badge
    @State private var isVisible = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                // Badge Icon with glow
                ZStack {
                    Circle()
                        .fill(PuffFreeTheme.accentTeal.opacity(0.2))
                        .frame(width: 140, height: 140)

                    Image(systemName: badge.icon)
                        .font(.system(size: 60))
                        .foregroundColor(PuffFreeTheme.accentTeal)
                }

                // Text
                VStack(spacing: 8) {
                    Text("BADGE UNLOCKED!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(badge.title)
                        .font(.headline)
                        .foregroundColor(PuffFreeTheme.textSecondary)

                    Text(badge.badgeDescription)
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }

                // Action Button
                Button {
                    withAnimation {
                        onDismiss()
                    }
                } label: {
                    Text("View Badges")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(PuffFreeTheme.accentTeal)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(32)
            .background(PuffFreeTheme.backgroundCard)
            .cornerRadius(16)
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(maxWidth: 300)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }

            HapticManager.notification(.warning)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Streak Milestone Celebration

struct StreakMilestoneCelebrationView: View {
    let streakDays: Int
    @State private var isVisible = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    let onDismiss: () -> Void

    var milestoneMessage: String {
        switch streakDays {
        case 7: return "7-Day Champion!"
        case 30: return "One Month Strong!"
        case 100: return "Century Club!"
        case 365: return "One Year Legend!"
        default: return "\(streakDays)-Day Streak!"
        }
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 20) {
                // Flame Animation
                VStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                        .scaleEffect(isVisible ? 1 : 0.5)

                    Text("\(streakDays)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    Text("Days Smoke-Free")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                // Milestone Text
                VStack(spacing: 4) {
                    Text(milestoneMessage)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(PuffFreeTheme.accentTeal)

                    Text("Keep that streak burning!")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                // Action Button
                Button {
                    withAnimation {
                        onDismiss()
                    }
                } label: {
                    Text("Keep Going!")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [
                                Color.orange.opacity(0.8),
                                Color.orange.opacity(0.6)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(32)
            .background(PuffFreeTheme.backgroundCard)
            .cornerRadius(16)
            .scaleEffect(scale)
            .opacity(opacity)
            .frame(maxWidth: 300)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
                isVisible = true
            }

            HapticManager.notification(.success)

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Quest Completion Toast

struct QuestCompletionToastView: View {
    let quest: Quest
    let xpGained: Int
    @State private var offset: CGFloat = 100
    @State private var opacity: Double = 0
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: quest.type.icon)
                    .font(.system(size: 16))
                    .foregroundColor(PuffFreeTheme.accentTeal)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Quest Complete!")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)

                    Text(quest.type.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("XP Earned")
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.textSecondary)

                    Text("+\(xpGained)")
                        .font(.headline)
                        .foregroundColor(PuffFreeTheme.accentTeal)
                }
            }
            .padding(12)
            .background(PuffFreeTheme.backgroundCard)
            .cornerRadius(8)
        }
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                offset = 0
                opacity = 1
            }

            HapticManager.selection()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    offset = -100
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

#Preview {
    LevelUpCelebrationView(newLevel: .phoenix_rising) {}
        .preferredColorScheme(.dark)
}
