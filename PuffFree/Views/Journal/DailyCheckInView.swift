import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var mood: Mood = .neutral
    @State private var cravingLevel: Double = 5
    @State private var energyLevel: Double = 5
    @State private var sleepQuality: Double = 5
    @State private var exercised = false
    @State private var hydratedWell = false
    @State private var proudMoment = ""
    @State private var gratitude = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mood
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Mood")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            ForEach(Mood.allCases) { m in
                                Button {
                                    mood = m
                                    HapticManager.selection()
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: m.icon)
                                            .font(.title2)
                                        Text(m.rawValue)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(mood == m ? .white : PuffFreeTheme.textTertiary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(mood == m ? PuffFreeTheme.backgroundElevated : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Sliders
                    Group {
                        CheckInSlider(title: "Craving Level", value: $cravingLevel, icon: "flame.fill", color: .orange)
                        CheckInSlider(title: "Energy Level", value: $energyLevel, icon: "bolt.fill", color: .yellow)
                        CheckInSlider(title: "Sleep Quality", value: $sleepQuality, icon: "moon.fill", color: .purple)
                    }

                    // Toggles
                    HStack(spacing: 12) {
                        CheckInToggle(title: "Exercised", icon: "figure.run", isOn: $exercised, color: PuffFreeTheme.success)
                        CheckInToggle(title: "Hydrated Well", icon: "drop.fill", isOn: $hydratedWell, color: PuffFreeTheme.info)
                    }

                    // Proud moment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Proud Moment")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("What are you proud of today?", text: $proudMoment, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(PuffFreeTheme.backgroundElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Gratitude
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gratitude")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("What are you grateful for?", text: $gratitude, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(PuffFreeTheme.backgroundElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Daily Check-In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCheckIn() }
                        .foregroundColor(PuffFreeTheme.accentTeal)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveCheckIn() {
        let checkIn = DailyCheckIn(
            mood: mood,
            cravingLevel: Int(cravingLevel),
            energyLevel: Int(energyLevel),
            sleepQuality: Int(sleepQuality),
            exercised: exercised,
            hydratedWell: hydratedWell,
            proudMoment: proudMoment,
            gratitude: gratitude
        )
        modelContext.insert(checkIn)
        HapticManager.notification(.success)
        dismiss()
    }
}

struct CheckInSlider: View {
    let title: String
    @Binding var value: Double
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(value))/10")
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Slider(value: $value, in: 1...10, step: 1)
                .tint(color)
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct CheckInToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        Button {
            isOn.toggle()
            HapticManager.selection()
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isOn ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isOn ? color : PuffFreeTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
