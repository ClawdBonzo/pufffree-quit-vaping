import SwiftUI

struct MotivationStepView: View {
    @Binding var primaryMotivation: String
    @Binding var additionalMotivations: [String]
    let onNext: () -> Void

    @State private var titleVisible  = false
    @State private var visibleCards: Set<Int> = []

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 6) {
                Text("Why are you quitting?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Select all that apply")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .scaleEffect(titleVisible ? 1 : 0.9)
            .opacity(titleVisible ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.7), value: titleVisible)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(AppConstants.Motivations.allCases.enumerated()), id: \.element.title) { idx, motivation in
                    let isSelected = primaryMotivation == motivation.title ||
                        additionalMotivations.contains(motivation.title)
                    let isVisible = visibleCards.contains(idx)

                    Button {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.6)) {
                            toggleMotivation(motivation.title)
                        }
                        HapticManager.selection()
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: motivation.icon)
                                .font(.title2)
                                .scaleEffect(isSelected ? 1.15 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.55), value: isSelected)
                            Text(motivation.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(isSelected ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            isSelected
                                ? AnyShapeStyle(PuffFreeTheme.primaryGradient)
                                : AnyShapeStyle(PuffFreeTheme.backgroundCard)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(
                            color: isSelected ? PuffFreeTheme.accentTeal.opacity(0.4) : .clear,
                            radius: 10, y: 4
                        )
                        .scaleEffect(isSelected ? 1.03 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(isVisible ? 1 : 0.8)
                    .opacity(isVisible ? 1 : 0)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.68).delay(Double(idx) * 0.06 + 0.12),
                        value: isVisible
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)

            Spacer()

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
        }
        .onAppear {
            titleVisible = true
            for idx in AppConstants.Motivations.allCases.indices {
                visibleCards.insert(idx)
            }
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
