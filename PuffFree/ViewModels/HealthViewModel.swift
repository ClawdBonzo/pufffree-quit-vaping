import Foundation
import SwiftUI

@Observable
final class HealthViewModel {
    var milestones: [HealthMilestone] = HealthMilestone.allMilestones
    var completedCount: Int = 0
    var nextUpcoming: HealthMilestone?

    struct HealthMilestone: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let hoursRequired: Int
        let icon: String
        let color: Color
        var isCompleted: Bool = false
        var progress: Double = 0

        var timeLabel: String {
            let hours = hoursRequired
            if hours < 24 {
                return "\(hours) hour\(hours == 1 ? "" : "s")"
            }
            let days = hours / 24
            if days < 30 {
                return "\(days) day\(days == 1 ? "" : "s")"
            }
            let months = days / 30
            if months < 12 {
                return "\(months) month\(months == 1 ? "" : "s")"
            }
            let years = months / 12
            return "\(years) year\(years == 1 ? "" : "s")"
        }

        static let allMilestones: [HealthMilestone] = [
            HealthMilestone(
                title: "Heart Rate Normalizes",
                description: "Your heart rate and blood pressure begin to drop back to normal levels.",
                hoursRequired: 1,
                icon: "heart.fill",
                color: .red
            ),
            HealthMilestone(
                title: "Blood Oxygen Improves",
                description: "Carbon monoxide levels in your blood drop. Oxygen levels return to normal.",
                hoursRequired: 8,
                icon: "lungs.fill",
                color: .blue
            ),
            HealthMilestone(
                title: "Nicotine Withdrawal Peaks",
                description: "Nicotine is being eliminated from your body. Stay strong through the peak.",
                hoursRequired: 24,
                icon: "bolt.fill",
                color: .orange
            ),
            HealthMilestone(
                title: "Taste & Smell Return",
                description: "Nerve endings start regenerating. Food tastes better, scents are richer.",
                hoursRequired: 48,
                icon: "nose",
                color: .purple
            ),
            HealthMilestone(
                title: "Nicotine-Free Body",
                description: "Nicotine is completely eliminated from your body. The chemical dependency is broken.",
                hoursRequired: 72,
                icon: "sparkles",
                color: .yellow
            ),
            HealthMilestone(
                title: "Breathing Improves",
                description: "Bronchial tubes are relaxing. Breathing becomes noticeably easier.",
                hoursRequired: 168,
                icon: "wind",
                color: .teal
            ),
            HealthMilestone(
                title: "Circulation Restored",
                description: "Blood circulation has significantly improved throughout your body.",
                hoursRequired: 336,
                icon: "arrow.triangle.2.circlepath",
                color: .pink
            ),
            HealthMilestone(
                title: "Lung Function Up 30%",
                description: "Lung function increases up to 30%. Coughing and shortness of breath decrease.",
                hoursRequired: 730,
                icon: "lungs.fill",
                color: .green
            ),
            HealthMilestone(
                title: "Immune System Recovery",
                description: "Your body's ability to fight infections has dramatically improved.",
                hoursRequired: 2190,
                icon: "shield.fill",
                color: .indigo
            ),
            HealthMilestone(
                title: "Lung Cilia Regrown",
                description: "The tiny hair-like structures in your lungs have fully regrown, clearing mucus effectively.",
                hoursRequired: 4380,
                icon: "leaf.fill",
                color: .mint
            ),
            HealthMilestone(
                title: "Heart Disease Risk Halved",
                description: "Your risk of coronary heart disease is now half that of a continuing smoker.",
                hoursRequired: 8760,
                icon: "heart.circle.fill",
                color: .red
            ),
            HealthMilestone(
                title: "Stroke Risk Normalized",
                description: "Your stroke risk has dropped to that of a non-smoker.",
                hoursRequired: 43800,
                icon: "brain.head.profile",
                color: .cyan
            )
        ]
    }

    func update(hoursSinceQuit: Int) {
        milestones = HealthMilestone.allMilestones.map { milestone in
            var m = milestone
            if hoursSinceQuit >= milestone.hoursRequired {
                m.isCompleted = true
                m.progress = 1.0
            } else {
                let allSorted = HealthMilestone.allMilestones
                let prevHours = allSorted
                    .last { $0.hoursRequired < milestone.hoursRequired }?.hoursRequired ?? 0
                let range = Double(milestone.hoursRequired - prevHours)
                let elapsed = Double(max(hoursSinceQuit - prevHours, 0))
                m.progress = min(elapsed / max(range, 1), 1.0)
            }
            return m
        }

        completedCount = milestones.filter(\.isCompleted).count
        nextUpcoming = milestones.first { !$0.isCompleted }
    }
}
