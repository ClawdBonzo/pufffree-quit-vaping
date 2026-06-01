import SwiftUI

struct ContextualPaywallView: View {
    let contextMessage: String
    let contextSubtitle: String
    var onDismiss: (() -> Void)?

    @Environment(\.subscriptionViewModel) private var subscriptionVM

    var body: some View {
        VStack(spacing: 0) {
            // Contextual header
            VStack(spacing: 8) {
                Text(contextMessage)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(PuffFreeTheme.flameGradient)

                Text(contextSubtitle)
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .padding(.bottom, 4)
            .padding(.horizontal, 24)

            PaywallView(onDismiss: onDismiss)
                .environment(\.subscriptionViewModel, subscriptionVM)
        }
        .background(Color(hex: "060D12").ignoresSafeArea())
    }
}
