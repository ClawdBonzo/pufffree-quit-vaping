import Foundation
import SwiftUI
import SwiftData

@Observable
final class CravingViewModel {
    var todayCravings: Int = 0
    var weekCravings: Int = 0
    var averageIntensity: Double = 0
    var resistRate: Double = 0
    var topTrigger: CravingTrigger?
    var cravingTrend: [DayCravingData] = []

    struct DayCravingData: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
        let averageIntensity: Double
    }

    func refresh(logs: [CravingLog]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today

        let todayLogs = logs.filter { calendar.isDateInToday($0.timestamp) }
        let weekLogs = logs.filter { $0.timestamp >= weekAgo }

        todayCravings = todayLogs.count
        weekCravings = weekLogs.count

        if !weekLogs.isEmpty {
            averageIntensity = Double(weekLogs.reduce(0) { $0 + $1.intensity }) / Double(weekLogs.count)
            let resisted = weekLogs.filter(\.didResist).count
            resistRate = Double(resisted) / Double(weekLogs.count)
        } else {
            averageIntensity = 0
            resistRate = 1.0
        }

        let triggerCounts = Dictionary(grouping: weekLogs, by: \.trigger)
            .mapValues(\.count)
        topTrigger = triggerCounts.max(by: { $0.value < $1.value })?.key

        cravingTrend = (0..<7).reversed().compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            let dayLogs = logs.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
            let avgIntensity = dayLogs.isEmpty ? 0 :
                Double(dayLogs.reduce(0) { $0 + $1.intensity }) / Double(dayLogs.count)
            return DayCravingData(date: date, count: dayLogs.count, averageIntensity: avgIntensity)
        }
    }

    func quickLogCraving(
        intensity: Int,
        trigger: CravingTrigger,
        didResist: Bool,
        modelContext: ModelContext
    ) {
        let log = CravingLog(
            intensity: intensity,
            trigger: trigger,
            didResist: didResist
        )
        modelContext.insert(log)
    }
}
