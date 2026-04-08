import SwiftUI

struct QuestListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GamificationViewModel?

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Daily Quests")
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if let viewModel = viewModel {
                    let completed = viewModel.getCompletedQuests().count
                    let active = viewModel.getActiveQuests().count
                    Text("\(completed)/\(completed + active)")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.accentTeal)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            if let viewModel = viewModel {
                let quests = viewModel.getActiveQuests()

                if quests.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 32))
                            .foregroundColor(PuffFreeTheme.accentTeal)

                        Text("All quests complete!")
                            .font(.headline)
                            .foregroundColor(.white)

                        Text("Come back tomorrow for more.")
                            .font(.caption)
                            .foregroundColor(PuffFreeTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(32)
                    .background(PuffFreeTheme.backgroundCard)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 12) {
                        ForEach(quests, id: \.id) { quest in
                            QuestRowView(quest: quest, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }

            Spacer()
        }
        .background(PuffFreeTheme.backgroundPrimary)
        .onAppear {
            if viewModel == nil {
                viewModel = GamificationViewModel(modelContext: modelContext)
                viewModel?.generateDailyQuests()
            }
        }
    }
}

struct QuestRowView: View {
    let quest: Quest
    let viewModel: GamificationViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: quest.type.icon)
                .font(.system(size: 18))
                .foregroundColor(PuffFreeTheme.accentTeal)
                .frame(width: 32, alignment: .center)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.type.rawValue)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(quest.questDescription)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // XP Reward + Complete Button
            VStack(alignment: .trailing, spacing: 8) {
                Text("+\(quest.xpReward) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(PuffFreeTheme.accentTeal)

                Button {
                    withAnimation {
                        viewModel.completeQuest(quest)
                    }
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(PuffFreeTheme.accentTeal)
                }
                .disabled(quest.isCompleted)
            }
        }
        .padding(12)
        .background(PuffFreeTheme.backgroundCard)
        .cornerRadius(8)
        .opacity(quest.isCompleted ? 0.5 : 1.0)
    }
}

#Preview {
    QuestListView()
        .preferredColorScheme(.dark)
}
