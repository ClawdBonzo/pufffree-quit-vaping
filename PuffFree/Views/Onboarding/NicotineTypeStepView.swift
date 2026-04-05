import SwiftUI

struct NicotineTypeStepView: View {
    @Binding var selectedType: NicotineType
    let onNext: () -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("What do you use?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Select your primary nicotine product")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(NicotineType.allCases) { type in
                    Button {
                        selectedType = type
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 10) {
                            Image(systemName: type.icon)
                                .font(.title2)
                            Text(type.rawValue)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(selectedType == type ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            selectedType == type ?
                            AnyShapeStyle(PuffFreeTheme.primaryGradient) :
                            AnyShapeStyle(PuffFreeTheme.backgroundCard)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    selectedType == type ? Color.clear : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)

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
