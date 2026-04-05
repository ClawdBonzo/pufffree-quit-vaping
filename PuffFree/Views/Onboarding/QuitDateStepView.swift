import SwiftUI

struct QuitDateStepView: View {
    @Binding var quitDate: Date
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image("OnboardingQuitDate")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text("When did you quit?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Or when do you plan to quit?")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }

            DatePicker(
                "Quit Date",
                selection: $quitDate,
                in: ...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .tint(PuffFreeTheme.accentTeal)
            .colorScheme(.dark)
            .padding(.horizontal, 16)

            Spacer()

            Button(action: onNext) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PuffFreeTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
