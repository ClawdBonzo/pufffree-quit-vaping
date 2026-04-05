import SwiftUI

struct MotivationCardView: View {
    @State private var quoteData = AppConstants.MotivationalQuotes.random

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
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
