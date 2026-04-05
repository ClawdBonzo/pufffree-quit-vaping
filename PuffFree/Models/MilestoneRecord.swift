import Foundation
import SwiftData

@Model
final class MilestoneRecord {
    var id: UUID
    var milestoneType: MilestoneType
    var unlockedAt: Date?
    var isUnlocked: Bool
    var celebrationShown: Bool

    init(milestoneType: MilestoneType, isUnlocked: Bool = false) {
        self.id = UUID()
        self.milestoneType = milestoneType
        self.isUnlocked = isUnlocked
        self.unlockedAt = isUnlocked ? Date() : nil
        self.celebrationShown = false
    }
}

enum MilestoneType: String, Codable, CaseIterable, Identifiable {
    case oneHour = "1 Hour Free"
    case fourHours = "4 Hours Strong"
    case eightHours = "8 Hour Warrior"
    case twelveHours = "Half Day Hero"
    case oneDay = "24 Hour Champion"
    case twoDays = "48 Hour Streak"
    case threeDays = "72 Hour Breakthrough"
    case oneWeek = "1 Week Wonder"
    case twoWeeks = "2 Week Titan"
    case oneMonth = "1 Month Master"
    case twoMonths = "2 Month Milestone"
    case threeMonths = "Quarter Year Quest"
    case sixMonths = "Half Year Hero"
    case oneYear = "1 Year Legend"

    var id: String { rawValue }

    var hoursRequired: Int {
        switch self {
        case .oneHour: return 1
        case .fourHours: return 4
        case .eightHours: return 8
        case .twelveHours: return 12
        case .oneDay: return 24
        case .twoDays: return 48
        case .threeDays: return 72
        case .oneWeek: return 168
        case .twoWeeks: return 336
        case .oneMonth: return 730
        case .twoMonths: return 1460
        case .threeMonths: return 2190
        case .sixMonths: return 4380
        case .oneYear: return 8760
        }
    }

    var icon: String {
        switch self {
        case .oneHour: return "star.fill"
        case .fourHours: return "star.circle.fill"
        case .eightHours: return "shield.fill"
        case .twelveHours: return "shield.checkered"
        case .oneDay: return "trophy.fill"
        case .twoDays: return "flame.fill"
        case .threeDays: return "bolt.shield.fill"
        case .oneWeek: return "crown.fill"
        case .twoWeeks: return "medal.fill"
        case .oneMonth: return "rosette"
        case .twoMonths: return "sparkles"
        case .threeMonths: return "diamond.fill"
        case .sixMonths: return "laurel.leading"
        case .oneYear: return "seal.fill"
        }
    }

    var celebrationMessage: String {
        switch self {
        case .oneHour: return "Your first hour! The journey begins."
        case .fourHours: return "4 hours strong! Your body is already starting to heal."
        case .eightHours: return "8 hours! Oxygen levels in your blood are normalizing."
        case .twelveHours: return "Half a day! Carbon monoxide levels have dropped."
        case .oneDay: return "24 hours! Your risk of heart attack is already decreasing."
        case .twoDays: return "48 hours! Your taste and smell are improving."
        case .threeDays: return "72 hours! Nicotine is completely leaving your body."
        case .oneWeek: return "1 week! Breathing is getting easier every day."
        case .twoWeeks: return "2 weeks! Circulation is dramatically improving."
        case .oneMonth: return "1 month! Lung function is increasing significantly."
        case .twoMonths: return "2 months! Your coughing and shortness of breath are decreasing."
        case .threeMonths: return "3 months! Your immune system is recovering."
        case .sixMonths: return "Half a year! Your lung cilia have regrown."
        case .oneYear: return "1 YEAR! Your risk of heart disease is cut in half!"
        }
    }

    var color: String {
        switch self {
        case .oneHour, .fourHours: return "milestoneGreen"
        case .eightHours, .twelveHours: return "milestoneTeal"
        case .oneDay, .twoDays, .threeDays: return "milestoneBlue"
        case .oneWeek, .twoWeeks: return "milestonePurple"
        case .oneMonth, .twoMonths, .threeMonths: return "milestoneGold"
        case .sixMonths, .oneYear: return "milestoneRainbow"
        }
    }
}
