import SwiftUI
import SwiftData

struct SavingsView: View {
    @Query private var profiles: [UserProfile]

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                if let profile {
                    VStack(spacing: 20) {
                        // Big number
                        GlassCard {
                            VStack(spacing: 8) {
                                Text("Total Saved")
                                    .font(.subheadline)
                                    .foregroundColor(PuffFreeTheme.textSecondary)
                                Text(String(format: "$%.2f", profile.moneySaved))
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundStyle(PuffFreeTheme.savingsGradient)
                            }
                        }
                        .padding(.horizontal, 16)

                        // Projections
                        VStack(spacing: 12) {
                            SavingsProjectionRow(
                                period: "Daily savings",
                                amount: dailySavings(profile)
                            )
                            SavingsProjectionRow(
                                period: "Weekly projection",
                                amount: dailySavings(profile) * 7
                            )
                            SavingsProjectionRow(
                                period: "Monthly projection",
                                amount: dailySavings(profile) * 30
                            )
                            SavingsProjectionRow(
                                period: "Yearly projection",
                                amount: dailySavings(profile) * 365
                            )
                        }
                        .padding(.horizontal, 16)

                        // Reward ideas
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What could you buy?")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                let saved = profile.moneySaved
                                ForEach(rewardIdeas(for: saved), id: \.name) { reward in
                                    HStack {
                                        Image(systemName: reward.icon)
                                            .foregroundStyle(PuffFreeTheme.savingsGradient)
                                            .frame(width: 24)
                                        Text(reward.name)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text(String(format: "$%.0f", reward.cost))
                                            .font(.caption)
                                            .foregroundColor(saved >= reward.cost ? PuffFreeTheme.success : PuffFreeTheme.textTertiary)

                                        Image(systemName: saved >= reward.cost ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(saved >= reward.cost ? PuffFreeTheme.success : PuffFreeTheme.textTertiary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        Spacer().frame(height: 100)
                    }
                    .padding(.top, 8)
                }
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Savings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func dailySavings(_ profile: UserProfile) -> Double {
        profile.costPerPack / Double(max(profile.packSize, 1)) * Double(profile.dailyUsageCount)
    }

    private func rewardIdeas(for amount: Double) -> [(name: String, cost: Double, icon: String)] {
        [
            ("Coffee treat", 7, "cup.and.saucer.fill"),
            ("Nice lunch", 25, "fork.knife"),
            ("New book", 20, "book.fill"),
            ("Movie night", 40, "film.fill"),
            ("New shoes", 100, "shoe.fill"),
            ("Weekend trip", 300, "airplane"),
            ("New gadget", 500, "iphone"),
            ("Vacation fund", 1000, "beach.umbrella")
        ]
    }
}

struct SavingsProjectionRow: View {
    let period: String
    let amount: Double

    var body: some View {
        HStack {
            Text(period)
                .font(.subheadline)
                .foregroundColor(PuffFreeTheme.textSecondary)
            Spacer()
            Text(String(format: "$%.2f", amount))
                .font(.headline)
                .foregroundColor(.white)
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
