import SwiftUI

struct BadgesView: View {
    @Environment(\.dismiss) var dismiss
    let viewModel: GamificationViewModel?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Unlocked Badges Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(PuffFreeTheme.accentTeal)
                        Text("Unlocked")
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        if let unlockedCount = viewModel?.badges.filter({ $0.isUnlocked }).count {
                            Text("\(unlockedCount)")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    if let unlockedBadges = viewModel?.getUnlockedBadges() {
                        if unlockedBadges.isEmpty {
                            Text("No badges unlocked yet. Keep going!")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                                .padding(.horizontal, 20)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(unlockedBadges, id: \.id) { badge in
                                        BadgeItemView(badge: badge, isUnlocked: true)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }

                Divider()
                    .background(PuffFreeTheme.backgroundCard)

                // Locked Badges Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(PuffFreeTheme.textSecondary)
                        Text("Locked")
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        if let lockedCount = viewModel?.badges.filter({ !$0.isUnlocked }).count {
                            Text("\(lockedCount)")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                        }
                    }
                    .padding(.horizontal, 20)

                    if let lockedBadges = viewModel?.getLockedBadges() {
                        VStack(spacing: 12) {
                            ForEach(lockedBadges, id: \.id) { badge in
                                LockedBadgeRowView(badge: badge)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                Spacer()
            }
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(PuffFreeTheme.accentTeal)
                    }
                }
            }
        }
    }
}

struct BadgeItemView: View {
    let badge: Badge
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.icon)
                .font(.system(size: 24))
                .foregroundColor(isUnlocked ? PuffFreeTheme.accentTeal : PuffFreeTheme.textSecondary)

            Text(badge.title)
                .font(.caption2)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80, height: 100)
        .padding(12)
        .background(isUnlocked ? PuffFreeTheme.backgroundCard : PuffFreeTheme.backgroundCard.opacity(0.5))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isUnlocked ? PuffFreeTheme.accentTeal : Color.clear,
                    lineWidth: 1.5
                )
        )
    }
}

struct LockedBadgeRowView: View {
    let badge: Badge

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: badge.icon)
                    .font(.system(size: 20))
                    .foregroundColor(PuffFreeTheme.textSecondary.opacity(0.6))
                    .frame(width: 40, alignment: .center)

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(badge.title)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(badge.badgeDescription)
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                // Lock icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                    .foregroundColor(PuffFreeTheme.textSecondary.opacity(0.6))
            }
            .padding(12)
            .background(PuffFreeTheme.backgroundCard.opacity(0.5))
            .cornerRadius(8)
        }
    }
}

#Preview {
    BadgesView(viewModel: nil)
        .preferredColorScheme(.dark)
}
