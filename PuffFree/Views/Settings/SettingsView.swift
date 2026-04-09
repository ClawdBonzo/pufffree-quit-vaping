import SwiftUI
import SwiftData

struct SettingsView: View {
    @Query private var profiles: [UserProfile]
    @Environment(\.modelContext) private var modelContext
    @State private var showEditProfile = false
    @State private var showResetAlert = false
    @State private var showPaywall = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var isRestoring = false
    @State private var showShareView = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                // Profile section
                if let profile {
                    Section {
                        HStack(spacing: 14) {
                            Image("OnboardingWelcome")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(profile.displayName.isEmpty ? "Quitter" : profile.displayName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Quit on \(profile.quitDate.shortFormatted)")
                                    .font(.caption)
                                    .foregroundColor(PuffFreeTheme.textSecondary)
                            }
                        }
                        .listRowBackground(PuffFreeTheme.backgroundCard)
                    }
                }

                // Quick stats
                if let profile {
                    Section("Your Stats") {
                        SettingsStatRow(label: "Days Puff-Free", value: "\(profile.daysSinceQuit)")
                        SettingsStatRow(label: "Money Saved", value: String(format: "$%.2f", profile.moneySaved))
                        SettingsStatRow(label: "Puffs Avoided", value: "\(profile.puffsAvoided)")
                        SettingsStatRow(label: "Cravings Resisted", value: "\(profile.totalCravingsResisted)")
                    }
                    .listRowBackground(PuffFreeTheme.backgroundCard)
                }

                // Settings
                Section("Preferences") {
                    Button {
                        showEditProfile = true
                    } label: {
                        Label("Edit Profile", systemImage: "person.fill")
                    }
                    .foregroundColor(.white)

                    NavigationLink {
                        MilestonesView()
                    } label: {
                        Label("Milestones", systemImage: "trophy.fill")
                    }
                    .foregroundColor(.white)

                    NavigationLink {
                        SavingsView()
                    } label: {
                        Label("Savings Tracker", systemImage: "dollarsign.circle.fill")
                    }
                    .foregroundColor(.white)

                    Button {
                        showShareView = true
                    } label: {
                        Label("Share My Journey", systemImage: "flame.fill")
                    }
                    .foregroundStyle(PuffFreeTheme.flameGradient)

                    Button {
                        showPaywall = true
                    } label: {
                        Label("Manage Subscription", systemImage: "crown.fill")
                    }
                    .foregroundColor(.white)

                    Button {
                        isRestoring = true
                        Task {
                            defer { isRestoring = false }
                            do {
                                let isPro = try await RevenueCatManager.shared.restorePurchases()
                                restoreMessage = isPro
                                    ? "Purchases restored successfully!"
                                    : "No active subscription found."
                            } catch {
                                restoreMessage = error.localizedDescription
                            }
                            showRestoreAlert = true
                        }
                    } label: {
                        if isRestoring {
                            HStack {
                                ProgressView().tint(PuffFreeTheme.accentTeal)
                                Text("Restoring…").foregroundColor(PuffFreeTheme.textSecondary)
                            }
                        } else {
                            Label("Restore Purchases", systemImage: "arrow.counterclockwise")
                        }
                    }
                    .foregroundColor(.white)
                }
                .listRowBackground(PuffFreeTheme.backgroundCard)

                // Notifications
                Section("Notifications") {
                    Button {
                        Task {
                            _ = await NotificationManager.shared.requestPermission()
                            NotificationManager.shared.scheduleDailyCheckInReminder()
                            NotificationManager.shared.scheduleMotivationalNotifications()
                        }
                    } label: {
                        Label("Re-enable Notifications", systemImage: "bell.fill")
                    }
                    .foregroundColor(.white)
                }
                .listRowBackground(PuffFreeTheme.backgroundCard)

                // Danger zone
                Section("Data") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash.fill")
                    }
                }
                .listRowBackground(PuffFreeTheme.backgroundCard)

                // App info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(PuffFreeTheme.textSecondary)
                        Spacer()
                        Text(AppConstants.appVersion)
                            .foregroundColor(PuffFreeTheme.textTertiary)
                    }
                    HStack {
                        Text("Built with")
                            .foregroundColor(PuffFreeTheme.textSecondary)
                        Spacer()
                        Text("SwiftUI + SwiftData")
                            .foregroundColor(PuffFreeTheme.textTertiary)
                    }
                }
                .listRowBackground(PuffFreeTheme.backgroundCard)
            }
            .scrollContentBackground(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showEditProfile) {
                if let profile {
                    EditProfileView(profile: profile)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false })
            }
            .sheet(isPresented: $showShareView) {
                if let profile {
                    PhoenixShareView(profile: profile)
                }
            }
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(restoreMessage)
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your progress, journal entries, and settings. This cannot be undone.")
            }
        }
    }

    private func resetAllData() {
        for profile in profiles { modelContext.delete(profile) }
        try? modelContext.fetch(FetchDescriptor<CravingLog>()).forEach { modelContext.delete($0) }
        try? modelContext.fetch(FetchDescriptor<JournalEntry>()).forEach { modelContext.delete($0) }
        try? modelContext.fetch(FetchDescriptor<DailyCheckIn>()).forEach { modelContext.delete($0) }
        try? modelContext.fetch(FetchDescriptor<MilestoneRecord>()).forEach { modelContext.delete($0) }
        NotificationManager.shared.cancelAll()
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
    }
}

struct SettingsStatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(PuffFreeTheme.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}
