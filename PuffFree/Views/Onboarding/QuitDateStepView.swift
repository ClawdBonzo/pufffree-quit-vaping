import SwiftUI

struct QuitDateStepView: View {
    @Binding var quitDate: Date
    let onNext: () -> Void

    @State private var heroVisible    = false
    @State private var contentVisible = false
    @State private var heroFloat      = false
    @State private var ctaVisible     = false

    var body: some View {
        VStack(spacing: 0) {
            // Hero
            Image("OnboardingQuitDate")
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 130)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: PuffFreeTheme.accentTeal.opacity(0.3), radius: 20, y: 6)
                .scaleEffect(heroVisible ? 1 : 0.82)
                .opacity(heroVisible ? 1 : 0)
                .offset(y: heroFloat ? -5 : 5)
                .animation(.spring(response: 0.5, dampingFraction: 0.68), value: heroVisible)
                .animation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: heroFloat)
                .padding(.top, 24)

            VStack(spacing: 6) {
                Text("When did you quit?")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Or when do you plan to?")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .padding(.top, 16)
            .opacity(contentVisible ? 1 : 0)
            .offset(y: contentVisible ? 0 : 12)
            .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.15), value: contentVisible)

            DatePicker(
                "Quit Date",
                selection: $quitDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(PuffFreeTheme.accentTeal)
            .colorScheme(.dark)
            .padding(.horizontal, 12)
            .opacity(contentVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.4).delay(0.25), value: contentVisible)

            Spacer(minLength: 0)

            Button(action: onNext) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PuffFreeTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: PuffFreeTheme.accentTeal.opacity(0.25), radius: 10, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .scaleEffect(ctaVisible ? 1 : 0.9)
            .opacity(ctaVisible ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.38), value: ctaVisible)
        }
        .onAppear {
            heroVisible    = true
            contentVisible = true
            ctaVisible     = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                heroFloat = true
            }
        }
    }
}
