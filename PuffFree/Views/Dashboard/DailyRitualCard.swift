import SwiftUI

/// Free-tier daily habit loop: a once-per-day affirmation that grants a small XP
/// reward, surfaces the user's Streak Shields, and offers a gentle Pro upsell.
/// Gives non-subscribers a concrete reason to open the app every day.
struct DailyRitualCard: View {
    let viewModel: GamificationViewModel
    var onUpgrade: () -> Void

    @State private var done = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(PuffFreeTheme.accentTeal.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: done ? "checkmark.seal.fill" : "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(PuffFreeTheme.primaryGradient)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(done ? "Daily ritual complete" : "Daily Ritual")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                    Text(done
                         ? "See you tomorrow — your streak is safe."
                         : "Affirm today and earn +20 XP.")
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                Spacer()

                if viewModel.streakShieldCount > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "shield.lefthalf.filled").font(.caption2)
                        Text("\(viewModel.streakShieldCount)").font(.caption2.weight(.bold))
                    }
                    .foregroundColor(PuffFreeTheme.accentTeal)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(viewModel.streakShieldCount) streak shields")
                }
            }

            Button {
                if viewModel.completeDailyRitual() {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7)) {
                        done = true
                    }
                }
            } label: {
                Text(done ? "Done today ✓" : "I'm still smoke-free today")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(done ? PuffFreeTheme.textSecondary : .black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(done
                                ? AnyShapeStyle(PuffFreeTheme.backgroundCard.opacity(0.6))
                                : AnyShapeStyle(PuffFreeTheme.primaryGradient))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .disabled(done)

            Button(action: onUpgrade) {
                Text("Unlock daily quests, insights & more with Pro")
                    .font(.caption2)
                    .foregroundColor(PuffFreeTheme.phoenixGold)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .onAppear { done = viewModel.isRitualDoneToday }
    }
}
