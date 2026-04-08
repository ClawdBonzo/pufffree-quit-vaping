import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if hasCompletedOnboarding, profiles.first != nil {
                MainTabView()
                    .transition(.opacity)
            } else {
                OnboardingContainerView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasCompletedOnboarding)
    }
}

struct MainTabView: View {
    @State private var selectedTab: TabItem = .dashboard
    @Query private var profiles: [UserProfile]

    enum TabItem: String, CaseIterable {
        case dashboard = "Dashboard"
        case health = "Health"
        case gamification = "Achievements"
        case cravings = "Cravings"
        case journal = "Journal"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "lungs.fill"
            case .health: return "heart.fill"
            case .gamification: return "star.fill"
            case .cravings: return "flame.fill"
            case .journal: return "book.fill"
            case .settings: return "gearshape.fill"
            }
        }

        var customIcon: String {
            switch self {
            case .dashboard: return "TabDashboard"
            case .health: return "TabProgress"
            case .gamification: return "TabAchievements"
            case .cravings: return "TabLogger"
            case .journal: return "TabCoach"
            case .settings: return "TabSettings"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(TabItem.dashboard)

                HealthTimelineView()
                    .tag(TabItem.health)

                GamificationView()
                    .tag(TabItem.gamification)

                CravingTrackerView()
                    .tag(TabItem.cravings)

                JournalView()
                    .tag(TabItem.journal)

                SettingsView()
                    .tag(TabItem.settings)
            }
            .tabViewStyle(.automatic)
            .toolbar(.hidden, for: .tabBar)

            PuffFreeTabBar(selectedTab: $selectedTab)
        }
    }
}
