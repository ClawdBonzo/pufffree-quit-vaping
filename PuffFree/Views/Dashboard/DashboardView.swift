import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \MilestoneRecord.unlockedAt) private var milestones: [MilestoneRecord]
    @State private var viewModel = QuitViewModel()
    @State private var gamificationViewModel: GamificationViewModel?
    @State private var showCelebration = false
    @State private var celebratingMilestone: MilestoneType?
    @State private var activeCelebration: CelebrationOverlayType?
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile? { profiles.first }

    enum CelebrationOverlayType {
        case levelUp(PlayerLevel)
        case badgeUnlock(Badge)
        case streakMilestone(Int)
        case questCompletion(Quest, Int)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Timer Card
                        TimerCardView(viewModel: viewModel)
                            .padding(.horizontal, 16)

                        // Quick Stats
                        QuickStatsView(viewModel: viewModel)
                            .padding(.horizontal, 16)

                        // Gamification Level Card
                        if let gamVM = gamificationViewModel, let state = gamVM.gamificationState {
                            LevelCardView(state: state)
                                .padding(.horizontal, 16)
                        }

                        // Active Quests Preview
                        if let gamVM = gamificationViewModel {
                            let activeQuests = gamVM.getActiveQuests()
                            if !activeQuests.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Today's Quests")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        let completed = gamVM.getCompletedQuests().count
                                        Text("\(completed)/\(completed + activeQuests.count)")
                                            .font(.caption)
                                            .foregroundColor(PuffFreeTheme.accentTeal)
                                    }
                                    .padding(.horizontal, 20)

                                    VStack(spacing: 8) {
                                        ForEach(activeQuests.prefix(3), id: \.id) { quest in
                                            QuestPreviewRow(quest: quest)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .padding(.vertical, 16)
                                .background(PuffFreeTheme.backgroundCard)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                        }

                        // Next Milestone
                        if let next = viewModel.nextMilestone {
                            NextMilestoneCard(
                                milestone: next,
                                progress: viewModel.progressToNextMilestone
                            )
                            .padding(.horizontal, 16)
                        }

                        // Motivation
                        MotivationCardView()
                            .padding(.horizontal, 16)

                        // Savings highlight
                        SavingsHighlightCard(moneySaved: viewModel.moneySaved)
                            .padding(.horizontal, 16)

                        Spacer().frame(height: 80)
                    }
                    .padding(.top, 8)
                }
                .scrollIndicators(.hidden)
                .background(PuffFreeTheme.backgroundPrimary)

                // Celebration Overlays
                if let celebration = activeCelebration {
                    ZStack {
                        switch celebration {
                        case .levelUp(let level):
                            LevelUpCelebrationView(newLevel: level) {
                                activeCelebration = nil
                            }
                        case .badgeUnlock(let badge):
                            BadgeUnlockCelebrationView(badge: badge) {
                                activeCelebration = nil
                            }
                        case .streakMilestone(let days):
                            StreakMilestoneCelebrationView(streakDays: days) {
                                activeCelebration = nil
                            }
                        case .questCompletion(let quest, let xp):
                            QuestCompletionToastView(quest: quest, xpGained: xp) {
                                activeCelebration = nil
                            }
                        }
                    }
                }
            }
            .navigationTitle("PuffFree")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            if let profile {
                viewModel.startTracking(profile: profile)
                checkMilestones()

                // Initialize gamification
                if gamificationViewModel == nil {
                    gamificationViewModel = GamificationViewModel(modelContext: modelContext)
                }

                // Update streak and check for badge unlocks
                if let gamVM = gamificationViewModel {
                    gamVM.updateStreak(daysSinceQuit: profile.daysSinceQuit)
                    gamVM.checkAndUnlockBadges(profile: profile)
                }
            }
        }
        .onDisappear {
            viewModel.stopTracking()
        }
        .fullScreenCover(isPresented: $showCelebration) {
            if let milestone = celebratingMilestone {
                MilestoneCelebrationView(milestone: milestone, isPresented: $showCelebration)
            }
        }
    }

    private func checkMilestones() {
        guard let profile else { return }
        if let newMilestone = viewModel.checkForNewMilestones(
            profile: profile,
            existingRecords: milestones,
            modelContext: modelContext
        ) {
            celebratingMilestone = newMilestone
            showCelebration = true
        }
    }
}

struct NextMilestoneCard: View {
    let milestone: MilestoneType
    let progress: Double

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: milestone.icon)
                        .font(.title3)
                        .foregroundStyle(PuffFreeTheme.primaryGradient)

                    Text("Next Milestone")
                        .font(.headline)
                        .foregroundColor(.white)

                    Spacer()

                    Text(milestone.rawValue)
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.accentTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(PuffFreeTheme.accentTeal.opacity(0.15))
                        .clipShape(Capsule())
                }

                ProgressView(value: progress)
                    .tint(PuffFreeTheme.accentTeal)

                Text(milestone.celebrationMessage)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
        }
    }
}

struct SavingsHighlightCard: View {
    let moneySaved: Double

    var body: some View {
        GlassCard {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Money Saved")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                    Text(String(format: "$%.2f", moneySaved))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(PuffFreeTheme.savingsGradient)
                }

                Spacer()

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(PuffFreeTheme.savingsGradient)
            }
        }
    }
}

struct LevelCardView: View {
    let state: GamificationState

    var body: some View {
        GlassCard {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Level")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                    Text(state.currentLevel.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(state.totalXP) XP")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.accentTeal)
                }

                Spacer()

                Image(systemName: state.currentLevel.icon)
                    .font(.system(size: 44))
                    .foregroundColor(Color(hex: state.currentLevel.color))
            }
        }
    }
}

struct QuestPreviewRow: View {
    let quest: Quest

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.type.icon)
                .font(.system(size: 16))
                .foregroundColor(PuffFreeTheme.accentTeal)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(quest.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.white)
                Text(quest.questDescription)
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("+\(quest.xpReward) XP")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(PuffFreeTheme.accentTeal)
        }
        .padding(8)
        .background(PuffFreeTheme.backgroundPrimary)
        .cornerRadius(6)
    }
}
