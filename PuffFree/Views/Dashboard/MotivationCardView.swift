import SwiftUI

struct MotivationCardView: View {
    /// The user's own reason for quitting, surfaced back to them on hard days.
    var primaryMotivation: String? = nil

    @State private var quoteData = AppConstants.MotivationalQuotes.random

    private var personalReason: String? {
        guard let m = primaryMotivation?.trimmingCharacters(in: .whitespaces), !m.isEmpty
        else { return nil }
        return m
    }

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                // The user's personal "why" — their strongest motivator, brought
                // back to the surface exactly when they need the reminder.
                if let reason = personalReason {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                            .foregroundColor(PuffFreeTheme.danger)
                        Text("\(NSLocalizedString("You quit for", comment: "Personal motivation prefix")) \(reason)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(PuffFreeTheme.textSecondary)
                    }
                    .padding(.bottom, 2)
                }

                HStack {
                    Image(systemName: "quote.opening")
                        .foregroundStyle(PuffFreeTheme.primaryGradient)
                    Text("Daily Motivation")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        withAnimation(.spring) {
                            quoteData = AppConstants.MotivationalQuotes.random
                        }
                        HapticManager.selection()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundColor(PuffFreeTheme.textSecondary)
                    }
                }

                Text(quoteData.quote)
                    .font(.body)
                    .italic()
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("- \(quoteData.author)")
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textTertiary)
            }
        }
    }
}
