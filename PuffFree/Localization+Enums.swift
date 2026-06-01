import Foundation

// Localized display names for enums whose `rawValue` doubles as the
// SwiftData/Codable storage value (so the rawValue itself must stay English).
// Keys live in Localizable.xcstrings; falls back to the English key if missing.

extension NicotineType {
    var displayName: String { NSLocalizedString(rawValue, comment: "Nicotine product type") }
}

extension Mood {
    var displayName: String { NSLocalizedString(rawValue, comment: "Mood") }
}

extension CravingTrigger {
    var displayName: String { NSLocalizedString(rawValue, comment: "Craving trigger") }
}

extension CopingStrategy {
    var displayName: String { NSLocalizedString(rawValue, comment: "Coping strategy") }
}

extension MilestoneType {
    var displayName: String { NSLocalizedString(rawValue, comment: "Milestone name") }
}

extension PlayerLevel {
    var localizedTitle: String { NSLocalizedString(title, comment: "Player level title") }
}
