import SwiftUI
import SwiftData

struct JournalView: View {
    @Query(sort: \JournalEntry.timestamp, order: .reverse) private var entries: [JournalEntry]
    @Query(sort: \DailyCheckIn.date, order: .reverse) private var checkIns: [DailyCheckIn]
    @State private var showNewEntry = false
    @State private var showCheckIn = false
    @State private var selectedSegment = 0
    @Environment(\.subscriptionViewModel) private var subscriptionVM

    var body: some View {
        NavigationStack {
            Group {
                if subscriptionVM.isPro {
                    proJournalContent
                } else {
                    journalPreviewGate
                }
            }
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if subscriptionVM.isPro {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            if selectedSegment == 0 {
                                showNewEntry = true
                            } else {
                                showCheckIn = true
                            }
                            HapticManager.impact(.light)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(PuffFreeTheme.primaryGradient)
                        }
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                JournalEntrySheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showCheckIn) {
                DailyCheckInView()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    // MARK: - Pro Content

    @ViewBuilder
    private var proJournalContent: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $selectedSegment) {
                Text("Journal").tag(0)
                Text("Check-Ins").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            ScrollView {
                if selectedSegment == 0 {
                    journalContent
                } else {
                    checkInContent
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Free User Preview Gate

    @ViewBuilder
    private var journalPreviewGate: some View {
        VStack(spacing: 0) {
            // Non-interactive segment picker preview
            Picker("View", selection: .constant(0)) {
                Text("Journal").tag(0)
                Text("Check-Ins").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .disabled(true)
            .opacity(0.5)

            Spacer()
        }
        .overlay {
            PremiumGateOverlay(
                title: "Your Private Journal",
                subtitle: "Track your thoughts, mood, and daily check-ins.",
                iconName: "book.fill"
            )
        }
    }

    @ViewBuilder
    private var journalContent: some View {
        if entries.isEmpty {
            MotivationalEmptyState(
                icon: "book.fill",
                title: "Start Your Journal",
                message: "Write about your journey, track your thoughts, and celebrate wins."
            )
            .padding(.top, 40)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(entries) { entry in
                    JournalEntryRow(entry: entry)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    @ViewBuilder
    private var checkInContent: some View {
        if checkIns.isEmpty {
            MotivationalEmptyState(
                icon: "checkmark.circle.fill",
                title: "Daily Check-Ins",
                message: "Track your mood, energy, and progress every day."
            )
            .padding(.top, 40)
        } else {
            LazyVStack(spacing: 12) {
                ForEach(checkIns) { checkIn in
                    CheckInRow(checkIn: checkIn)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.mood.icon)
                    .foregroundColor(moodColor(entry.mood))
                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text(entry.timestamp.shortFormatted)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textTertiary)
            }

            Text(entry.body)
                .font(.subheadline)
                .foregroundColor(PuffFreeTheme.textSecondary)
                .lineLimit(3)

            if !entry.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(PuffFreeTheme.accentTeal.opacity(0.15))
                            .foregroundColor(PuffFreeTheme.accentTeal)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(entry.title.isEmpty
            ? NSLocalizedString("Untitled", comment: "Journal entry") : entry.title)
        .accessibilityValue("\(entry.mood.displayName), \(entry.timestamp.shortFormatted)")
        .accessibilityHint(entry.body)
    }

    private func moodColor(_ mood: Mood) -> Color {
        switch mood {
        case .great: return PuffFreeTheme.moodGreat
        case .good: return PuffFreeTheme.moodGood
        case .neutral: return PuffFreeTheme.moodNeutral
        case .struggling: return PuffFreeTheme.moodStruggling
        case .terrible: return PuffFreeTheme.moodTerrible
        }
    }
}

struct CheckInRow: View {
    let checkIn: DailyCheckIn

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: checkIn.mood.icon)
                .font(.title3)
                .foregroundColor(checkInMoodColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(checkIn.date.shortFormatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    Label("Craving: \(checkIn.cravingLevel)/10", systemImage: "flame")
                    Label("Energy: \(checkIn.energyLevel)/10", systemImage: "bolt")
                }
                .font(.caption2)
                .foregroundColor(PuffFreeTheme.textSecondary)
            }

            Spacer()

            HStack(spacing: 4) {
                if checkIn.exercised {
                    Image(systemName: "figure.run")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.success)
                }
                if checkIn.hydratedWell {
                    Image(systemName: "drop.fill")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.info)
                }
            }
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var checkInMoodColor: Color {
        switch checkIn.mood {
        case .great: return PuffFreeTheme.moodGreat
        case .good: return PuffFreeTheme.moodGood
        case .neutral: return PuffFreeTheme.moodNeutral
        case .struggling: return PuffFreeTheme.moodStruggling
        case .terrible: return PuffFreeTheme.moodTerrible
        }
    }
}
