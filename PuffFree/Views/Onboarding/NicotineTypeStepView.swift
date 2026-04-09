import SwiftUI

struct NicotineTypeStepView: View {
    @Binding var selectedType: NicotineType
    let onNext: () -> Void

    @State private var titleVisible  = false
    @State private var visibleCards: Set<Int> = []
    @State private var ctaVisible    = false

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            // Subtle ambient orbs
            FloatingOrb(color: PuffFreeTheme.accentTeal, size: 280, xOffset: -100,
                        yRange: 25, duration: 5.8, startDelay: 0)
                .offset(y: -180)
            FloatingOrb(color: Color(hex: "7C3AED"), size: 200, xOffset: 110,
                        yRange: 20, duration: 7.0, startDelay: 1.0)
                .offset(y: 160)

            VStack(spacing: 0) {
                Spacer()

                // ── Heading ───────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("What do you use?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Select your primary nicotine product")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                .scaleEffect(titleVisible ? 1 : 0.88)
                .opacity(titleVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: titleVisible)

                // ── Type grid ─────────────────────────────────────────────
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(Array(NicotineType.allCases.enumerated()), id: \.element) { idx, type in
                        let isSelected = selectedType == type
                        let isVisible  = visibleCards.contains(idx)

                        NicotineTypeCard(
                            type: type,
                            isSelected: isSelected,
                            isPopular: type == .vape
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
                                selectedType = type
                            }
                            HapticManager.selection()
                        }
                        .scaleEffect(isVisible ? 1 : 0.78)
                        .opacity(isVisible ? 1 : 0)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.68)
                                .delay(Double(idx) * 0.07 + 0.1),
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
            for idx in NicotineType.allCases.indices {
                visibleCards.insert(idx)
            }
        }
    }
}

// MARK: - Individual nicotine type card

private struct NicotineTypeCard: View {
    let type: NicotineType
    let isSelected: Bool
    let isPopular: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 10) {
                    // Icon bubble
                    ZStack {
                        Circle()
                            .fill(
                                isSelected
                                    ? PuffFreeTheme.accentTeal.opacity(0.25)
                                    : Color.white.opacity(0.06)
                            )
                            .frame(width: 52, height: 52)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)

                        Image(systemName: type.icon)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundStyle(
                                isSelected
                                    ? AnyShapeStyle(PuffFreeTheme.primaryGradient)
                                    : AnyShapeStyle(Color.white.opacity(0.7))
                            )
                            .scaleEffect(isSelected ? 1.18 : 1.0)
                            .animation(.spring(response: 0.28, dampingFraction: 0.52), value: isSelected)
                    }

                    VStack(spacing: 2) {
                        Text(type.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)

                        Text(typeSubtitle(type))
                            .font(.system(size: 10))
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                            .opacity(0.6)
                    }
                }
                .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .padding(.horizontal, 8)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                isSelected
                                    ? LinearGradient(
                                        colors: [Color(hex: "1E2D42"), Color(hex: "162635")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing)
                                    : LinearGradient(
                                        colors: [Color(hex: "141824"), Color(hex: "111620")],
                                        startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected ? PuffFreeTheme.accentTeal.opacity(0.65) : Color.white.opacity(0.07),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                    }
                )
                .shadow(
                    color: isSelected ? PuffFreeTheme.accentTeal.opacity(0.25) : .clear,
                    radius: 12, y: 4
                )
                .scaleEffect(isSelected ? 1.04 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.62), value: isSelected)

                // "Most popular" badge
                if isPopular {
                    Text("Most popular")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(PuffFreeTheme.accentTeal)
                        .clipShape(Capsule())
                        .offset(x: -4, y: 6)
                }

                // Checkmark when selected
                if isSelected {
                    ZStack {
                        Circle()
                            .fill(PuffFreeTheme.accentTeal)
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .offset(x: -8, y: 8)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func typeSubtitle(_ type: NicotineType) -> String {
        switch type {
        case .vape:      return "E-cig / Pod system"
        case .cigarette: return "Traditional smoking"
        case .pouch:     return "Nicotine pouches"
        case .gum:       return "Nicotine replacement"
        case .patch:     return "Skin patch"
        case .snus:      return "Oral smokeless"
        case .hookah:    return "Water pipe / Shisha"
        case .other:     return "Something else"
        }
    }
}
