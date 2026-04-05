import SwiftUI

struct PuffFreeTabBar: View {
    @Binding var selectedTab: MainTabView.TabItem

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTabView.TabItem.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                    HapticManager.selection()
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20, weight: selectedTab == tab ? .bold : .regular))
                            .symbolEffect(.bounce, value: selectedTab == tab)

                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(selectedTab == tab ? PuffFreeTheme.accentTeal : PuffFreeTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            PuffFreeTheme.backgroundSecondary
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.white.opacity(0.1)),
                    alignment: .top
                )
        )
    }
}
