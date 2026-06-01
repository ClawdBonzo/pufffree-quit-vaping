import SwiftUI

// MARK: - Premium Gate Overlay

struct PremiumGateOverlay: View {
    let title: String
    let subtitle: String
    var iconName: String = "lock.fill"

    @Environment(\.subscriptionViewModel) private var subscriptionVM
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showPaywall = false
    @State private var lockPulse = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.85)

            VStack(spacing: 16) {
                // Lock icon with flame glow
                ZStack {
                    Circle()
                        .fill(PuffFreeTheme.emberOrange.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .scaleEffect(lockPulse ? 1.12 : 1.0)
                        .animation(
                            reduceMotion ? nil : .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                            value: lockPulse
                        )

                    Image(systemName: iconName)
                        .font(.system(size: 32))
                        .foregroundStyle(PuffFreeTheme.flameGradient)
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    showPaywall = true
                } label: {
                    Text("Unlock Pro")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(PuffFreeTheme.flameGradient)
                        .clipShape(Capsule())
                        .shadow(color: PuffFreeTheme.emberOrange.opacity(0.4), radius: 10, y: 4)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(subtitle). Double tap to unlock.")
        .accessibilityAddTraits(.isButton)
        .onAppear {
            guard !reduceMotion else { return }
            lockPulse = true
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onDismiss: { showPaywall = false })
                .environment(\.subscriptionViewModel, subscriptionVM)
        }
    }
}

// MARK: - Premium Gate Modifier

struct PremiumGateModifier: ViewModifier {
    let isLocked: Bool
    let title: String
    let subtitle: String
    var iconName: String = "lock.fill"

    func body(content: Content) -> some View {
        if isLocked {
            content
                .overlay {
                    PremiumGateOverlay(
                        title: title,
                        subtitle: subtitle,
                        iconName: iconName
                    )
                }
                .allowsHitTesting(true)
        } else {
            content
        }
    }
}

extension View {
    func premiumGate(
        isLocked: Bool,
        title: String,
        subtitle: String,
        iconName: String = "lock.fill"
    ) -> some View {
        modifier(PremiumGateModifier(
            isLocked: isLocked,
            title: title,
            subtitle: subtitle,
            iconName: iconName
        ))
    }
}
