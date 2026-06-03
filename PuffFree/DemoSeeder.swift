#if DEBUG
import Foundation
import SwiftData

/// DEBUG-only demo data for App Store screenshots.
/// Activated by launching the app with the `-SeedDemoData` argument:
///   xcrun simctl launch <udid> com.clawdbonzo.PuffFree -SeedDemoData
/// Seeds aspirational, realistic data (NOT empty states) and marks onboarding complete.
enum DemoSeeder {
    static var isActive: Bool {
        ProcessInfo.processInfo.arguments.contains("-SeedDemoData")
    }

    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        guard isActive else { return }

        // Start clean so re-runs are deterministic.
        try? context.delete(model: UserProfile.self)
        try? context.delete(model: CravingLog.self)
        try? context.delete(model: JournalEntry.self)
        try? context.delete(model: DailyCheckIn.self)
        try? context.delete(model: MilestoneRecord.self)
        try? context.delete(model: GamificationState.self)
        try? context.delete(model: Quest.self)

        let cal = Calendar.current
        let now = Date()
        let quitDate = cal.date(byAdding: .day, value: -78, to: now) ?? now

        let profile = UserProfile(
            displayName: "Alex",
            quitDate: quitDate,
            nicotineType: .vape,
            dailyUsageCount: 10,
            costPerPack: 1.20,
            packSize: 1,
            nicotineStrength: 5.0,
            primaryMotivation: "Health",
            additionalMotivations: ["Money", "Fitness", "Family"],
            notificationsEnabled: true
        )
        profile.longestStreakDays = 78
        profile.totalCravingsResisted = 63
        context.insert(profile)

        // Milestones unlocked up to current elapsed time.
        let hours = profile.hoursSinceQuit
        for milestone in MilestoneType.allCases {
            context.insert(MilestoneRecord(milestoneType: milestone,
                                           isUnlocked: milestone.hoursRequired <= hours))
        }

        // Cravings — rich history, mostly resisted (high resist rate), varied triggers.
        let triggers: [CravingTrigger] = [.stress, .afterMeal, .coffee, .boredom, .social,
                                          .anxiety, .habit, .driving, .morning, .stress]
        let strategies = ["Deep Breathing", "Go for a Walk", "Drink Water",
                          "Chew Gum", "Meditate", "Call a Friend"]
        for i in 0..<16 {
            let resisted = i % 8 != 0   // ~87% resist rate
            let log = CravingLog(
                intensity: [3, 4, 5, 6, 7, 8].randomElement() ?? 5,
                trigger: triggers[i % triggers.count],
                copingStrategy: strategies[i % strategies.count],
                didResist: resisted,
                durationSeconds: [90, 120, 180, 240, 300].randomElement() ?? 180,
                notes: ""
            )
            log.timestamp = cal.date(byAdding: .hour, value: -(i * 11 + 2), to: now) ?? now
            context.insert(log)
        }

        // Journal entries.
        let entries: [(String, String, Mood, [String])] = [
            ("Two months free!", "Hit 60 days today. My lungs feel completely different on my morning runs.", .great, ["milestone", "fitness"]),
            ("Tough afternoon", "Big craving after a stressful meeting, but I went for a walk and it passed in minutes.", .good, ["stress", "win"]),
            ("Saving up", "Saved enough to book a weekend trip. Wild how fast it adds up.", .great, ["money"]),
            ("Sleeping better", "Slept through the night for the first time in ages. Energy is way up.", .good, ["health"])
        ]
        for (i, e) in entries.enumerated() {
            let entry = JournalEntry(title: e.0, body: e.1, mood: e.2, tags: e.3)
            entry.timestamp = cal.date(byAdding: .day, value: -(i * 3 + 1), to: now) ?? now
            context.insert(entry)
        }

        // Daily check-ins (recent, trending positive).
        for i in 0..<6 {
            let checkIn = DailyCheckIn(
                mood: i < 4 ? .great : .good,
                cravingLevel: max(1, 4 - i),
                energyLevel: min(10, 6 + i),
                sleepQuality: min(10, 7 + (i % 3)),
                exercised: i % 2 == 0,
                hydratedWell: true,
                proudMoment: i == 0 ? "Resisted a craving at the bar" : "",
                gratitude: i == 0 ? "Grateful for clear mornings" : ""
            )
            checkIn.date = cal.date(byAdding: .day, value: -i, to: now) ?? now
            context.insert(checkIn)
        }

        // Gamification — strong, aspirational progression.
        let gam = GamificationState()
        gam.totalXP = 2680
        gam.currentLevel = .smoke_free
        gam.levelProgress = gam.totalXP - PlayerLevel.smoke_free.xpRequired
        gam.streakDays = 78
        gam.bestStreak = 78
        gam.streakMultiplier = 2.5
        gam.lastActiveDate = now
        gam.totalQuestsCompleted = 42
        gam.totalBadgesUnlocked = 7
        gam.streakShields = 3
        context.insert(gam)

        let questTypes: [QuestType] = [.smokeFreeDay, .checkIn, .resistCravings, .journalEntry]
        for (i, qt) in questTypes.enumerated() {
            let quest = Quest(type: qt)
            if i < 2 {
                quest.progress = quest.targetProgress
                quest.complete()
            }
            context.insert(quest)
        }

        // NOTE: Badge is intentionally NOT seeded/persisted — its BadgeRequirement
        // (enum with associated values) is not SwiftData-storable.

        try? context.save()

        // Skip onboarding so screenshots land directly on the main app.
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
#endif
