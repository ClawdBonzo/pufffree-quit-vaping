import SwiftUI
import SwiftData
import RevenueCat

@main
struct PuffFreeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var subscriptionViewModel = SubscriptionViewModel()

    init() {
        Purchases.configure(withAPIKey: AppConstants.RevenueCat.apiKey)
        #if DEBUG
        DemoSeeder.seedIfNeeded(sharedModelContainer.mainContext)
        #endif
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            CravingLog.self,
            MilestoneRecord.self,
            JournalEntry.self,
            DailyCheckIn.self,
            GamificationState.self,
            Quest.self
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
                .environment(\.subscriptionViewModel, subscriptionViewModel)
                .task { await subscriptionViewModel.refresh() }
        }
        .modelContainer(sharedModelContainer)
    }
}
