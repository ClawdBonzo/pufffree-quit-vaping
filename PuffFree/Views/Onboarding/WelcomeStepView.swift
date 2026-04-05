import SwiftUI

struct WelcomeStepView: View {
    @Binding var displayName: String
    let onNext: () -> Void

    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "lungs.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(PuffFreeTheme.primaryGradient)
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)

                Text("PuffFree")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Your journey to freedom starts here")
                    .font(.title3)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .offset(y: animateIn ? 0 : 20)

            VStack(alignment: .leading, spacing: 12) {
                Text("What should we call you?")
                    .font(.headline)
                    .foregroundColor(.white)

                TextField("Your name (optional)", text: $displayName)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .opacity(animateIn ? 1 : 0)

            Spacer()

            Button(action: onNext) {
                Text("Let's Begin")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PuffFreeTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .opacity(animateIn ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animateIn = true
            }
        }
    }
}
