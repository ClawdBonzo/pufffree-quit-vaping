import SwiftUI

struct MotivationStepView: View {
    @Binding var primaryMotivation: String
    @Binding var additionalMotivations: [String]
    let onNext: () -> Void

    @State private var titleVisible  = false
    @State private var visibleCards: Set<Int> = []
    @State private var ctaVisible    = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            // Ambient orbs
            FloatingOrb(color: PuffFreeTheme.success, size: 300, xOffset: 110,
                        yRange: 28, duration: 6.0, startDelay: 0)
                .offset(y: -160)
            FloatingOrb(color: PuffFreeTheme.accentTeal, size: 220, xOffset: -90,
                        yRange: 22, duration: 7.5, startDelay: 1.3)
                .offset(y: 180)

            VStack(spacing: 0) {
                Spacer()

                // ── Heading ───────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Why are you quitting?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Your reasons make you stronger")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                .scaleEffect(titleVisible ? 1 : 0.88)
                .opacity(titleVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: titleVisible)

                // ── Motivation grid ───────────────────────────────────────
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(AppConstants.Motivations.allCases.enumerated()), id: \.element.title) { idx, motivation in
                        let isSelected = primaryMotivation == motivation.title
                            || additionalMotivations.contains(motivation.title)
                        let isVisible  = visibleCards.contains(idx)

                        MotivationCard(
                            motivation: motivation,
                            isSelected: isSelected
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
                                toggleMotivation(motivation.title)
                            }
                            HapticManager.selection()
                        }
                        .scaleEffect(isVisible ? 1 : 0.78)
                        .opacity(isVisible ? 1 : 0)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.68)
                                .delay(Double(idx) * 0.06 + 0.1),
                            value: isVisible
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Spacer()

                // ── CTA ───────────────────────────────────────────────────
                Button(action: onNext) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(PuffFreeTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: PuffFreeTheme.accentTeal.opacity(0.4), radius: 14, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .scaleEffect(ctaVisible ? 1 : 0.88)
                .opacity(ctaVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.45), value: ctaVisible)
            }
        }
        .onAppear {
            titleVisible = true
            ctaVisible   = true
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

// MARK: - Motivation card

private struct MotivationCard: View {
    let motivation: AppConstants.Motivations
    let isSelected: Bool
    let action: () -> Void

    // Per-motivation accent colors for selected glow
    private var accentColor: Color {
        switch motivation {
        case .health:     return Color(hex: "34D399")
        case .money:      return Color(hex: "FBBF24")
        case .family:     return Color(hex: "F472B6")
        case .fitness:    return Color(hex: "60A5FA")
        case .appearance: return Color(hex: "A78BFA")
        case .freedom:    return Color(hex: "2DD4BF")
        case .smell:      return Color(hex: "86EFAC")
        case .energy:     return Color(hex: "FCD34D")
        }
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 10) {
                    // Icon bubble
                    ZStack {
                        Circle()
                            .fill(
                                isSelected
                                    ? accentColor.opacity(0.22)
                                    : Color.white.opacity(0.06)
                            )
                            .frame(width: 52, height: 52)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                        Image(systemName: motivation.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(isSelected ? accentColor : .white.opacity(0.7))
                            .scaleEffect(isSelected ? 1.18 : 1.0)
                            .animation(.spring(response: 0.28, dampingFraction: 0.52), value: isSelected)
                    }

                    Text(motivation.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                isSelected
                                    ? LinearGradient(
                                        colors: [Color(hex: "1A2038"),
                                                 accentColor.opacity(0.08)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                                    : LinearGradient(
                                        colors: [Color(hex: "141824"), Color(hex: "111620")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
                            )
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected ? accentColor.opacity(0.6) : Color.white.opacity(0.07),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    }
                )
                .shadow(
                    color: isSelected ? accentColor.opacity(0.22) : .clear,
                    radius: 12, y: 4
                )
                .scaleEffect(isSelected ? 1.04 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isSelected)

                // Checkmark badge
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(accentColor)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .offset(x: -8, y: 8)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
