import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID
    var displayName: String
    var quitDate: Date
    var nicotineType: NicotineType
    var dailyUsageCount: Int
    var costPerPack: Double
    var packSize: Int
    var nicotineStrength: Double
    var primaryMotivation: String
    var additionalMotivations: [String]
    var notificationsEnabled: Bool
    var createdAt: Date
    var longestStreakDays: Int
    var totalCravingsResisted: Int

    init(
        displayName: String = "",
        quitDate: Date = Date(),
        nicotineType: NicotineType = .vape,
        dailyUsageCount: Int = 10,
        costPerPack: Double = 15.0,
        packSize: Int = 1,
        nicotineStrength: Double = 5.0,
        primaryMotivation: String = "Health",
        additionalMotivations: [String] = [],
        notificationsEnabled: Bool = true
    ) {
        self.id = UUID()
        self.displayName = displayName
        self.quitDate = quitDate
        self.nicotineType = nicotineType
        self.dailyUsageCount = dailyUsageCount
        self.costPerPack = costPerPack
        self.packSize = packSize
        self.nicotineStrength = nicotineStrength
        self.primaryMotivation = primaryMotivation
        self.additionalMotivations = additionalMotivations
        self.notificationsEnabled = notificationsEnabled
        self.createdAt = Date()
        self.longestStreakDays = 0
        self.totalCravingsResisted = 0
    }

    var daysSinceQuit: Int {
        Calendar.current.dateComponents([.day], from: quitDate, to: Date()).day ?? 0
    }

    var hoursSinceQuit: Int {
        Calendar.current.dateComponents([.hour], from: quitDate, to: Date()).hour ?? 0
    }

    var timeSinceQuit: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = Date().timeIntervalSince(quitDate)
        guard interval > 0 else { return (0, 0, 0, 0) }
        let totalSeconds = Int(interval)
        let days = totalSeconds / 86400
        let hours = (totalSeconds % 86400) / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return (days, hours, minutes, seconds)
    }

    var moneySaved: Double {
        let dailyCost = costPerPack / Double(max(packSize, 1)) * Double(dailyUsageCount)
        let interval = Date().timeIntervalSince(quitDate)
        guard interval > 0 else { return 0 }
        return dailyCost * (interval / 86400.0)
    }

    var puffsAvoided: Int {
        let interval = Date().timeIntervalSince(quitDate)
        guard interval > 0 else { return 0 }
        let days = interval / 86400.0
        return Int(days * Double(dailyUsageCount))
    }

    var lifeRegained: String {
        let minutesPerCig = 11.0
        let totalMinutes = Double(puffsAvoided) * minutesPerCig
        let hours = Int(totalMinutes / 60)
        let days = hours / 24
        if days > 0 {
            return "\(days)d \(hours % 24)h"
        }
        return "\(hours)h \(Int(totalMinutes) % 60)m"
    }
}

enum NicotineType: String, Codable, CaseIterable, Identifiable {
    case vape = "Vape/E-Cigarette"
    case cigarette = "Cigarettes"
    case pouch = "Nicotine Pouches"
    case gum = "Nicotine Gum"
    case patch = "Nicotine Patches"
    case snus = "Snus"
    case hookah = "Hookah"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .vape: return "cloud.fill"
        case .cigarette: return "flame.fill"
        case .pouch: return "pill.fill"
        case .gum: return "mouth.fill"
        case .patch: return "bandage.fill"
        case .snus: return "circle.fill"
        case .hookah: return "wind"
        case .other: return "questionmark.circle.fill"
        }
    }
}
