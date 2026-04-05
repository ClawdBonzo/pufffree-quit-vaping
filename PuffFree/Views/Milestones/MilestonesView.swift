import SwiftUI
import SwiftData

struct MilestonesView: View {
    @Query(sort: \MilestoneRecord.unlockedAt) private var records: [MilestoneRecord]
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Summary
                    let unlocked = records.filter(\.isUnlocked).count
                    HStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("\(unlocked)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(PuffFreeTheme.primaryGradient)
                            Text("Unlocked")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(PuffFreeTheme.backgroundCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        VStack(spacing: 4) {
                            Text("\(MilestoneType.allCases.count - unlocked)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(PuffFreeTheme.textTertiary)
                            Text("Remaining")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(PuffFreeTheme.backgroundCard)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 16)

                    // Grid
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(MilestoneType.allCases) { milestone in
                            let record = records.first { $0.milestoneType == milestone }
                            let isUnlocked = record?.isUnlocked ?? false

                            MilestoneGridItem(
                                milestone: milestone,
                                isUnlocked: isUnlocked,
                                unlockedAt: record?.unlockedAt
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
            .navigationTitle("Milestones")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct MilestoneGridItem: View {
    let milestone: MilestoneType
    let isUnlocked: Bool
    let unlockedAt: Date?

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: milestone.icon)
                .font(.system(size: 28))
                .foregroundStyle(isUnlocked ? PuffFreeTheme.primaryGradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))

            Text(milestone.rawValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isUnlocked ? .white : PuffFreeTheme.textTertiary)
                .multilineTextAlignment(.center)

            if let date = unlockedAt {
                Text(date.shortFormatted)
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.accentTeal)
            } else {
                Text("\(milestone.hoursRequired)h needed")
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.textTertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            isUnlocked ? PuffFreeTheme.backgroundElevated : PuffFreeTheme.backgroundCard
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isUnlocked ? PuffFreeTheme.accentTeal.opacity(0.3) : Color.white.opacity(0.06),
                    lineWidth: 1
                )
        )
    }
}
