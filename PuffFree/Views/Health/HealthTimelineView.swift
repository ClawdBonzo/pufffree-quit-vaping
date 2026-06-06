import SwiftUI
import SwiftData

struct HealthTimelineView: View {
    @Query private var profiles: [UserProfile]
    @State private var viewModel = HealthViewModel()
    @Environment(\.subscriptionViewModel) private var subscriptionVM
    @State private var showPaywall = false
    @State private var showSources = false

    private var profile: UserProfile? { profiles.first }

    /// Free users see the first 3 milestones; Pro sees all
    private let freeMilestoneLimit = 3

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header stats
                    HStack(spacing: 16) {
                        HealthStatBubble(
                            value: "\(viewModel.completedCount)",
                            label: "Completed",
                            icon: "checkmark.circle.fill",
                            color: PuffFreeTheme.success
                        )
                        HealthStatBubble(
                            value: "\(viewModel.milestones.count - viewModel.completedCount)",
                            label: "Remaining",
                            icon: "clock.fill",
                            color: PuffFreeTheme.info
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                    // Timeline
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.milestones.enumerated()), id: \.element.id) { index, milestone in
                            if index < freeMilestoneLimit || subscriptionVM.isPro {
                                HealthMilestoneRow(
                                    milestone: milestone,
                                    isLast: subscriptionVM.isPro
                                        ? index == viewModel.milestones.count - 1
                                        : index == freeMilestoneLimit - 1
                                )
                            } else if index == freeMilestoneLimit {
                                // Gate overlay at the boundary
                                lockedMilestoneGate
                            }
                            // indices beyond freeMilestoneLimit hidden for free users
                        }
                    }
                    .padding(.horizontal, 16)

                    // Citations (Guideline 1.4.1) — always reachable below the timeline.
                    sourcesFooter
                        .padding(.horizontal, 16)
                        .padding(.top, 12)

                    Spacer().frame(height: 100)
                }
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Health Recovery")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSources = true } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(PuffFreeTheme.accentTeal)
                    }
                    .accessibilityLabel("Health information sources")
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false })
                    .environment(\.subscriptionViewModel, subscriptionVM)
            }
            .sheet(isPresented: $showSources) {
                HealthSourcesView()
            }
        }
        .onAppear {
            if let profile {
                viewModel.update(hoursSinceQuit: profile.hoursSinceQuit)
            }
        }
    }

    private var sourcesFooter: some View {
        Button { showSources = true } label: {
            VStack(spacing: 6) {
                Text("Recovery timeline based on guidance from the CDC, NHS & WHO.")
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 4) {
                    Image(systemName: "info.circle")
                    Text("View sources & medical disclaimer")
                }
                .font(.caption2.weight(.semibold))
                .foregroundColor(PuffFreeTheme.accentTeal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var lockedMilestoneGate: some View {
        let remaining = viewModel.milestones.count - freeMilestoneLimit
        Button { showPaywall = true } label: {
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundStyle(PuffFreeTheme.flameGradient)
                Text("Unlock \(remaining) More Milestones")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("See your full health recovery timeline")
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(PuffFreeTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(PuffFreeTheme.emberOrange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }
}

struct HealthStatBubble: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
