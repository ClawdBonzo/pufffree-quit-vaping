import SwiftUI

struct GamificationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GamificationViewModel?
    @State private var showBadges = false

    var body: some View {
        VStack(spacing: 20) {
            // Level Card
            if let state = viewModel?.gamificationState {
                LevelCardView(state: state, viewModel: viewModel)
            }

            // Streak Display
            if let state = viewModel?.gamificationState {
                StreakView(state: state)
            }

            // XP Progress Bar
            if let viewModel = viewModel {
                XPProgressView(viewModel: viewModel)
            }

            // Quick Stats
            if let state = viewModel?.gamificationState {
                QuickStatsView(state: state)
            }

            // Badges Button
            Button {
                showBadges = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.white)
                    Text("View Badges")
                        .font(.headline)
                    Spacer()
                    if let unlockedCount = viewModel?.badges.filter({ $0.isUnlocked }).count {
                        Text("\(unlockedCount)")
                            .font(.caption)
                            .foregroundColor(PuffFreeTheme.accentTeal)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(PuffFreeTheme.backgroundCard)
                .cornerRadius(12)
            }
            .foregroundColor(.white)

            Spacer()
        }
        .padding(20)
        .background(PuffFreeTheme.backgroundPrimary)
        .onAppear {
            if viewModel == nil {
                viewModel = GamificationViewModel(modelContext: modelContext)
            }
        }
        .sheet(isPresented: $showBadges) {
            BadgesView(viewModel: viewModel)
        }
    }
}

// MARK: - Level Card

struct LevelCardView: View {
    let state: GamificationState
    let viewModel: GamificationViewModel?

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Level Icon
                VStack(spacing: 8) {
                    Image(systemName: state.currentLevel.icon)
                        .font(.system(size: 28))
                        .foregroundColor(.white)

                    Text("Level \(state.currentLevel.rawValue)")
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                .frame(width: 60)
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: state.currentLevel.color).opacity(0.3),
                            Color(hex: state.currentLevel.color).opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)

                // Level Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(state.currentLevel.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Total XP: \(state.totalXP)")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                Spacer()
            }
            .padding(16)
            .background(PuffFreeTheme.backgroundCard)
            .cornerRadius(12)

            // Next Level Preview
            if state.currentLevel.rawValue < PlayerLevel.legendary.rawValue {
                HStack(spacing: 12) {
                    Image(systemName: PlayerLevel(rawValue: state.currentLevel.rawValue + 1)?.icon ?? "star")
                        .font(.system(size: 16))
                        .foregroundColor(PuffFreeTheme.accentTeal)

                    Text("Next: \(PlayerLevel(rawValue: state.currentLevel.rawValue + 1)?.title ?? "Unknown")")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)

                    Spacer()

                    Text("+\(PlayerLevel(rawValue: state.currentLevel.rawValue + 1)?.xpRequired ?? 0 - state.totalXP) XP")
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.accentTeal)
                }
                .padding(12)
                .background(PuffFreeTheme.backgroundCard.opacity(0.5))
                .cornerRadius(8)
            }
        }
    }
}

// MARK: - Streak View

struct StreakView: View {
    let state: GamificationState

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Current Streak")
                        .font(.headline)
                        .foregroundColor(.white)
                }

                Text("\(state.streakDays) days")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(PuffFreeTheme.accentTeal)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Best Streak")
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)

                Text("\(state.bestStreak) days")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("XP Multiplier")
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)

                Text("\(String(format: "%.1f", state.streakMultiplier))x")
                    .font(.headline)
                    .foregroundColor(PuffFreeTheme.accentTeal)
            }
        }
        .padding(16)
        .background(PuffFreeTheme.backgroundCard)
        .cornerRadius(12)
    }
}

// MARK: - XP Progress Bar

struct XPProgressView: View {
    let viewModel: GamificationViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Experience Progress")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if let state = viewModel.gamificationState {
                    Text("\(state.levelProgress) XP")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 6)
                        .fill(PuffFreeTheme.backgroundCard)

                    // Progress
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    PuffFreeTheme.accentTeal,
                                    Color(hex: "4DB8A8")
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.getXPPercentage())
                }
                .frame(height: 12)
            }
            .frame(height: 12)

            HStack {
                let (current, next) = viewModel.getCurrentLevelProgress()
                Text("\(current) / \(next)")
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.textSecondary)

                Spacer()

                let percentage = Int(viewModel.getXPPercentage() * 100)
                Text("\(percentage)%")
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.accentTeal)
            }
        }
        .padding(16)
        .background(PuffFreeTheme.backgroundCard)
        .cornerRadius(12)
    }
}

// MARK: - Quick Stats

struct QuickStatsView: View {
    let state: GamificationState

    var body: some View {
        HStack(spacing: 12) {
            StatCard(
                icon: "checkmark.circle.fill",
                label: "Quests",
                value: "\(state.totalQuestsCompleted)"
            )

            StatCard(
                icon: "star.fill",
                label: "Badges",
                value: "\(state.totalBadgesUnlocked)"
            )
        }
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(PuffFreeTheme.accentTeal)

            Text(label)
                .font(.caption)
                .foregroundColor(PuffFreeTheme.textSecondary)

            Text(value)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(PuffFreeTheme.backgroundCard)
        .cornerRadius(8)
    }
}

#Preview {
    GamificationView()
        .preferredColorScheme(.dark)
}
