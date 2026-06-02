import Foundation
import SwiftUI
import SwiftData

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

        // Only assign when the value actually changed. With @Observable, every
        // property set notifies observers even if the value is identical, which
        // would re-render any view reading it on every 1-second tick. Gating on
        // change keeps the per-second redraw scoped to what truly moved.
        let newComponents = profile.timeSinceQuit
        if newComponents != timeComponents { timeComponents = newComponents }

        let newMoney = profile.moneySaved
        if newMoney != moneySaved { moneySaved = newMoney }

        let newPuffs = profile.puffsAvoided
        if newPuffs != puffsAvoided { puffsAvoided = newPuffs }

        let newLife = profile.lifeRegained
        if newLife != lifeRegained { lifeRegained = newLife }

        let newStreak = profile.daysSinceQuit
        if newStreak != currentStreak { currentStreak = newStreak }

        let hoursSinceQuit = profile.hoursSinceQuit
        let allMilestones = MilestoneType.allCases
        let newNext = allMilestones.first { $0.hoursRequired > hoursSinceQuit }
        if newNext != nextMilestone { nextMilestone = newNext }

        let newProgress: Double
        if let next = newNext {
            let previousHours = allMilestones
                .last { $0.hoursRequired <= hoursSinceQuit }?.hoursRequired ?? 0
            let range = Double(next.hoursRequired - previousHours)
            let progress = Double(hoursSinceQuit - previousHours)
            newProgress = min(max(progress / range, 0), 1)
        } else {
            newProgress = 1.0
        }
        if newProgress != progressToNextMilestone { progressToNextMilestone = newProgress }
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
