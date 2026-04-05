import SwiftUI

struct CravingHistoryView: View {
    let logs: [CravingLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Cravings")
                .font(.headline)
                .foregroundColor(.white)

            if logs.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.largeTitle)
                        .foregroundStyle(PuffFreeTheme.primaryGradient)
                    Text("No cravings logged yet")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                    Text("That's a great sign! Log cravings when they happen.")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
            } else {
                ForEach(logs) { log in
                    CravingLogRow(log: log)
                }
            }
        }
    }
}

struct CravingLogRow: View {
    let log: CravingLog

    var body: some View {
        HStack(spacing: 12) {
            // Intensity indicator
            Circle()
                .fill(intensityColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: log.trigger.icon)
                        .font(.caption)
                    Text(log.trigger.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)

                Text(log.timestamp.relativeFormatted)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textTertiary)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("\(log.intensity)/10")
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)

                Image(systemName: log.didResist ? "shield.fill" : "heart.slash")
                    .font(.caption)
                    .foregroundColor(log.didResist ? PuffFreeTheme.success : PuffFreeTheme.warning)
            }
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var intensityColor: Color {
        switch log.intensity {
        case 1...3: return PuffFreeTheme.success
        case 4...6: return PuffFreeTheme.warning
        default: return PuffFreeTheme.danger
        }
    }
}
