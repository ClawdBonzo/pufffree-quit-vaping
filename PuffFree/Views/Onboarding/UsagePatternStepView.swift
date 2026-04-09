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
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 6) {
                Text("Your Usage")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Help us personalize your experience")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .scaleEffect(titleVisible ? 1 : 0.9)
            .opacity(titleVisible ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.7), value: titleVisible)

            VStack(spacing: 14) {
                UsageSliderRow(
                    title: usageLabel,
                    value: Binding(get: { Double(dailyUsage) }, set: { dailyUsage = Int($0) }),
                    range: 1...100, unit: "per day", step: 1
                )
                .opacity(slidersVisible[0] ? 1 : 0)
                .offset(x: slidersVisible[0] ? 0 : 30)
                .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.12), value: slidersVisible[0])

                UsageSliderRow(
                    title: "Cost per \(costLabel)",
                    value: $costPerPack,
                    range: 1...100, unit: "$", step: 0.5, isCurrency: true
                )
                .opacity(slidersVisible[1] ? 1 : 0)
                .offset(x: slidersVisible[1] ? 0 : 30)
                .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.22), value: slidersVisible[1])

                if nicotineType == .vape {
                    UsageSliderRow(
                        title: "Nicotine Strength",
                        value: $nicotineStrength,
                        range: 0...60, unit: "mg/mL", step: 1
                    )
                    .opacity(slidersVisible[2] ? 1 : 0)
                    .offset(x: slidersVisible[2] ? 0 : 30)
                    .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.32), value: slidersVisible[2])
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
            .scaleEffect(ctaVisible ? 1 : 0.9)
            .opacity(ctaVisible ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.42), value: ctaVisible)
        }
        .onAppear {
            titleVisible = true
            ctaVisible   = true
            for i in slidersVisible.indices { slidersVisible[i] = true }
        }
    }

    private var usageLabel: String {
        switch nicotineType {
        case .vape:          return "Puffs"
        case .cigarette:     return "Cigarettes"
        case .pouch, .snus:  return "Pouches"
        case .gum:           return "Pieces"
        default:             return "Uses"
        }
    }

    private var costLabel: String {
        switch nicotineType {
        case .vape:          return "pod/cartridge"
        case .cigarette:     return "pack"
        case .pouch, .snus:  return "can"
        case .gum:           return "pack"
        default:             return "unit"
        }
    }
}

struct UsageSliderRow: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let unit: String
    var step: Double = 1
    var isCurrency: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(isCurrency ? String(format: "$%.2f", value) : "\(Int(value)) \(unit)")
                    .font(.headline)
                    .foregroundColor(PuffFreeTheme.accentTeal)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3), value: value)
            }
            Slider(value: $value, in: range, step: step)
                .tint(PuffFreeTheme.accentTeal)
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
