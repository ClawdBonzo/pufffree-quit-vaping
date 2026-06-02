import SwiftUI

/// A polished, encouraging empty state — a gradient icon medallion that gently
/// scales in, with a motivating title and message. Replaces flat blank screens
/// on day 0 (no journal entries, no cravings logged, etc.).
/// Respects Reduce Motion (skips the entrance animation).
struct MotivationalEmptyState: View {
    let icon: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(PuffFreeTheme.accentTeal.opacity(0.15))
                    .frame(width: 92, height: 92)
                Image(systemName: icon)
                    .font(.system(size: 38, weight: .semibold))
                    .foregroundStyle(PuffFreeTheme.primaryGradient)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.subheadline)
                .foregroundColor(PuffFreeTheme.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
        .padding(.vertical, 40)
        .accessibilityElement(children: .combine)
        .onAppear {
            guard !reduceMotion else { appeared = true; return }
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { appeared = true }
        }
    }
}
