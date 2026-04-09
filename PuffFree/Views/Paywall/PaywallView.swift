import SwiftUI
import RevenueCat

struct PaywallView: View {
    @State private var viewModel = SubscriptionViewModel()
    @State private var selectedPackage: Package? = nil
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var glowPulse = false

    var onDismiss: (() -> Void)?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.12, blue: 0.08),
                        PuffFreeTheme.backgroundPrimary,
                        Color(red: 0.02, green: 0.08, blue: 0.12)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    // — Hero icon + dismiss
                    ZStack(alignment: .topTrailing) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(PuffFreeTheme.accentTeal.opacity(0.15))
                                    .frame(width: 80, height: 80)
                                    .scaleEffect(glowPulse ? 1.15 : 1.0)
                                    .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: glowPulse)

                                Image(systemName: "crown.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [PuffFreeTheme.accentTeal, Color(hex: "FFD700")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }

                            Text("Go Pro")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Start your 3-day free trial · Cancel anytime")
                                .font(.caption)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, geo.safeAreaInsets.top + 12)

                        if onDismiss != nil {
                            Button { onDismiss?() } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                            .padding(.trailing, 20)
                            .padding(.top, geo.safeAreaInsets.top + 12)
                        }
                    }

                    // — Features (compact horizontal rows)
                    VStack(spacing: 8) {
                        PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced health & savings analytics")
                        PaywallFeatureRow(icon: "brain.head.profile",        text: "AI-powered craving insights")
                        PaywallFeatureRow(icon: "bell.badge.fill",           text: "Smart milestone celebrations")
                        PaywallFeatureRow(icon: "lock.open.fill",            text: "Unlock all features, forever")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    // — Packages
                    VStack(spacing: 8) {
                        if viewModel.isLoading && viewModel.currentOfferings == nil {
                            ProgressView()
                                .tint(PuffFreeTheme.accentTeal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else if let offering = viewModel.currentOfferings?.current {
                            ForEach(orderedPackages(from: offering), id: \.identifier) { package in
                                PaywallPackageCard(
                                    package: package,
                                    isSelected: selectedPackage?.identifier == package.identifier,
                                    onTap: { withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { selectedPackage = package } }
                                )
                            }
                        } else {
                            ForEach(fallbackPlans, id: \.title) { plan in
                                PaywallFallbackCard(plan: plan)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    Spacer(minLength: 0)

                    // — CTA stack (pinned to bottom)
                    VStack(spacing: 10) {
                        Button {
                            Task {
                                if let pkg = selectedPackage {
                                    await viewModel.purchase(pkg)
                                } else if let first = viewModel.currentOfferings?.current?.availablePackages.first {
                                    await viewModel.purchase(first)
                                }
                                if viewModel.isPro { onDismiss?() }
                            }
                        } label: {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView().tint(.black)
                                } else {
                                    Text(ctaTitle)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(PuffFreeTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(viewModel.isLoading)

                        HStack(spacing: 20) {
                            Button {
                                Task {
                                    await viewModel.restore()
                                    restoreMessage = viewModel.isPro
                                        ? "Purchases restored successfully!"
                                        : "No active subscription found."
                                    showRestoreAlert = true
                                }
                            } label: {
                                Text("Restore")
                                    .font(.footnote)
                                    .foregroundColor(PuffFreeTheme.textSecondary)
                            }
                            .disabled(viewModel.isLoading)

                            if let onDismiss {
                                Button { onDismiss() } label: {
                                    Text("Maybe Later")
                                        .font(.footnote)
                                        .foregroundColor(PuffFreeTheme.textTertiary)
                                }
                            }
                        }

                        Text("Auto-renews unless cancelled. See Terms & Privacy.")
                            .font(.system(size: 9))
                            .foregroundColor(PuffFreeTheme.textTertiary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, max(geo.safeAreaInsets.bottom, 16) + 4)
                }
            }
        }
        .ignoresSafeArea()
        .alert("Restore Purchases", isPresented: $showRestoreAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(restoreMessage)
        }
        .alert("Purchase Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task {
            await viewModel.refresh()
            if let monthly = viewModel.currentOfferings?.current?.monthly {
                selectedPackage = monthly
            } else {
                selectedPackage = viewModel.currentOfferings?.current?.availablePackages.first
            }
        }
        .onAppear { glowPulse = true }
    }

    // MARK: - Helpers

    private var ctaTitle: String {
        guard let pkg = selectedPackage else { return "Start Free Trial" }
        switch pkg.packageType {
        case .lifetime: return "Buy Lifetime — \(pkg.localizedPriceString)"
        default: return "Start 3-Day Free Trial"
        }
    }

    private func orderedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.weekly, .monthly, .annual, .lifetime]
        return order.compactMap { type in
            offering.availablePackages.first { $0.packageType == type }
        }
    }

    private var fallbackPlans: [(title: String, price: String, badge: String?, isBest: Bool)] {
        [
            (title: "Weekly",   price: "$4.99/wk",   badge: "3-day free trial", isBest: false),
            (title: "Monthly",  price: "$9.99/mo",   badge: "3-day free trial", isBest: true),
            (title: "Yearly",   price: "$49.99/yr",  badge: "3-day free trial", isBest: false),
            (title: "Lifetime", price: "$79.99 once", badge: nil,               isBest: false)
        ]
    }
}

// MARK: - Sub-views

struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.footnote)
                .foregroundStyle(PuffFreeTheme.primaryGradient)
                .frame(width: 22)

            Text(text)
                .font(.footnote)
                .foregroundColor(PuffFreeTheme.textSecondary)

            Spacer()
        }
    }
}

struct PaywallPackageCard: View {
    let package: Package
    let isSelected: Bool
    let onTap: () -> Void

    private var isBestValue: Bool { package.packageType == .monthly }
    private var isLifetime: Bool { package.packageType == .lifetime }

    private var title: String {
        switch package.packageType {
        case .weekly:   return "Weekly"
        case .monthly:  return "Monthly"
        case .annual:   return "Yearly"
        case .lifetime: return "Lifetime"
        default:        return package.identifier
        }
    }

    private var priceLabel: String {
        switch package.packageType {
        case .weekly:   return "\(package.localizedPriceString)/wk"
        case .monthly:  return "\(package.localizedPriceString)/mo"
        case .annual:   return "\(package.localizedPriceString)/yr"
        case .lifetime: return "\(package.localizedPriceString)"
        default:        return package.localizedPriceString
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? PuffFreeTheme.accentTeal : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(PuffFreeTheme.accentTeal)
                            .frame(width: 11, height: 11)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.white)
                        if isBestValue {
                            Text("BEST")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(PuffFreeTheme.accentTeal)
                                .clipShape(Capsule())
                        }
                    }
                    if !isLifetime {
                        Text("3-day free trial")
                            .font(.caption2)
                            .foregroundColor(PuffFreeTheme.success)
                    }
                }

                Spacer()

                Text(priceLabel)
                    .font(.footnote).fontWeight(.medium)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected
                        ? PuffFreeTheme.backgroundCard.opacity(1.4)
                        : PuffFreeTheme.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected
                                    ? (isBestValue ? PuffFreeTheme.accentTeal : Color.white.opacity(0.35))
                                    : Color.clear,
                                lineWidth: isBestValue && isSelected ? 1.5 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.01 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

struct PaywallFallbackCard: View {
    let plan: (title: String, price: String, badge: String?, isBest: Bool)

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .stroke(plan.isBest ? PuffFreeTheme.accentTeal : Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 20, height: 20)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(plan.title)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                    if plan.isBest {
                        Text("BEST")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(PuffFreeTheme.accentTeal)
                            .clipShape(Capsule())
                    }
                }
                if let badge = plan.badge {
                    Text(badge)
                        .font(.caption2)
                        .foregroundColor(PuffFreeTheme.success)
                }
            }

            Spacer()

            Text(plan.price)
                .font(.footnote).fontWeight(.medium)
                .foregroundColor(PuffFreeTheme.textSecondary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(PuffFreeTheme.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(plan.isBest ? PuffFreeTheme.accentTeal : Color.clear, lineWidth: 1.5)
                )
        )
    }
}
