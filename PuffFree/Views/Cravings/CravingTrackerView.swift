import SwiftUI
import SwiftData

struct CravingTrackerView: View {
    @Query(sort: \CravingLog.timestamp, order: .reverse) private var logs: [CravingLog]
    @Query private var profiles: [UserProfile]
    @State private var viewModel = CravingViewModel()
    @State private var showLogSheet = false
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Stats row
                    HStack(spacing: 12) {
                        CravingStatCard(
                            title: "Today",
                            value: "\(viewModel.todayCravings)",
                            icon: "flame.fill",
                            color: .orange
                        )
                        CravingStatCard(
                            title: "This Week",
                            value: "\(viewModel.weekCravings)",
                            icon: "calendar",
                            color: PuffFreeTheme.info
                        )
                        CravingStatCard(
                            title: "Resist Rate",
                            value: "\(Int(viewModel.resistRate * 100))%",
                            icon: "shield.fill",
                            color: PuffFreeTheme.success
                        )
                    }
                    .padding(.horizontal, 16)

                    // Top trigger
                    if let trigger = viewModel.topTrigger {
                        GlassCard {
                            HStack {
                                Image(systemName: trigger.icon)
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Top Trigger")
                                        .font(.caption)
                                        .foregroundColor(PuffFreeTheme.textSecondary)
                                    Text(trigger.rawValue)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(PuffFreeTheme.textTertiary)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Quick log button
                    Button {
                        showLogSheet = true
                        HapticManager.impact(.medium)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Log a Craving")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(PuffFreeTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)

                    // Recent history
                    CravingHistoryView(logs: Array(logs.prefix(20)))
                        .padding(.horizontal, 16)

                    Spacer().frame(height: 100)
                }
                .padding(.top, 8)
            }
            .scrollIndicators(.hidden)
            .background(PuffFreeTheme.backgroundPrimary)
            .navigationTitle("Cravings")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showLogSheet) {
                LogCravingSheet()
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            viewModel.refresh(logs: logs)
        }
        .onChange(of: logs.count) {
            viewModel.refresh(logs: logs)
        }
    }
}

struct CravingStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(title)
                .font(.caption2)
                .foregroundColor(PuffFreeTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
