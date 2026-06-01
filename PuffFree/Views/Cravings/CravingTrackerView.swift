import SwiftUI
import SwiftData

struct CravingTrackerView: View {
    @Query(sort: \CravingLog.timestamp, order: .reverse) private var logs: [CravingLog]
    @Query private var profiles: [UserProfile]
    @State private var viewModel = CravingViewModel()
    @State private var showLogSheet = false
    @State private var showPaywall = false
    @Environment(\.modelContext) private var modelContext
    @Environment(\.subscriptionViewModel) private var subscriptionVM

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
                        // Resist Rate — gated for free users
                        if subscriptionVM.isPro {
                            CravingStatCard(
                                title: "Resist Rate",
                                value: "\(Int(viewModel.resistRate * 100))%",
                                icon: "shield.fill",
                                color: PuffFreeTheme.success
                            )
                        } else {
                            Button { showPaywall = true } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "shield.fill")
                                        .foregroundColor(PuffFreeTheme.success.opacity(0.5))
                                    HStack(spacing: 2) {
                                        Image(systemName: "lock.fill")
                                            .font(.system(size: 10))
                                        Text("PRO")
                                            .font(.system(size: 10, weight: .bold))
                                    }
                                    .foregroundColor(PuffFreeTheme.phoenixGold)
                                    Text("Resist Rate")
                                        .font(.caption2)
                                        .foregroundColor(PuffFreeTheme.textSecondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(PuffFreeTheme.backgroundCard)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(PuffFreeTheme.phoenixGold.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Top trigger — gated for free users
                    if subscriptionVM.isPro, let trigger = viewModel.topTrigger {
                        GlassCard {
                            HStack {
                                Image(systemName: trigger.icon)
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Top Trigger")
                                        .font(.caption)
                                        .foregroundColor(PuffFreeTheme.textSecondary)
                                    Text(trigger.displayName)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(PuffFreeTheme.textTertiary)
                            }
                        }
                        .padding(.horizontal, 16)
                    } else if !subscriptionVM.isPro, viewModel.topTrigger != nil {
                        Button { showPaywall = true } label: {
                            GlassCard {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title3)
                                        .foregroundStyle(PuffFreeTheme.flameGradient)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Top Trigger")
                                            .font(.caption)
                                            .foregroundColor(PuffFreeTheme.textSecondary)
                                        Text("Unlock Insights")
                                            .font(.headline)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()
                                    Text("PRO")
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundColor(PuffFreeTheme.phoenixGold)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(PuffFreeTheme.phoenixGold.opacity(0.15))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .buttonStyle(.plain)
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
            .sheet(isPresented: $showPaywall) {
                PaywallView(onDismiss: { showPaywall = false })
                    .environment(\.subscriptionViewModel, subscriptionVM)
            }
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
