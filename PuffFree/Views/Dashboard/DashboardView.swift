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

    // Entrance animation states
    @State private var heroVisible     = false
    @State private var statsVisible    = false
    @State private var questsVisible   = false
    @State private var milestoneVisible = false
    @State private var xpBarWidth: CGFloat = 0
    @State private var streakPulse = false

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
                    VStack(spacing: 14) {

                        // ─── HERO CARD: Timer + XP + Streak ──────────────────
                        heroCard
                            .padding(.horizontal, 16)
                            .scaleEffect(heroVisible ? 1 : 0.93)
                            .opacity(heroVisible ? 1 : 0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.75), value: heroVisible)

                        // ─── 3-STAT ROW ───────────────────────────────────────
                        statRow
                            .padding(.horizontal, 16)
                            .offset(y: statsVisible ? 0 : 20)
                            .opacity(statsVisible ? 1 : 0)
                            .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.1), value: statsVisible)

                        // ─── TODAY'S QUESTS ───────────────────────────────────
                        if let gamVM = gamificationViewModel {
                            questsSection(gamVM: gamVM)
                                .padding(.horizontal, 16)
                                .offset(y: questsVisible ? 0 : 20)
                                .opacity(questsVisible ? 1 : 0)
                                .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.18), value: questsVisible)
                        }

                        // ─── NEXT MILESTONE ───────────────────────────────────
                        if let next = viewModel.nextMilestone {
                            NextMilestoneCard(
                                milestone: next,
                                progress: viewModel.progressToNextMilestone
                            )
                            .padding(.horizontal, 16)
                            .offset(y: milestoneVisible ? 0 : 20)
                            .opacity(milestoneVisible ? 1 : 0)
                            .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.26), value: milestoneVisible)
                        }

                        // ─── MOTIVATION + SAVINGS ─────────────────────────────
                        HStack(spacing: 12) {
                            MotivationCardView()
                            SavingsHighlightCard(moneySaved: viewModel.moneySaved)
                        }
                        .padding(.horizontal, 16)
                        .opacity(milestoneVisible ? 1 : 0)
                        .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.33), value: milestoneVisible)

                        Spacer().frame(height: 90)
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
                            LevelUpCelebrationView(newLevel: level) { activeCelebration = nil }
                        case .badgeUnlock(let badge):
                            BadgeUnlockCelebrationView(badge: badge) { activeCelebration = nil }
                        case .streakMilestone(let days):
                            StreakMilestoneCelebrationView(streakDays: days) { activeCelebration = nil }
                        case .questCompletion(let quest, let xp):
                            QuestCompletionToastView(quest: quest, xpGained: xp) { activeCelebration = nil }
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
                if gamificationViewModel == nil {
                    gamificationViewModel = GamificationViewModel(modelContext: modelContext)
                }
                if let gamVM = gamificationViewModel {
                    gamVM.updateStreak(daysSinceQuit: profile.daysSinceQuit)
                    gamVM.checkAndUnlockBadges(profile: profile)
                }
            }
            // Staggered entrance
            withAnimation { heroVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { statsVisible    = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { questsVisible   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { milestoneVisible = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { streakPulse      = true }
        }
        .onDisappear { viewModel.stopTracking() }
        .fullScreenCover(isPresented: $showCelebration) {
            if let milestone = celebratingMilestone {
                MilestoneCelebrationView(milestone: milestone, isPresented: $showCelebration)
            }
        }
    }

    // MARK: - Hero Card (Timer + XP bar + Streak)

    @ViewBuilder
    private var heroCard: some View {
        let gamState = gamificationViewModel?.gamificationState

        GlassCard {
            VStack(spacing: 14) {
                // Timer row
                HStack(alignment: .center, spacing: 0) {
                    VStack(spacing: 2) {
                        Text("Puff-Free For")
                            .font(.caption)
                            .foregroundColor(PuffFreeTheme.textSecondary)

                        HStack(spacing: 2) {
                            HeroTimeUnit(value: viewModel.timeComponents.days,    label: "D")
                            HeroColon()
                            HeroTimeUnit(value: viewModel.timeComponents.hours,   label: "H")
                            HeroColon()
                            HeroTimeUnit(value: viewModel.timeComponents.minutes, label: "M")
                            HeroColon()
                            HeroTimeUnit(value: viewModel.timeComponents.seconds, label: "S")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Streak badge
                    VStack(spacing: 3) {
                        ZStack {
                            Circle()
                                .fill(Color.orange.opacity(0.18))
                                .frame(width: 52, height: 52)
                                .scaleEffect(streakPulse ? 1.12 : 1.0)
                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: streakPulse)

                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
                                )
                        }
                        Text("\(gamificationViewModel?.gamificationState?.streakDays ?? 0)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("streak")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(PuffFreeTheme.textTertiary)
                            .textCase(.uppercase)
                    }
                }

                Divider().background(Color.white.opacity(0.08))

                // XP Level bar
                if let state = gamState {
                    VStack(spacing: 6) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: state.currentLevel.icon)
                                    .font(.caption)
                                    .foregroundColor(Color(hex: state.currentLevel.color))
                                Text(state.currentLevel.title)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Text("\(state.totalXP) XP")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.accentTeal)
                        }

                        // Animated XP progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.08))
                                    .frame(height: 7)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [PuffFreeTheme.accentTeal, Color(hex: state.currentLevel.color)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: xpBarWidth, height: 7)
                                    .onAppear {
                                        let pct = xpProgressPct(state: state)
                                        withAnimation(.spring(response: 1.1, dampingFraction: 0.8).delay(0.5)) {
                                            xpBarWidth = geo.size.width * pct
                                        }
                                    }
                            }
                        }
                        .frame(height: 7)

                        // Next level teaser
                        if let next = PlayerLevel(rawValue: state.currentLevel.rawValue + 1) {
                            HStack {
                                Spacer()
                                Text("Next: \(next.title)  →  \(next.xpRequired) XP")
                                    .font(.system(size: 9))
                                    .foregroundColor(PuffFreeTheme.textTertiary)
                            }
                        }
                    }
                } else {
                    // Skeleton XP bar while loading
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 7)
                }
            }
        }
    }

    // MARK: - 3-Stat Row

    private var statRow: some View {
        HStack(spacing: 10) {
            MiniStatCard(
                icon: "nosign",
                value: "\(viewModel.puffsAvoided)",
                label: "Avoided",
                color: .red
            )
            MiniStatCard(
                icon: "dollarsign.circle.fill",
                value: String(format: "$%.0f", viewModel.moneySaved),
                label: "Saved",
                color: PuffFreeTheme.accentTeal
            )
            MiniStatCard(
                icon: "heart.fill",
                value: viewModel.lifeRegained,
                label: "Regained",
                color: Color(hex: "FF6B9D")
            )
        }
    }

    // MARK: - Quests Section

    @ViewBuilder
    private func questsSection(gamVM: GamificationViewModel) -> some View {
        let active = gamVM.getActiveQuests()
        let done   = gamVM.getCompletedQuests().count

        if !active.isEmpty || done > 0 {
            VStack(spacing: 0) {
                // Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("Today's Quests")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Progress pill
                    Text("\(done) / \(done + active.count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(done == (done + active.count) ? PuffFreeTheme.success : PuffFreeTheme.accentTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            (done == (done + active.count) ? PuffFreeTheme.success : PuffFreeTheme.accentTeal)
                                .opacity(0.15)
                        )
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 10)

                // Quest rows
                VStack(spacing: 0) {
                    ForEach(active.prefix(3), id: \.id) { quest in
                        QuestPreviewRow(quest: quest)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 2)
                    }
                    if active.isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(PuffFreeTheme.success)
                            Text("All quests completed! 🎉")
                                .font(.subheadline)
                                .foregroundColor(PuffFreeTheme.success)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                    }
                }
                .padding(.bottom, 8)
            }
            .background(PuffFreeTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }

    // MARK: - Helpers

    private func xpProgressPct(state: GamificationState) -> CGFloat {
        let current = CGFloat(state.totalXP - state.currentLevel.xpRequired)
        let next = CGFloat(
            (PlayerLevel(rawValue: state.currentLevel.rawValue + 1)?.xpRequired ?? state.currentLevel.xpRequired + 1000)
            - state.currentLevel.xpRequired
        )
        guard next > 0 else { return 1.0 }
        return min(max(current / next, 0), 1.0)
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

// MARK: - Supporting Views

struct HeroTimeUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 0) {
            Text(String(format: "%02d", value))
                .font(.system(size: 34, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: value)
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(PuffFreeTheme.textTertiary)
        }
        .frame(minWidth: 48)
    }
}

struct HeroColon: View {
    @State private var visible = true

    var body: some View {
        Text(":")
            .font(.system(size: 26, weight: .bold, design: .monospaced))
            .foregroundColor(PuffFreeTheme.accentTeal)
            .opacity(visible ? 1 : 0.25)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    visible.toggle()
                }
            }
    }
}

struct MiniStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(height: 24)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(PuffFreeTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

struct NextMilestoneCard: View {
    let milestone: MilestoneType
    let progress: Double

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: milestone.icon)
                        .font(.subheadline)
                        .foregroundStyle(PuffFreeTheme.primaryGradient)
                    Text("Next Milestone")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Text(milestone.rawValue)
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.accentTeal)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(PuffFreeTheme.accentTeal.opacity(0.15))
                        .clipShape(Capsule())
                }

                ProgressView(value: progress)
                    .tint(PuffFreeTheme.accentTeal)
                    .scaleEffect(x: 1, y: 1.4, anchor: .center)

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
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title2)
                    .foregroundStyle(PuffFreeTheme.savingsGradient)
                Text(String(format: "$%.2f", moneySaved))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(PuffFreeTheme.savingsGradient)
                Text("Saved")
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct QuestPreviewRow: View {
    let quest: Quest

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(PuffFreeTheme.accentTeal.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: quest.type.icon)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.accentTeal)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(quest.type.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(quest.questDescription)
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("+\(quest.xpReward)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(PuffFreeTheme.accentTeal)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(PuffFreeTheme.accentTeal.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
}

