import Foundation
import SwiftData

@Model
final class DailyCheckIn {
    var id: UUID
    var date: Date
    var mood: Mood
    var cravingLevel: Int
    var energyLevel: Int
    var sleepQuality: Int
    var exercised: Bool
    var hydratedWell: Bool
    var proudMoment: String
    var gratitude: String

    init(
        mood: Mood = .neutral,
        cravingLevel: Int = 5,
        energyLevel: Int = 5,
        sleepQuality: Int = 5,
        exercised: Bool = false,
        hydratedWell: Bool = false,
        proudMoment: String = "",
        gratitude: String = ""
    ) {
        self.id = UUID()
        self.date = Date()
        self.mood = mood
        self.cravingLevel = cravingLevel
        self.energyLevel = energyLevel
        self.sleepQuality = sleepQuality
        self.exercised = exercised
        self.hydratedWell = hydratedWell
        self.proudMoment = proudMoment
        self.gratitude = gratitude
    }
}
