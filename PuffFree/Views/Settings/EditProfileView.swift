import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var profile: UserProfile

    @State private var displayName: String = ""
    @State private var dailyUsage: Double = 10
    @State private var costPerPack: Double = 15
    @State private var nicotineStrength: Double = 5
    @State private var quitDate: Date = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Your name", text: $displayName)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(PuffFreeTheme.backgroundElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Quit date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quit Date")
                            .font(.headline)
                            .foregroundColor(.white)
                        DatePicker("", selection: $quitDate, in: ...Date(), displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .tint(PuffFreeTheme.accentTeal)
                            .colorScheme(.dark)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Usage stats
                    PremiumSliderRow(
                        title: "Daily Usage",
                        value: $dailyUsage,
                        range: 1...100,
                        unit: "per day",
                        step: 1
                    )

                    PremiumSliderRow(
                        title: "Cost per Unit",
                        value: $costPerPack,
                        range: 1...100,
                        unit: "$",
                        step: 0.5,
                        isCurrency: true
                    )

                    if profile.nicotineType == .vape {
                        PremiumSliderRow(
                            title: "Nicotine Strength",
                            value: $nicotineStrength,
                            range: 0...60,
                            unit: "mg/mL",
                            step: 1
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveChanges() }
                        .foregroundColor(PuffFreeTheme.accentTeal)
                        .fontWeight(.semibold)
                }
            }
            .onAppear {
                displayName = profile.displayName
                dailyUsage = Double(profile.dailyUsageCount)
                costPerPack = profile.costPerPack
                nicotineStrength = profile.nicotineStrength
                quitDate = profile.quitDate
            }
        }
    }

    private func saveChanges() {
        profile.displayName = displayName
        profile.dailyUsageCount = Int(dailyUsage)
        profile.costPerPack = costPerPack
        profile.nicotineStrength = nicotineStrength
        profile.quitDate = quitDate

        NotificationManager.shared.cancelAll()
        NotificationManager.shared.scheduleAllMilestoneNotifications(quitDate: quitDate)

        HapticManager.notification(.success)
        dismiss()
    }
}
