import Foundation
import SwiftData

// MARK: - XP & Level System

enum PlayerLevel: Int, Codable, CaseIterable {
    case addicted = 0
    case aware = 1
    case cutting = 2
    case moderate = 3
    case controlled = 4
    case smoke_free = 5
    case breathing_easy = 6
    case phoenix_rising = 7
    case legendary = 8

    var title: String {
        switch self {
        case .addicted: return "Addicted"
        case .aware: return "Aware"
        case .cutting: return "Cutting Down"
        case .moderate: return "Moderate Use"
        case .controlled: return "Controlled"
        case .smoke_free: return "Smoke-Free"
        case .breathing_easy: return "Breathing Easy"
        case .phoenix_rising: return "Phoenix Rising"
        case .legendary: return "Legend"
        }
    }

    var xpRequired: Int {
        switch self {
        case .addicted: return 0
        case .aware: return 250
        case .cutting: return 600
        case .moderate: return 1100
        case .controlled: return 1700
        case .smoke_free: return 2500
        case .breathing_easy: return 3500
        case .phoenix_rising: return 5000
        case .legendary: return 7500
        }
    }

    var icon: String {
        switch self {
        case .addicted: return "xmark.circle.fill"
        case .aware: return "lightbulb.fill"
        case .cutting: return "arrow.down.circle.fill"
        case .moderate: return "hand.raised.circle.fill"
        case .controlled: return "checkmark.circle.fill"
        case .smoke_free: return "wind.circle.fill"
        case .breathing_easy: return "lungs.fill"
        case .phoenix_rising: return "flame.fill"
        case .legendary: return "crown.fill"
        }
    }

    var color: String {
        switch self {
        case .addicted: return "FF4444"
        case .aware: return "FF9800"
        case .cutting: return "FFC107"
        case .moderate: return "8BC34A"
        case .controlled: return "4CAF50"
        case .smoke_free: return "2E7D32"
        case .breathing_easy: return "00897B"
        case .phoenix_rising: return "FF6F00"
        case .legendary: return "FFD700"
        }
    }
}

@Model
final class GamificationState {
    var totalXP: Int
    var currentLevel: PlayerLevel
    var levelProgress: Int // XP towards next level
    var streakDays: Int
    var bestStreak: Int
    var streakMultiplier: Double
    var lastActiveDate: Date
    var totalQuestsCompleted: Int
    var totalBadgesUnlocked: Int
    var createdAt: Date

    init() {
        self.totalXP = 0
        self.currentLevel = .addicted
        self.levelProgress = 0
        self.streakDays = 0
        self.bestStreak = 0
        self.streakMultiplier = 1.0
        self.lastActiveDate = Date()
        self.totalQuestsCompleted = 0
        self.totalBadgesUnlocked = 0
        self.createdAt = Date()
    }

    func addXP(_ amount: Int, from source: String) -> (leveledUp: Bool, newLevel: PlayerLevel?) {
        totalXP += amount

        var leveledUp = false
        var newLevel: PlayerLevel? = nil

        // Check for level up
        let nextLevel = PlayerLevel(rawValue: currentLevel.rawValue + 1)
        if let next = nextLevel, totalXP >= next.xpRequired {
            currentLevel = next
            levelProgress = totalXP - next.xpRequired
            leveledUp = true
            newLevel = next
        } else {
            levelProgress = totalXP - currentLevel.xpRequired
        }

        return (leveledUp, newLevel)
    }

    func updateStreak(daysSinceQuit: Int) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: lastActiveDate)

        let daysDiff = calendar.dateComponents([.day], from: lastActive, to: today).day ?? 0

        if daysDiff == 0 {
            // Already counted today
            return
        } else if daysDiff == 1 {
            // Continued streak
            streakDays += 1
            streakMultiplier = 1.0 + (Double(streakDays) * 0.1)
            if streakDays > bestStreak {
                bestStreak = streakDays
            }
        } else {
            // Streak broken, reset
            streakDays = 1
            streakMultiplier = 1.0
        }

        lastActiveDate = Date()
    }

    func resetStreak() {
        streakDays = 0
        streakMultiplier = 1.0
    }
}

// MARK: - Quests

enum QuestType: String, Codable, CaseIterable {
    case smokeFreeDay = "Smoke-Free Day"
    case resistCravings = "Resist 3 Cravings"
    case logBreathwork = "Log Breathwork"
    case journalEntry = "Journal Entry"
    case checkIn = "Daily Check-In"
    case streak7 = "7-Day Streak"
    case streak30 = "30-Day Streak"
    case upgradeMotivation = "Add Motivation"

    var description: String {
        switch self {
        case .smokeFreeDay: return "Complete a full smoke-free day"
        case .resistCravings: return "Resist and log 3 cravings"
        case .logBreathwork: return "Do a breathing exercise"
        case .journalEntry: return "Write a journal entry"
        case .checkIn: return "Complete daily check-in"
        case .streak7: return "Achieve 7-day streak"
        case .streak30: return "Achieve 30-day streak"
        case .upgradeMotivation: return "Add a motivation"
        }
    }

    var xpReward: Int {
        switch self {
        case .smokeFreeDay: return 50
        case .resistCravings: return 75
        case .logBreathwork: return 40
        case .journalEntry: return 60
        case .checkIn: return 30
        case .streak7: return 150
        case .streak30: return 500
        case .upgradeMotivation: return 25
        }
    }

    var icon: String {
        switch self {
        case .smokeFreeDay: return "calendar.circle.fill"
        case .resistCravings: return "hand.raised.fill"
        case .logBreathwork: return "wind.circle.fill"
        case .journalEntry: return "doc.text.fill"
        case .checkIn: return "checkmark.circle.fill"
        case .streak7: return "flame.fill"
        case .streak30: return "flame.fill"
        case .upgradeMotivation: return "star.fill"
        }
    }

    var frequency: QuestFrequency {
        switch self {
        case .smokeFreeDay, .checkIn, .resistCravings: return .daily
        case .logBreathwork, .journalEntry: return .daily
        case .streak7, .streak30, .upgradeMotivation: return .onetime
        }
    }
}

enum QuestFrequency: String, Codable {
    case daily
    case weekly
    case onetime
}

@Model
final class Quest {
    var id: String
    var type: QuestType
    var questDescription: String
    var xpReward: Int
    var isCompleted: Bool
    var completedDate: Date?
    var createdDate: Date
    var expiresDate: Date?
    var progress: Int
    var targetProgress: Int
    var frequency: QuestFrequency

    init(type: QuestType) {
        self.id = UUID().uuidString
        self.type = type
        self.questDescription = type.description
        self.xpReward = type.xpReward
        self.frequency = type.frequency
        self.isCompleted = false
        self.createdDate = Date()
        self.progress = 0
        self.targetProgress = 1

        let calendar = Calendar.current

        // Set expiry for daily quests (expires tomorrow at midnight)
        if type.frequency == .daily {
            self.expiresDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
        }
    }

    func complete() {
        isCompleted = true
        completedDate = Date()
    }

    var isExpired: Bool {
        guard let expiry = expiresDate else { return false }
        return Date() > expiry
    }
}

// MARK: - Badges

enum BadgeType: String, Codable, CaseIterable {
    case firstDayFree = "First Day Free"
    case week = "One Week Strong"
    case month = "30-Day Phoenix"
    case hundredDays = "Century Club"
    case sixMonths = "Half-Year Hero"
    case oneYear = "Anniversary Legend"
    case cravingSlayer = "Craving Slayer"
    case breathworkMaster = "Breathwork Master"
    case journalJourney = "Journal Journey"
    case motivationChampion = "Motivation Champion"
    case streakmaster = "Streakmaster"
    case legendarySavings = "Savings Legend"

    var title: String {
        switch self {
        case .firstDayFree: return "First Day Free"
        case .week: return "One Week Strong"
        case .month: return "30-Day Phoenix"
        case .hundredDays: return "Century Club"
        case .sixMonths: return "Half-Year Hero"
        case .oneYear: return "Anniversary Legend"
        case .cravingSlayer: return "Craving Slayer"
        case .breathworkMaster: return "Breathwork Master"
        case .journalJourney: return "Journal Journey"
        case .motivationChampion: return "Motivation Champion"
        case .streakmaster: return "Streakmaster"
        case .legendarySavings: return "Savings Legend"
        }
    }

    var description: String {
        switch self {
        case .firstDayFree: return "Completed your first smoke-free day"
        case .week: return "Stayed smoke-free for 7 days"
        case .month: return "Reached 30 days smoke-free"
        case .hundredDays: return "100 days of freedom"
        case .sixMonths: return "6 months completely free"
        case .oneYear: return "A full year of new life"
        case .cravingSlayer: return "Resisted 50 cravings"
        case .breathworkMaster: return "Completed 25 breathing exercises"
        case .journalJourney: return "Wrote 50 journal entries"
        case .motivationChampion: return "Added 5 motivations"
        case .streakmaster: return "Maintained a 100-day streak"
        case .legendarySavings: return "Saved over $1000"
        }
    }

    var icon: String {
        switch self {
        case .firstDayFree: return "star.fill"
        case .week: return "flame.fill"
        case .month: return "phoenix.fill"
        case .hundredDays: return "100.circle.fill"
        case .sixMonths: return "calendar.circle.fill"
        case .oneYear: return "star.circle.fill"
        case .cravingSlayer: return "bolt.fill"
        case .breathworkMaster: return "wind.circle.fill"
        case .journalJourney: return "doc.text.fill"
        case .motivationChampion: return "heart.fill"
        case .streakmaster: return "flame.circle.fill"
        case .legendarySavings: return "dollarsign.circle.fill"
        }
    }

    var requirementType: BadgeRequirement {
        switch self {
        case .firstDayFree: return .daysSinceQuit(1)
        case .week: return .daysSinceQuit(7)
        case .month: return .daysSinceQuit(30)
        case .hundredDays: return .daysSinceQuit(100)
        case .sixMonths: return .daysSinceQuit(180)
        case .oneYear: return .daysSinceQuit(365)
        case .cravingSlayer: return .cravingsResisted(50)
        case .breathworkMaster: return .breathworkSessions(25)
        case .journalJourney: return .journalEntries(50)
        case .motivationChampion: return .motivationCount(5)
        case .streakmaster: return .streakDays(100)
        case .legendarySavings: return .moneySaved(1000)
        }
    }

    var isPremium: Bool {
        // Premium badges = legendary/rare cosmetics
        return false // All badges are free tier for now
    }
}

enum BadgeRequirement: Codable {
    case daysSinceQuit(Int)
    case cravingsResisted(Int)
    case breathworkSessions(Int)
    case journalEntries(Int)
    case motivationCount(Int)
    case streakDays(Int)
    case moneySaved(Double)

    enum CodingKeys: String, CodingKey {
        case type
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "daysSinceQuit": self = .daysSinceQuit(try container.decode(Int.self, forKey: .value))
        case "cravingsResisted": self = .cravingsResisted(try container.decode(Int.self, forKey: .value))
        case "breathworkSessions": self = .breathworkSessions(try container.decode(Int.self, forKey: .value))
        case "journalEntries": self = .journalEntries(try container.decode(Int.self, forKey: .value))
        case "motivationCount": self = .motivationCount(try container.decode(Int.self, forKey: .value))
        case "streakDays": self = .streakDays(try container.decode(Int.self, forKey: .value))
        case "moneySaved": self = .moneySaved(try container.decode(Double.self, forKey: .value))
        default: throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown type")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .daysSinceQuit(let val):
            try container.encode("daysSinceQuit", forKey: .type)
            try container.encode(val, forKey: .value)
        case .cravingsResisted(let val):
            try container.encode("cravingsResisted", forKey: .type)
            try container.encode(val, forKey: .value)
        case .breathworkSessions(let val):
            try container.encode("breathworkSessions", forKey: .type)
            try container.encode(val, forKey: .value)
        case .journalEntries(let val):
            try container.encode("journalEntries", forKey: .type)
            try container.encode(val, forKey: .value)
        case .motivationCount(let val):
            try container.encode("motivationCount", forKey: .type)
            try container.encode(val, forKey: .value)
        case .streakDays(let val):
            try container.encode("streakDays", forKey: .type)
            try container.encode(val, forKey: .value)
        case .moneySaved(let val):
            try container.encode("moneySaved", forKey: .type)
            try container.encode(val, forKey: .value)
        }
    }
}

@Model
final class Badge {
    var id: String
    var type: BadgeType
    var title: String
    var badgeDescription: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var requirement: BadgeRequirement
    var isPremium: Bool

    init(type: BadgeType) {
        self.id = UUID().uuidString
        self.type = type
        self.title = type.title
        self.badgeDescription = type.description
        self.icon = type.icon
        self.requirement = type.requirementType
        self.isPremium = type.isPremium
        self.isUnlocked = false
    }

    func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
}
