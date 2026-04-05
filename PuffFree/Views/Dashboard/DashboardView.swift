import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \MilestoneRecord.unlockedAt) private var milestones: [MilestoneRecord]
    @State private var viewModel = QuitViewModel()
    @State private var showCelebration = false
    @State private var celebratingMilestone: MilestoneType?
    @Environment(\.modelContext) private var modelContext

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Timer Card
                    TimerCardView(viewModel: viewModel)
                        .padding(.horizontal, 16)

                    // Quick Stats
                    QuickStatsView(viewModel: viewModel)
                        .padding(.horizontal, 16)

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
            .navigationTitle("PuffFree")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            if let profile {
                viewModel.startTracking(profile: profile)
                checkMilestones()
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
