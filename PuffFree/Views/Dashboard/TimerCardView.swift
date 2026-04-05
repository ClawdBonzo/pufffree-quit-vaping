import SwiftUI

struct TimerCardView: View {
    let viewModel: QuitViewModel

    var body: some View {
        GlassCard {
            VStack(spacing: 16) {
                Text("Puff-Free For")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)

                HStack(spacing: 4) {
                    TimeUnitView(value: viewModel.timeComponents.days, label: "DAYS")
                    TimeSeparator()
                    TimeUnitView(value: viewModel.timeComponents.hours, label: "HRS")
                    TimeSeparator()
                    TimeUnitView(value: viewModel.timeComponents.minutes, label: "MIN")
                    TimeSeparator()
                    TimeUnitView(value: viewModel.timeComponents.seconds, label: "SEC")
                }

                // Puffs avoided
                HStack(spacing: 24) {
                    StatPill(
                        icon: "nosign",
                        value: "\(viewModel.puffsAvoided)",
                        label: "Puffs Avoided"
                    )
                    StatPill(
                        icon: "clock.fill",
                        value: viewModel.lifeRegained,
                        label: "Life Regained"
                    )
                }
            }
        }
    }
}

struct TimeUnitView: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 38, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: value)

            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(PuffFreeTheme.textTertiary)
        }
        .frame(minWidth: 60)
    }
}

struct TimeSeparator: View {
    @State private var isVisible = true

    var body: some View {
        Text(":")
            .font(.system(size: 30, weight: .bold, design: .monospaced))
            .foregroundColor(PuffFreeTheme.accentTeal)
            .opacity(isVisible ? 1 : 0.3)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                    isVisible.toggle()
                }
            }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(PuffFreeTheme.primaryGradient)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(PuffFreeTheme.textTertiary)
        }
    }
}
