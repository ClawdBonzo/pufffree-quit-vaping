import Foundation
import SwiftData

@Model
final class CravingLog {
    var id: UUID
    var timestamp: Date
    var intensity: Int
    var trigger: CravingTrigger
    var copingStrategy: String
    var didResist: Bool
    var durationSeconds: Int
    var notes: String

    init(
        intensity: Int = 5,
        trigger: CravingTrigger = .stress,
        copingStrategy: String = "",
        didResist: Bool = true,
        durationSeconds: Int = 0,
        notes: String = ""
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.intensity = intensity
        self.trigger = trigger
        self.copingStrategy = copingStrategy
        self.didResist = didResist
        self.durationSeconds = durationSeconds
        self.notes = notes
    }
}

enum CravingTrigger: String, Codable, CaseIterable, Identifiable {
    case stress = "Stress"
    case boredom = "Boredom"
    case social = "Social Situation"
    case afterMeal = "After Meal"
    case alcohol = "Alcohol"
    case coffee = "Coffee/Caffeine"
    case anxiety = "Anxiety"
    case habit = "Habit/Routine"
    case emotion = "Emotional"
    case morning = "Morning Routine"
    case driving = "Driving"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .stress: return "bolt.fill"
        case .boredom: return "clock.fill"
        case .social: return "person.3.fill"
        case .afterMeal: return "fork.knife"
        case .alcohol: return "wineglass.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .anxiety: return "brain.head.profile"
        case .habit: return "arrow.clockwise"
        case .emotion: return "heart.fill"
        case .morning: return "sunrise.fill"
        case .driving: return "car.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

enum CopingStrategy: String, CaseIterable, Identifiable {
    case deepBreathing = "Deep Breathing"
    case drinkWater = "Drink Water"
    case goForWalk = "Go for a Walk"
    case chewGum = "Chew Gum"
    case callFriend = "Call a Friend"
    case exercise = "Exercise"
    case meditation = "Meditate"
    case snack = "Healthy Snack"
    case distraction = "Distraction"
    case journaling = "Journaling"
    case coldShower = "Cold Water on Face"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .deepBreathing: return "wind"
        case .drinkWater: return "drop.fill"
        case .goForWalk: return "figure.walk"
        case .chewGum: return "mouth.fill"
        case .callFriend: return "phone.fill"
        case .exercise: return "figure.run"
        case .meditation: return "brain.head.profile"
        case .snack: return "carrot.fill"
        case .distraction: return "gamecontroller.fill"
        case .journaling: return "pencil.and.scribble"
        case .coldShower: return "snowflake"
        case .other: return "ellipsis.circle.fill"
        }
    }
}
