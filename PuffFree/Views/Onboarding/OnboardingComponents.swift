import SwiftUI

// MARK: - Floating Orb (background ambient light)

struct FloatingOrb: View {
    let color: Color
    let size: CGFloat
    let xOffset: CGFloat
    let yRange: CGFloat
    let duration: Double
    var startDelay: Double = 0

    @State private var floating = false

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [color.opacity(0.28), color.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .offset(x: xOffset, y: floating ? -yRange : yRange)
            .animation(
                .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(startDelay),
                value: floating
            )
            .onAppear { floating = true }
            .allowsHitTesting(false)
    }
}

// MARK: - Social Proof Capsule

struct SocialProofBar: View {
    var label: String = "50,000+ quit successfully"

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 1) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundColor(Color(hex: "FFD700"))
                }
            }
            Text("4.9")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
            Text("·")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.35))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.65))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(Color.white.opacity(0.07))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.1), lineWidth: 0.5))
    }
}

// MARK: - Onboarding Step Heading

struct OnboardingHeading: View {
    let title: String
    var subtitle: String? = nil
    var gradientTitle: Bool = false

    var body: some View {
        VStack(spacing: 5) {
            if gradientTitle {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(PuffFreeTheme.primaryGradient)
                    .multilineTextAlignment(.center)
            } else {
                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            if let sub = subtitle {
                Text(sub)
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Continue Button (shared style)

struct OnboardingCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(PuffFreeTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: PuffFreeTheme.accentTeal.opacity(0.4), radius: 14, y: 5)
        }
        .padding(.horizontal, 24)
    }
}
