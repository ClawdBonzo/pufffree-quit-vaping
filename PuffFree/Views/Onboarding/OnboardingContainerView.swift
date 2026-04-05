import SwiftUI
import SwiftData

struct OnboardingContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var currentStep = 0
    @State private var displayName = ""
    @State private var nicotineType: NicotineType = .vape
    @State private var dailyUsage = 10
    @State private var costPerPack = 15.0
    @State private var packSize = 1
    @State private var nicotineStrength = 5.0
    @State private var quitDate = Date()
    @State private var primaryMotivation = "Health"
    @State private var additionalMotivations: [String] = []
    @State private var notificationsEnabled = true

    private let totalSteps = 6

    var body: some View {
        ZStack {
            PuffFreeTheme.backgroundPrimary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: Double(currentStep + 1), total: Double(totalSteps))
                    .tint(PuffFreeTheme.accentTeal)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                TabView(selection: $currentStep) {
                    WelcomeStepView(
                        displayName: $displayName,
                        onNext: { nextStep() }
                    )
                    .tag(0)

                    NicotineTypeStepView(
                        selectedType: $nicotineType,
                        onNext: { nextStep() }
                    )
                    .tag(1)

                    UsagePatternStepView(
                        nicotineType: nicotineType,
                        dailyUsage: $dailyUsage,
                        costPerPack: $costPerPack,
                        packSize: $packSize,
                        nicotineStrength: $nicotineStrength,
                        onNext: { nextStep() }
                    )
                    .tag(2)

                    QuitDateStepView(
                        quitDate: $quitDate,
                        onNext: { nextStep() }
                    )
                    .tag(3)

                    MotivationStepView(
                        primaryMotivation: $primaryMotivation,
                        additionalMotivations: $additionalMotivations,
                        onNext: { nextStep() }
                    )
                    .tag(4)

                    NotificationStepView(
                        notificationsEnabled: $notificationsEnabled,
                        onComplete: { completeOnboarding() }
                    )
                    .tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }

    private func nextStep() {
        withAnimation {
            currentStep = min(currentStep + 1, totalSteps - 1)
        }
        HapticManager.selection()
    }

    private func completeOnboarding() {
        let profile = UserProfile(
            displayName: displayName.isEmpty ? "Friend" : displayName,
            quitDate: quitDate,
            nicotineType: nicotineType,
            dailyUsageCount: dailyUsage,
            costPerPack: costPerPack,
            packSize: packSize,
            nicotineStrength: nicotineStrength,
            primaryMotivation: primaryMotivation,
            additionalMotivations: additionalMotivations,
            notificationsEnabled: notificationsEnabled
        )

        modelContext.insert(profile)

        if notificationsEnabled {
            Task {
                _ = await NotificationManager.shared.requestPermission()
                NotificationManager.shared.scheduleDailyCheckInReminder()
                NotificationManager.shared.scheduleMotivationalNotifications()
                NotificationManager.shared.scheduleAllMilestoneNotifications(quitDate: quitDate)
            }
        }

        // Seed initial milestones
        for milestone in MilestoneType.allCases {
            let record = MilestoneRecord(milestoneType: milestone, isUnlocked: false)
            modelContext.insert(record)
        }

        HapticManager.celebration()

        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}
