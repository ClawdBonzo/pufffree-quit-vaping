import Foundation
import SwiftData
import Observation

@Observable
@MainActor
class GamificationViewModel {
    var gamificationState: GamificationState?
    var quests: [Quest] = []
    var badges: [Badge] = []
    var unlockedBadges: [Badge] = []

    private let modelContext: ModelContext?

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        loadGamificationState()
        loadQuests()
        loadBadges()
    }

    // MARK: - XP & Level

    func addXP(_ amount: Int, source: String) {
        guard let state = gamificationState else { return }

        let (leveledUp, newLevel) = state.addXP(amount, from: source)

        if leveledUp, let level = newLevel {
            HapticManager.notification(.success)
            // Could trigger confetti, level-up animation, etc.
        } else {
            HapticManager.selection()
        }

        saveGamificationState()
    }

    func getCurrentLevelProgress() -> (current: Int, next: Int) {
        guard let state = gamificationState else { return (0, 0) }

        let currentLevelXP = state.currentLevel.xpRequired
        let nextLevelXP = (state.currentLevel.rawValue < PlayerLevel.legendary.rawValue) ?
            PlayerLevel(rawValue: state.currentLevel.rawValue + 1)?.xpRequired ?? currentLevelXP + 1000 :
            currentLevelXP + 1000

        let progressInLevel = state.totalXP - currentLevelXP
        let requiredForLevel = nextLevelXP - currentLevelXP

        return (progressInLevel, requiredForLevel)
    }

    func getXPPercentage() -> Double {
        let (current, next) = getCurrentLevelProgress()
        guard next > 0 else { return 0 }
        return Double(current) / Double(next)
    }

    // MARK: - Streak System

    func updateStreak(daysSinceQuit: Int) {
        guard let state = gamificationState else { return }

        let previousStreak = state.streakDays
        state.updateStreak(daysSinceQuit: daysSinceQuit)

        if state.streakDays > previousStreak {
            HapticManager.notification(.success)
            // Could trigger celebration animation
        }

        saveGamificationState()
    }

    func getStreakBonus() -> Double {
        guard let state = gamificationState else { return 1.0 }
        return state.streakMultiplier
    }

    // MARK: - Quests

    func generateDailyQuests() {
        let dailyQuestTypes: [QuestType] = [
            .smokeFreeDay,
            .checkIn,
            .resistCravings
        ]

        let today = Calendar.current.startOfDay(for: Date())

        // Remove expired quests
        quests.removeAll { quest in
            if let expiry = quest.expiresDate {
                return today > expiry
            }
            return false
        }

        // Add new quests if they don't exist
        for questType in dailyQuestTypes {
            if !quests.contains(where: { $0.type == questType && !$0.isExpired }) {
                let newQuest = Quest(type: questType)
                quests.append(newQuest)
                if let context = modelContext {
                    context.insert(newQuest)
                }
            }
        }

        saveQuests()
    }

    func completeQuest(_ quest: Quest) {
        quest.complete()

        let xpGain = Int(Double(quest.xpReward) * getStreakBonus())
        addXP(xpGain, source: quest.type.rawValue)

        gamificationState?.totalQuestsCompleted += 1

        HapticManager.notification(.success)
        saveQuests()
        saveGamificationState()
    }

    func getActiveQuests() -> [Quest] {
        return quests.filter { !$0.isCompleted && !$0.isExpired }
    }

    func getCompletedQuests() -> [Quest] {
        return quests.filter { $0.isCompleted }
    }

    // MARK: - Badges

    func checkAndUnlockBadges(profile: UserProfile?) {
        guard let profile = profile, let state = gamificationState else { return }

        for badge in badges where !badge.isUnlocked {
            if shouldUnlockBadge(badge, for: profile, state: state) {
                badge.unlock()
                state.totalBadgesUnlocked += 1

                unlockedBadges.append(badge)
                HapticManager.notification(.warning) // Special haptic for badge unlock
                saveGamificationState()
            }
        }

        saveBadges()
    }

    private func shouldUnlockBadge(_ badge: Badge, for profile: UserProfile, state: GamificationState) -> Bool {
        switch badge.requirement {
        case .daysSinceQuit(let days):
            return profile.daysSinceQuit >= days

        case .cravingsResisted(let count):
            return profile.totalCravingsResisted >= count

        case .breathworkSessions:
            // TODO: Track breathwork sessions — badge locked until implemented
            return false

        case .journalEntries:
            // TODO: Track journal entries — badge locked until implemented
            return false

        case .motivationCount(let count):
            return profile.primaryMotivation.isEmpty ? 1 >= count : (profile.additionalMotivations.count + 1) >= count

        case .streakDays(let days):
            return state.streakDays >= days

        case .moneySaved(let amount):
            return profile.moneySaved >= amount
        }
    }

    func getUnlockedBadges() -> [Badge] {
        return badges.filter { $0.isUnlocked }
    }

    func getLockedBadges() -> [Badge] {
        return badges.filter { !$0.isUnlocked }
    }

    // MARK: - Persistence

    private func loadGamificationState() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<GamificationState>()
        do {
            let states = try context.fetch(descriptor)
            if let state = states.first {
                self.gamificationState = state
            } else {
                let newState = GamificationState()
                context.insert(newState)
                self.gamificationState = newState
                try context.save()
            }
        } catch {
            print("Failed to load gamification state: \(error)")
            self.gamificationState = GamificationState()
        }
    }

    private func loadQuests() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Quest>()
        do {
            self.quests = try context.fetch(descriptor)
        } catch {
            print("Failed to load quests: \(error)")
            self.quests = []
        }
    }

    private func loadBadges() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Badge>()
        do {
            let loadedBadges = try context.fetch(descriptor)
            if loadedBadges.isEmpty {
                // Initialize all badges
                for badgeType in BadgeType.allCases {
                    let badge = Badge(type: badgeType)
                    self.badges.append(badge)
                    context.insert(badge)
                }
                try context.save()
            } else {
                self.badges = loadedBadges
            }
        } catch {
            print("Failed to load badges: \(error)")
            self.badges = BadgeType.allCases.map { Badge(type: $0) }
        }
    }

    private func saveGamificationState() {
        guard let context = modelContext, let state = gamificationState else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save gamification state: \(error)")
        }
    }

    private func saveQuests() {
        guard let context = modelContext else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save quests: \(error)")
        }
    }

    private func saveBadges() {
        guard let context = modelContext else { return }

        do {
            try context.save()
        } catch {
            print("Failed to save badges: \(error)")
        }
    }
}
