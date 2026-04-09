import SwiftUI

struct WelcomeStepView: View {
    @Binding var displayName: String
    let onNext: () -> Void

    @State private var heroVisible  = false
    @State private var titleVisible = false
    @State private var fieldVisible = false
    @State private var ctaVisible   = false
    @State private var heroFloat    = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero image — NO duplicate "PuffFree" text below it
            Image("OnboardingWelcome")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 210)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: PuffFreeTheme.accentTeal.opacity(0.35), radius: 24, y: 8)
                .scaleEffect(heroVisible ? 1 : 0.78)
                .opacity(heroVisible ? 1 : 0)
                .offset(y: heroFloat ? -6 : 6)
                .animation(
                    .spring(response: 0.55, dampingFraction: 0.68),
                    value: heroVisible
                )
                .animation(
                    .easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                    value: heroFloat
                )

            VStack(spacing: 6) {
                Text("Your journey to freedom")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("starts right now")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [PuffFreeTheme.accentTeal, Color(hex: "A8E6CF")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .scaleEffect(titleVisible ? 1 : 0.88)
            .opacity(titleVisible ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.18), value: titleVisible)

            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("What should we call you?")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PuffFreeTheme.textSecondary)

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(PuffFreeTheme.accentTeal)
                        .frame(width: 20)
                    TextField("Your name (optional)", text: $displayName)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                }
                .padding(14)
                .background(PuffFreeTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(displayName.isEmpty ? Color.white.opacity(0.08) : PuffFreeTheme.accentTeal.opacity(0.5), lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: displayName.isEmpty)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .offset(y: fieldVisible ? 0 : 16)
            .opacity(fieldVisible ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.75).delay(0.32), value: fieldVisible)

            Spacer()

            // CTA
            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text(displayName.isEmpty ? "Let's Begin" : "Let's Go, \(displayName.split(separator: " ").first.map(String.init) ?? displayName)!")
                        .font(.headline)
                        .foregroundColor(.black)
                    Image(systemName: "arrow.right")
                        .font(.headline)
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(PuffFreeTheme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: PuffFreeTheme.accentTeal.opacity(0.3), radius: 12, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .scaleEffect(ctaVisible ? 1 : 0.9)
            .opacity(ctaVisible ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.46), value: ctaVisible)
        }
        .onAppear {
            heroVisible  = true
            titleVisible = true
            fieldVisible = true
            ctaVisible   = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                heroFloat = true
            }
        }
    }
}
