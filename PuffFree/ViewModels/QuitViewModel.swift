import Foundation
import SwiftUI
import SwiftData
import Combine

@Observable @MainActor
final class QuitViewModel {
    var timeComponents: (days: Int, hours: Int, minutes: Int, seconds: Int) = (0, 0, 0, 0)
    var moneySaved: Double = 0
    var puffsAvoided: Int = 0
    var lifeRegained: String = "0h 0m"
    var currentStreak: Int = 0
    var nextMilestone: MilestoneType?
    var progressToNextMilestone: Double = 0

    private var timer: Timer?
    private var profile: UserProfile?

    func startTracking(profile: UserProfile) {
        self.profile = profile
        updateStats()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateStats()
        }
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
    }

    private func updateStats() {
        guard let profile else { return }
        timeComponents = profile.timeSinceQuit
        moneySaved = profile.moneySaved
        puffsAvoided = profile.puffsAvoided
        lifeRegained = profile.lifeRegained
        currentStreak = profile.daysSinceQuit

        let hoursSinceQuit = profile.hoursSinceQuit
        let allMilestones = MilestoneType.allCases
        nextMilestone = allMilestones.first { $0.hoursRequired > hoursSinceQuit }

        if let next = nextMilestone {
            let previousHours = allMilestones
                .last { $0.hoursRequired <= hoursSinceQuit }?.hoursRequired ?? 0
            let range = Double(next.hoursRequired - previousHours)
            let progress = Double(hoursSinceQuit - previousHours)
            progressToNextMilestone = min(max(progress / range, 0), 1)
        } else {
            progressToNextMilestone = 1.0
        }
    }

    func checkForNewMilestones(
        profile: UserProfile,
        existingRecords: [MilestoneRecord],
        modelContext: ModelContext
    ) -> MilestoneType? {
        let hoursSinceQuit = profile.hoursSinceQuit
        let unlockedTypes = Set(existingRecords.map(\.milestoneType))

        for milestone in MilestoneType.allCases {
            if hoursSinceQuit >= milestone.hoursRequired && !unlockedTypes.contains(milestone) {
                let record = MilestoneRecord(milestoneType: milestone, isUnlocked: true)
                modelContext.insert(record)

                if existingRecords.filter(\.celebrationShown).count < MilestoneType.allCases.count {
                    return milestone
                }
            }
        }

        return nil
    }
}
