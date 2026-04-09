import SwiftUI

struct WelcomeStepView: View {
    @Binding var displayName: String
    let onNext: () -> Void

    @State private var heroVisible  = false
    @State private var statsVisible = false
    @State private var titleVisible = false
    @State private var fieldVisible = false
    @State private var ctaVisible   = false
    @State private var heroFloat    = false

    var body: some View {
        ZStack {
            // Ambient orbs
            FloatingOrb(color: PuffFreeTheme.accentTeal, size: 380, xOffset: -100,
                        yRange: 35, duration: 5.5, startDelay: 0)
                .offset(y: -220)
            FloatingOrb(color: Color(hex: "7C3AED"), size: 260, xOffset: 130,
                        yRange: 28, duration: 7.0, startDelay: 1.2)
                .offset(y: 80)
            FloatingOrb(color: PuffFreeTheme.success, size: 200, xOffset: -60,
                        yRange: 22, duration: 6.2, startDelay: 0.5)
                .offset(y: 260)

            VStack(spacing: 0) {
                Spacer()

                // ── Hero ──────────────────────────────────────────────────
                ZStack {
                    // Glow ring behind image
                    Circle()
                        .fill(PuffFreeTheme.accentTeal.opacity(0.12))
                        .frame(width: 240, height: 240)
                        .blur(radius: 30)
                        .scaleEffect(heroFloat ? 1.15 : 1.0)
                        .animation(
                            .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                            value: heroFloat
                        )

                    Image("OnboardingWelcome")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 230)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: PuffFreeTheme.accentTeal.opacity(0.4), radius: 32, y: 10)
                }
                .scaleEffect(heroVisible ? 1 : 0.75)
                .opacity(heroVisible ? 1 : 0)
                .offset(y: heroFloat ? -7 : 7)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.65),
                    value: heroVisible
                )
                .animation(
                    .easeInOut(duration: 3.0).repeatForever(autoreverses: true),
                    value: heroFloat
                )

                // ── Social proof stats ────────────────────────────────────
                HStack(spacing: 16) {
                    WelcomeStat(value: "50K+", label: "Quit")
                    WelcomeStatDivider()
                    WelcomeStat(value: "4.9★", label: "Rating")
                    WelcomeStatDivider()
                    WelcomeStat(value: "Free", label: "to start")
                }
                .padding(.top, 22)
                .opacity(statsVisible ? 1 : 0)
                .offset(y: statsVisible ? 0 : 12)
                .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.14), value: statsVisible)

                // ── Title ─────────────────────────────────────────────────
                VStack(spacing: 5) {
                    Text("Your journey to freedom")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("starts right now")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [PuffFreeTheme.accentTeal, Color(hex: "A8E6CF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .scaleEffect(titleVisible ? 1 : 0.88)
                .opacity(titleVisible ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.24), value: titleVisible)

                // ── Name field ────────────────────────────────────────────
                VStack(alignment: .leading, spacing: 8) {
                    Text("What should we call you?")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PuffFreeTheme.textSecondary)

                    HStack(spacing: 10) {
                        Image(systemName: "person.fill")
                            .foregroundColor(PuffFreeTheme.accentTeal)
                            .frame(width: 20)
                        TextField("Your name (optional)", text: $displayName)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(hex: "1A2038"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        displayName.isEmpty
                                            ? Color.white.opacity(0.1)
                                            : PuffFreeTheme.accentTeal.opacity(0.6),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(
                                color: displayName.isEmpty ? .clear : PuffFreeTheme.accentTeal.opacity(0.2),
                                radius: 8, y: 2
                            )
                    )
                    .animation(.easeInOut(duration: 0.25), value: displayName.isEmpty)
                }
                .padding(.horizontal, 28)
                .padding(.top, 24)
                .offset(y: fieldVisible ? 0 : 18)
                .opacity(fieldVisible ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.74).delay(0.34), value: fieldVisible)

                Spacer()

                // ── CTA ───────────────────────────────────────────────────
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text(displayName.isEmpty
                             ? "Let's Begin"
                             : "Let's Go, \(displayName.split(separator: " ").first.map(String.init) ?? displayName)!")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(PuffFreeTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: PuffFreeTheme.accentTeal.opacity(0.45), radius: 16, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .scaleEffect(ctaVisible ? 1 : 0.88)
                .opacity(ctaVisible ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.48), value: ctaVisible)
            }
        }
        .onAppear {
            heroVisible  = true
            statsVisible = true
            titleVisible = true
            fieldVisible = true
            ctaVisible   = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { heroFloat = true }
        }
    }
}

// MARK: - Sub-views

private struct WelcomeStat: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(PuffFreeTheme.primaryGradient)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
    }
}

private struct WelcomeStatDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(width: 1, height: 28)
    }
}
