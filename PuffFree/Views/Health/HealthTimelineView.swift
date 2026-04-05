import SwiftUI
import SwiftData

struct HealthTimelineView: View {
    @Query private var profiles: [UserProfile]
    @State private var viewModel = HealthViewModel()

    private var profile: UserProfile? { profiles.first }

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
                            HealthMilestoneRow(
                                milestone: milestone,
                                isLast: index == viewModel.milestones.count - 1
                            )
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer().frame(height: 100)
                }
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Health Recovery")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .onAppear {
            if let profile {
                viewModel.update(hoursSinceQuit: profile.hoursSinceQuit)
            }
        }
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
