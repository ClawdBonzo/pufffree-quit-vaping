import SwiftUI

struct CravingHistoryView: View {
    let logs: [CravingLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Cravings")
                .font(.headline)
                .foregroundColor(.white)

            if logs.isEmpty {
                MotivationalEmptyState(
                    icon: "checkmark.shield.fill",
                    title: "No cravings logged yet",
                    message: "That's a great sign! When a craving hits, log it here — you'll see how often you win."
                )
            } else {
                // Lazily render and cap to the most recent entries — the history
                // can grow unbounded, and eagerly laying out every row is wasteful.
                LazyVStack(spacing: 12) {
                    ForEach(logs.prefix(50)) { log in
                        CravingLogRow(log: log)
                    }
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
                    Text(log.trigger.displayName)
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
