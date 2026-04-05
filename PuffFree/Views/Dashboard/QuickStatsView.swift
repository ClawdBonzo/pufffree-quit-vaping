import SwiftUI

struct QuickStatsView: View {
    let viewModel: QuitViewModel

    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                title: "Streak",
                value: "\(viewModel.currentStreak)",
                unit: "days",
                icon: "flame.fill",
                gradient: LinearGradient(
                    colors: [.orange, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            QuickStatCard(
                title: "Saved",
                value: String(format: "$%.0f", viewModel.moneySaved),
                unit: "",
                icon: "dollarsign.circle.fill",
                gradient: PuffFreeTheme.savingsGradient
            )

            QuickStatCard(
                title: "Avoided",
                value: formatNumber(viewModel.puffsAvoided),
                unit: "puffs",
                icon: "nosign",
                gradient: PuffFreeTheme.healthGradient
            )
        }
    }

    private func formatNumber(_ num: Int) -> String {
        if num >= 1000 {
            return String(format: "%.1fk", Double(num) / 1000)
        }
        return "\(num)"
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let gradient: LinearGradient

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(gradient)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)

            if !unit.isEmpty {
                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(PuffFreeTheme.textTertiary)
            }

            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(PuffFreeTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}
