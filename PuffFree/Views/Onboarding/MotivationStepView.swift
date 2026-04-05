import SwiftUI

struct MotivationStepView: View {
    @Binding var primaryMotivation: String
    @Binding var additionalMotivations: [String]
    let onNext: () -> Void

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("Why are you quitting?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(AppConstants.Motivations.allCases, id: \.title) { motivation in
                    let isSelected = primaryMotivation == motivation.title ||
                        additionalMotivations.contains(motivation.title)

                    Button {
                        toggleMotivation(motivation.title)
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: motivation.icon)
                                .font(.title2)
                            Text(motivation.title)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(isSelected ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            isSelected ?
                            AnyShapeStyle(PuffFreeTheme.primaryGradient) :
                            AnyShapeStyle(PuffFreeTheme.backgroundCard)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
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

    private func toggleMotivation(_ title: String) {
        if primaryMotivation == title {
            primaryMotivation = additionalMotivations.first ?? "Health"
            additionalMotivations.removeAll { $0 == title }
        } else if additionalMotivations.contains(title) {
            additionalMotivations.removeAll { $0 == title }
        } else {
            if primaryMotivation.isEmpty {
                primaryMotivation = title
            } else {
                additionalMotivations.append(title)
            }
        }
    }
}
