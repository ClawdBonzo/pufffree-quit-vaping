import SwiftUI
import SwiftData
import RevenueCat

@main
struct PuffFreeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        // TODO: Replace with live key before App Store release
        Purchases.configure(withAPIKey: AppConstants.RevenueCat.apiKey)
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            CravingLog.self,
            MilestoneRecord.self,
            JournalEntry.self,
            DailyCheckIn.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
