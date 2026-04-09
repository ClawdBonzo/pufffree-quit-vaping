import SwiftUI
import SwiftData

struct LogCravingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var intensity: Double = 5
    @State private var selectedTrigger: CravingTrigger = .stress
    @State private var selectedCoping: CopingStrategy = .deepBreathing
    @State private var didResist = true
    @State private var notes = ""
    @State private var gamificationViewModel: GamificationViewModel?
    @State private var showCelebration = false
    @State private var celebrationData: (xp: Int, type: String)? = nil
    @State private var showResistAnimation = false

    var body: some View {
        NavigationStack {
            ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Intensity slider
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Intensity")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(Int(intensity))/10")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(intensityColor)
                        }

                        Slider(value: $intensity, in: 1...10, step: 1)
                            .tint(intensityColor)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Trigger selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("What triggered it?")
                            .font(.headline)
                            .foregroundColor(.white)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(CravingTrigger.allCases) { trigger in
                                Button {
                                    selectedTrigger = trigger
                                    HapticManager.selection()
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: trigger.icon)
                                            .font(.caption)
                                        Text(trigger.rawValue)
                                            .font(.caption)
                                    }
                                    .foregroundColor(selectedTrigger == trigger ? .black : .white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedTrigger == trigger ?
                                        AnyShapeStyle(PuffFreeTheme.primaryGradient) :
                                        AnyShapeStyle(PuffFreeTheme.backgroundElevated)
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Did you resist?
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Did you resist?")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            ResistButton(
                                title: "Yes, I resisted!",
                                icon: "shield.fill",
                                isSelected: didResist,
                                color: PuffFreeTheme.success
                            ) { didResist = true }

                            ResistButton(
                                title: "I slipped",
                                icon: "heart.slash",
                                isSelected: !didResist,
                                color: PuffFreeTheme.warning
                            ) { didResist = false }
                        }
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Coping strategy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Coping Strategy Used")
                            .font(.headline)
                            .foregroundColor(.white)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 8) {
                            ForEach(CopingStrategy.allCases) { strategy in
                                Button {
                                    selectedCoping = strategy
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: strategy.icon)
                                            .font(.caption2)
                                        Text(strategy.rawValue)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(selectedCoping == strategy ? .black : .white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        selectedCoping == strategy ?
                                        AnyShapeStyle(PuffFreeTheme.primaryGradient) :
                                        AnyShapeStyle(PuffFreeTheme.backgroundElevated)
                                    )
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes (optional)")
                            .font(.headline)
                            .foregroundColor(.white)

                        TextField("How are you feeling?", text: $notes, axis: .vertical)
                            .lineLimit(3...5)
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
            .navigationTitle("Log Craving")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveCraving() }
                        .foregroundStyle(PuffFreeTheme.flameGradient)
                        .fontWeight(.semibold)
                }
            }

            // Phoenix resist celebration overlay
            if showResistAnimation {
                PhoenixResistOverlay()
                    .transition(.opacity)
                    .zIndex(10)
            }
            } // end ZStack
        }
    }

    private var intensityColor: Color {
        switch Int(intensity) {
        case 1...3: return PuffFreeTheme.success
        case 4...6: return PuffFreeTheme.warning
        default: return PuffFreeTheme.danger
        }
    }

    private func saveCraving() {
        let log = CravingLog(
            intensity: Int(intensity),
            trigger: selectedTrigger,
            copingStrategy: selectedCoping.rawValue,
            didResist: didResist,
            notes: notes
        )
        modelContext.insert(log)

        if didResist, let profile = profiles.first {
            profile.totalCravingsResisted += 1

            // Initialize gamification if needed
            if gamificationViewModel == nil {
                gamificationViewModel = GamificationViewModel(modelContext: modelContext)
            }

            // Award XP for resisting craving
            if let gamVM = gamificationViewModel {
                let xpAmount = Int(intensity) * 10 // Higher intensity = more XP
                gamVM.addXP(xpAmount, source: "resistCraving")

                // Update quest progress for craving resistance
                for quest in gamVM.quests {
                    if quest.type == .resistCravings && !quest.isCompleted {
                        quest.progress += 1
                        if quest.progress >= quest.targetProgress {
                            quest.isCompleted = true
                            quest.completedDate = Date()
                        }
                    }
                }
            }
        }

        HapticManager.notification(didResist ? .success : .warning)

        if didResist {
            // Show phoenix celebration before dismissing
            withAnimation(.easeIn(duration: 0.2)) { showResistAnimation = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                dismiss()
            }
        } else {
            dismiss()
        }
    }
}

struct ResistButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .black : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? color : PuffFreeTheme.backgroundElevated)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Phoenix Resist Overlay
// Full-screen transformation shown when user successfully resists a craving.

struct PhoenixResistOverlay: View {
    @State private var scale: CGFloat    = 0.5
    @State private var opacity: Double   = 0
    @State private var flamePulse        = false
    @State private var burstVisible      = false
    @State private var textOffset: CGFloat = 20

    var body: some View {
        ZStack {
            Color(hex: "040608").opacity(0.94)
                .ignoresSafeArea()

            PhoenixParticleField(intensity: 1.8)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            RadialGradient(
                colors: [PuffFreeTheme.smokeTeal.opacity(0.35), .clear],
                center: .center, startRadius: 0, endRadius: 200
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 20) {
                ZStack {
                    if burstVisible { EmberBurstView(particleCount: 16) }

                    Circle()
                        .fill(PuffFreeTheme.smokeTeal.opacity(0.18))
                        .frame(width: 130, height: 130)
                        .scaleEffect(flamePulse ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: flamePulse)
                        .blur(radius: 10)

                    ZStack {
                        Image(systemName: "shield.fill")
                            .font(.system(size: 62, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [PuffFreeTheme.smokeTeal, PuffFreeTheme.phoenixGold],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: PuffFreeTheme.smokeTeal.opacity(0.8), radius: 18)

                        Image(systemName: "flame.fill")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundStyle(PuffFreeTheme.flameGradient)
                            .offset(y: -4)
                    }
                    .scaleEffect(flamePulse ? 1.06 : 0.97)
                    .animation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true), value: flamePulse)
                }
                .frame(height: 140)

                VStack(spacing: 8) {
                    Text("CRAVING DEFEATED!")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [PuffFreeTheme.smokeTeal, PuffFreeTheme.phoenixGold],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .shadow(color: PuffFreeTheme.smokeTeal.opacity(0.5), radius: 10)

                    Text("The phoenix rises stronger.")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                .offset(y: textOffset)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15), value: textOffset)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
                scale = 1; opacity = 1; textOffset = 0
            }
            flamePulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { burstVisible = true }
            HapticManager.celebration()
        }
    }
}
