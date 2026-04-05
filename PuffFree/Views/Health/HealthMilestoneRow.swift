import SwiftUI

struct HealthMilestoneRow: View {
    let milestone: HealthViewModel.HealthMilestone
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline connector
            VStack(spacing: 0) {
                Circle()
                    .fill(milestone.isCompleted ? milestone.color : Color.white.opacity(0.2))
                    .frame(width: 14, height: 14)
                    .overlay(
                        Circle()
                            .fill(milestone.isCompleted ? milestone.color.opacity(0.3) : .clear)
                            .frame(width: 24, height: 24)
                    )

                if !isLast {
                    Rectangle()
                        .fill(
                            milestone.isCompleted ?
                            milestone.color.opacity(0.4) :
                            Color.white.opacity(0.1)
                        )
                        .frame(width: 2)
                }
            }
            .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: milestone.icon)
                        .font(.body)
                        .foregroundColor(milestone.isCompleted ? milestone.color : .white.opacity(0.4))

                    Text(milestone.title)
                        .font(.headline)
                        .foregroundColor(milestone.isCompleted ? .white : .white.opacity(0.5))
                }

                Text(milestone.description)
                    .font(.caption)
                    .foregroundColor(milestone.isCompleted ? PuffFreeTheme.textSecondary : PuffFreeTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Text(milestone.timeLabel)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(milestone.isCompleted ? milestone.color : .white.opacity(0.3))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            (milestone.isCompleted ? milestone.color : Color.white)
                                .opacity(0.1)
                        )
                        .clipShape(Capsule())

                    if milestone.isCompleted {
                        Text("Completed")
                            .font(.caption2)
                            .foregroundColor(PuffFreeTheme.success)
                    } else if milestone.progress > 0 {
                        ProgressView(value: milestone.progress)
                            .tint(milestone.color)
                            .frame(maxWidth: 80)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
}
