import Foundation
import SwiftData

@Model
final class JournalEntry {
    var id: UUID
    var timestamp: Date
    var title: String
    var body: String
    var mood: Mood
    var tags: [String]

    init(
        title: String = "",
        body: String = "",
        mood: Mood = .neutral,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.title = title
        self.body = body
        self.mood = mood
        self.tags = tags
    }
}

enum Mood: String, Codable, CaseIterable, Identifiable {
    case great = "Great"
    case good = "Good"
    case neutral = "Okay"
    case struggling = "Struggling"
    case terrible = "Terrible"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .great: return "face.smiling.inverse"
        case .good: return "face.smiling"
        case .neutral: return "face.dashed"
        case .struggling: return "cloud.rain.fill"
        case .terrible: return "cloud.bolt.fill"
        }
    }

    var color: String {
        switch self {
        case .great: return "moodGreat"
        case .good: return "moodGood"
        case .neutral: return "moodNeutral"
        case .struggling: return "moodStruggling"
        case .terrible: return "moodTerrible"
        }
    }
}
