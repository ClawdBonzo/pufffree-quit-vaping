import SwiftUI
import SwiftData

struct JournalEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var body_ = ""
    @State private var selectedMood: Mood = .neutral
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var gamificationViewModel: GamificationViewModel?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Mood selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How are you feeling?")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack(spacing: 12) {
                            ForEach(Mood.allCases) { mood in
                                Button {
                                    selectedMood = mood
                                    HapticManager.selection()
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: mood.icon)
                                            .font(.title2)
                                        Text(mood.rawValue)
                                            .font(.caption2)
                                    }
                                    .foregroundColor(selectedMood == mood ? .white : PuffFreeTheme.textTertiary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedMood == mood ?
                                        PuffFreeTheme.backgroundElevated : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Title")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("What's on your mind?", text: $title)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(PuffFreeTheme.backgroundElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Body
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journal Entry")
                            .font(.headline)
                            .foregroundColor(.white)
                        TextField("Write your thoughts...", text: $body_, axis: .vertical)
                            .lineLimit(5...15)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(PuffFreeTheme.backgroundElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(PuffFreeTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                    // Tags
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.white)

                        HStack {
                            TextField("Add a tag", text: $tagInput)
                                .textFieldStyle(.plain)
                                .foregroundColor(.white)
                                .onSubmit { addTag() }

                            Button("Add") { addTag() }
                                .foregroundColor(PuffFreeTheme.accentTeal)
                        }
                        .padding()
                        .background(PuffFreeTheme.backgroundElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        if !tags.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag)
                                        Button {
                                            tags.removeAll { $0 == tag }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption2)
                                        }
                                    }
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
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
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveEntry() }
                        .foregroundColor(PuffFreeTheme.accentTeal)
                        .fontWeight(.semibold)
                        .disabled(body_.isEmpty)
                }
            }
        }
    }

    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
        tagInput = ""
    }

    private func saveEntry() {
        let entry = JournalEntry(
            title: title,
            body: body_,
            mood: selectedMood,
            tags: tags
        )
        modelContext.insert(entry)

        // Integrate gamification - award XP for journaling
        if gamificationViewModel == nil {
            gamificationViewModel = GamificationViewModel(modelContext: modelContext)
        }

        if let gamVM = gamificationViewModel {
            let xpAmount = 50 + (tags.count * 10) // Extra XP for tagging
            gamVM.addXP(xpAmount, source: "journalEntry")

            // Update quest progress for journal entries
            for quest in gamVM.quests {
                if quest.type == .journalEntry && !quest.isCompleted {
                    quest.progress += 1
                    if quest.progress >= quest.targetProgress {
                        quest.isCompleted = true
                        quest.completedDate = Date()
                    }
                }
            }
        }

        HapticManager.notification(.success)
        dismiss()
    }
}

// Simple flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            maxHeight = max(maxHeight, y + rowHeight)
        }

        return (CGSize(width: maxWidth, height: maxHeight), positions)
    }
}
