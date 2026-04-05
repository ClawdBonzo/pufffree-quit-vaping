import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct PuffFreeEntry: TimelineEntry {
    let date: Date
    let daysSinceQuit: Int
    let hoursSinceQuit: Int
    let minutesSinceQuit: Int
    let moneySaved: Double
    let puffsAvoided: Int

    static let placeholder = PuffFreeEntry(
        date: Date(),
        daysSinceQuit: 42,
        hoursSinceQuit: 1008,
        minutesSinceQuit: 60480,
        moneySaved: 315.00,
        puffsAvoided: 840
    )
}

// MARK: - Timeline Provider
struct PuffFreeProvider: TimelineProvider {
    func placeholder(in context: Context) -> PuffFreeEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PuffFreeEntry) -> Void) {
        completion(createEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PuffFreeEntry>) -> Void) {
        let entry = createEntry()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func createEntry() -> PuffFreeEntry {
        let defaults = UserDefaults(suiteName: "group.com.pufffree.app")
        let quitDateInterval = defaults?.double(forKey: "quitDate") ?? Date().timeIntervalSince1970
        let quitDate = Date(timeIntervalSince1970: quitDateInterval)
        let dailyUsage = defaults?.integer(forKey: "dailyUsage") ?? 10
        let costPerDay = defaults?.double(forKey: "costPerDay") ?? 5.0

        let interval = Date().timeIntervalSince(quitDate)
        let days = Int(interval / 86400)
        let hours = Int(interval / 3600)
        let minutes = Int(interval / 60)
        let moneySaved = costPerDay * (interval / 86400)
        let puffsAvoided = Int(Double(dailyUsage) * (interval / 86400))

        return PuffFreeEntry(
            date: Date(),
            daysSinceQuit: max(days, 0),
            hoursSinceQuit: max(hours, 0),
            minutesSinceQuit: max(minutes, 0),
            moneySaved: max(moneySaved, 0),
            puffsAvoided: max(puffsAvoided, 0)
        )
    }
}

// MARK: - Home Screen Widget
struct PuffFreeWidget: Widget {
    let kind: String = "PuffFreeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PuffFreeProvider()) { entry in
            PuffFreeWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PuffFree Timer")
        .description("Track your smoke-free journey")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PuffFreeWidgetView: View {
    let entry: PuffFreeEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    var smallWidget: some View {
        VStack(spacing: 8) {
            Image(systemName: "lungs.fill")
                .font(.title2)
                .foregroundStyle(.teal)

            Text("\(entry.daysSinceQuit)")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            Text("days free")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    var mediumWidget: some View {
        HStack(spacing: 20) {
            VStack(spacing: 6) {
                Image(systemName: "lungs.fill")
                    .font(.title2)
                    .foregroundStyle(.teal)
                Text("\(entry.daysSinceQuit)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Text("days free")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.orange)
                    Text(String(format: "$%.0f saved", entry.moneySaved))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 6) {
                    Image(systemName: "nosign")
                        .foregroundColor(.red)
                    Text("\(entry.puffsAvoided) avoided")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.blue)
                    Text("\(entry.hoursSinceQuit)h strong")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Lock Screen Widget
struct PuffFreeLockScreenWidget: Widget {
    let kind: String = "PuffFreeLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PuffFreeProvider()) { entry in
            PuffFreeLockScreenView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("PuffFree Lock Screen")
        .description("Quick glance at your progress")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}

struct PuffFreeLockScreenView: View {
    let entry: PuffFreeEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryRectangular:
            rectangularView
        case .accessoryInline:
            inlineView
        default:
            circularView
        }
    }

    var circularView: some View {
        VStack(spacing: 2) {
            Image(systemName: "lungs.fill")
                .font(.caption)
            Text("\(entry.daysSinceQuit)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text("days")
                .font(.system(size: 8))
        }
    }

    var rectangularView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("PuffFree")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("\(entry.daysSinceQuit) days free")
                    .font(.headline)
                Text(String(format: "$%.0f saved", entry.moneySaved))
                    .font(.caption2)
            }
            Spacer()
        }
    }

    var inlineView: some View {
        Text("\(entry.daysSinceQuit)d puff-free | $\(String(format: "%.0f", entry.moneySaved)) saved")
    }
}
