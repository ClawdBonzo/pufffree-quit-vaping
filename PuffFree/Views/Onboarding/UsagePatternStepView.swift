import SwiftUI

struct UsagePatternStepView: View {
    let nicotineType: NicotineType
    @Binding var dailyUsage: Int
    @Binding var costPerPack: Double
    @Binding var packSize: Int
    @Binding var nicotineStrength: Double
    let onNext: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 20)

                VStack(spacing: 8) {
                    Text("Your Usage")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Help us personalize your experience")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }

                VStack(spacing: 20) {
                    // Daily usage
                    UsageSliderRow(
                        title: usageLabel,
                        value: Binding(
                            get: { Double(dailyUsage) },
                            set: { dailyUsage = Int($0) }
                        ),
                        range: 1...100,
                        unit: "per day",
                        step: 1
                    )

                    // Cost
                    UsageSliderRow(
                        title: "Cost per \(costLabel)",
                        value: $costPerPack,
                        range: 1...100,
                        unit: "$",
                        step: 0.5,
                        isCurrency: true
                    )

                    // Nicotine strength for vape
                    if nicotineType == .vape {
                        UsageSliderRow(
                            title: "Nicotine Strength",
                            value: $nicotineStrength,
                            range: 0...60,
                            unit: "mg/mL",
                            step: 1
                        )
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
        .scrollIndicators(.hidden)
    }

    private var usageLabel: String {
        switch nicotineType {
        case .vape: return "Puffs"
        case .cigarette: return "Cigarettes"
        case .pouch, .snus: return "Pouches"
        case .gum: return "Pieces"
        default: return "Uses"
        }
    }

    private var costLabel: String {
        switch nicotineType {
        case .vape: return "pod/cartridge"
        case .cigarette: return "pack"
        case .pouch, .snus: return "can"
        case .gum: return "pack"
        default: return "unit"
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
            }

            Slider(value: $value, in: range, step: step)
                .tint(PuffFreeTheme.accentTeal)
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
