import SwiftUI

struct UsagePatternStepView: View {
    let nicotineType: NicotineType
    @Binding var dailyUsage: Int
    @Binding var costPerPack: Double
    @Binding var packSize: Int
    @Binding var nicotineStrength: Double
    let onNext: () -> Void

    @State private var titleVisible = false
    @State private var slidersVisible: [Bool] = [false, false, false]
    @State private var ctaVisible = false

    var body: some View {
        ZStack {
            // Ambient orbs
            FloatingOrb(color: PuffFreeTheme.warning, size: 260, xOffset: 100,
                        yRange: 22, duration: 6.2, startDelay: 0)
                .offset(y: -160)
            FloatingOrb(color: PuffFreeTheme.accentTeal, size: 180, xOffset: -90,
                        yRange: 18, duration: 7.5, startDelay: 1.0)
                .offset(y: 180)

            VStack(spacing: 0) {
                Spacer()

                // ── Heading ───────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Your Usage")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Help us personalize your plan")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                .scaleEffect(titleVisible ? 1 : 0.9)
                .opacity(titleVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.7), value: titleVisible)

                // ── Sliders ───────────────────────────────────────────────
                VStack(spacing: 14) {
                    PremiumSliderRow(
                        title: usageLabel,
                        value: Binding(
                            get: { Double(dailyUsage) },
                            set: { dailyUsage = Int($0) }
                        ),
                        range: 1...100, unit: "per day", step: 1
                    )
                    .opacity(slidersVisible[0] ? 1 : 0)
                    .offset(x: slidersVisible[0] ? 0 : 32)
                    .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.12), value: slidersVisible[0])

                    PremiumSliderRow(
                        title: "Cost per \(costLabel)",
                        value: $costPerPack,
                        range: 1...100, unit: "$", step: 0.5, isCurrency: true
                    )
                    .opacity(slidersVisible[1] ? 1 : 0)
                    .offset(x: slidersVisible[1] ? 0 : 32)
                    .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.22), value: slidersVisible[1])

                    if nicotineType == .vape {
                        PremiumSliderRow(
                            title: "Nicotine Strength",
                            value: $nicotineStrength,
                            range: 0...60, unit: "mg/mL", step: 1
                        )
                        .opacity(slidersVisible[2] ? 1 : 0)
                        .offset(x: slidersVisible[2] ? 0 : 32)
                        .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.32), value: slidersVisible[2])
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
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.42), value: ctaVisible)
            }
        }
        .onAppear {
            titleVisible = true
            ctaVisible   = true
            for i in slidersVisible.indices { slidersVisible[i] = true }
        }
    }

    private var usageLabel: String {
        switch nicotineType {
        case .vape:         return "Puffs"
        case .cigarette:    return "Cigarettes"
        case .pouch, .snus: return "Pouches"
        case .gum:          return "Pieces"
        default:            return "Uses"
        }
    }

    private var costLabel: String {
        switch nicotineType {
        case .vape:         return "pod/cartridge"
        case .cigarette:    return "pack"
        case .pouch, .snus: return "can"
        case .gum:          return "pack"
        default:            return "unit"
        }
    }
}

// MARK: - Premium slider row

struct PremiumSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    var step: Double = 1
    var isCurrency: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text(isCurrency ? String(format: "$%.2f", value) : "\(Int(value)) \(unit)")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundStyle(PuffFreeTheme.primaryGradient)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: value)
            }

            Slider(value: $value, in: range, step: step)
                .tint(PuffFreeTheme.accentTeal)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "141824"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 6, y: 2)
    }
}
