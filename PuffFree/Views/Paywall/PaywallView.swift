import SwiftUI
import RevenueCat

struct PaywallView: View {
    @State private var viewModel = SubscriptionViewModel()
    @State private var selectedPackage: Package? = nil
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    var onDismiss: (() -> Void)?

    var body: some View {
        ZStack {
            PuffFreeTheme.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    ZStack(alignment: .topTrailing) {
                        Image("OnboardingPaywall")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [.clear, PuffFreeTheme.backgroundPrimary],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        if onDismiss != nil {
                            Button {
                                onDismiss?()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding()
                            }
                        }
                    }

                    VStack(spacing: 8) {
                        Text("Go Pro")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Start your 3-day free trial.\nCancel anytime.")
                            .font(.subheadline)
                            .foregroundColor(PuffFreeTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                    // Feature highlights
                    VStack(spacing: 12) {
                        PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Advanced health & savings analytics")
                        PaywallFeatureRow(icon: "brain.head.profile", text: "AI-powered craving insights")
                        PaywallFeatureRow(icon: "bell.badge.fill", text: "Smart milestone celebrations")
                        PaywallFeatureRow(icon: "lock.open.fill", text: "Unlock all app features, forever")
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    // Packages
                    if viewModel.isLoading && viewModel.currentOfferings == nil {
                        ProgressView()
                            .tint(PuffFreeTheme.accentTeal)
                            .padding(.vertical, 40)
                    } else if let offering = viewModel.currentOfferings?.current {
                        VStack(spacing: 10) {
                            ForEach(orderedPackages(from: offering), id: \.identifier) { package in
                                PaywallPackageCard(
                                    package: package,
                                    isSelected: selectedPackage?.identifier == package.identifier,
                                    onTap: { selectedPackage = package }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    } else {
                        // Fallback skeleton when no offerings loaded
                        VStack(spacing: 10) {
                            ForEach(fallbackPlans, id: \.title) { plan in
                                PaywallFallbackCard(plan: plan)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    // CTA
                    VStack(spacing: 14) {
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
                            .padding(.vertical, 16)
                            .background(PuffFreeTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(viewModel.isLoading)

                        Button {
                            Task {
                                await viewModel.restore()
                                restoreMessage = viewModel.isPro
                                    ? "Purchases restored successfully!"
                                    : "No active subscription found."
                                showRestoreAlert = true
                            }
                        } label: {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(PuffFreeTheme.textSecondary)
                        }
                        .disabled(viewModel.isLoading)

                        if let onDismiss {
                            Button {
                                onDismiss()
                            } label: {
                                Text("Maybe Later")
                                    .font(.caption)
                                    .foregroundColor(PuffFreeTheme.textTertiary)
                            }
                        }

                        Text("Subscriptions auto-renew unless cancelled. See Terms & Privacy.")
                            .font(.system(size: 10))
                            .foregroundColor(PuffFreeTheme.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
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
            // Pre-select monthly (best value)
            if let monthly = viewModel.currentOfferings?.current?.monthly {
                selectedPackage = monthly
            } else {
                selectedPackage = viewModel.currentOfferings?.current?.availablePackages.first
            }
        }
    }

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

    // Shown when RevenueCat offerings haven't loaded (e.g., no internet, first cold launch)
    private var fallbackPlans: [(title: String, price: String, badge: String?, isBest: Bool)] {
        [
            (title: "Weekly", price: "$4.99 / week", badge: "3-day free trial", isBest: false),
            (title: "Monthly", price: "$9.99 / month", badge: "3-day free trial", isBest: true),
            (title: "Yearly", price: "$49.99 / year", badge: "3-day free trial", isBest: false),
            (title: "Lifetime", price: "$79.99 once", badge: nil, isBest: false)
        ]
    }
}

// MARK: - Sub-views

struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(PuffFreeTheme.primaryGradient)
                .frame(width: 28)

            Text(text)
                .font(.subheadline)
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
        case .weekly:   return "\(package.localizedPriceString) / week"
        case .monthly:  return "\(package.localizedPriceString) / month"
        case .annual:   return "\(package.localizedPriceString) / year"
        case .lifetime: return "\(package.localizedPriceString) once"
        default:        return package.localizedPriceString
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? PuffFreeTheme.accentTeal : Color.white.opacity(0.2), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(PuffFreeTheme.accentTeal)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(PuffFreeTheme.accentTeal)
                                .clipShape(Capsule())
                        }
                    }

                    if !isLifetime {
                        Text("3-day free trial")
                            .font(.caption)
                            .foregroundColor(PuffFreeTheme.success)
                    }
                }

                Spacer()

                Text(priceLabel)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(PuffFreeTheme.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected
                                    ? (isBestValue ? PuffFreeTheme.accentTeal : Color.white.opacity(0.4))
                                    : Color.clear,
                                lineWidth: isBestValue && isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct PaywallFallbackCard: View {
    let plan: (title: String, price: String, badge: String?, isBest: Bool)

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .stroke(plan.isBest ? PuffFreeTheme.accentTeal : Color.white.opacity(0.2), lineWidth: 2)
                .frame(width: 22, height: 22)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(plan.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)

                    if plan.isBest {
                        Text("BEST VALUE")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(PuffFreeTheme.accentTeal)
                            .clipShape(Capsule())
                    }
                }

                if let badge = plan.badge {
                    Text(badge)
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.success)
                }
            }

            Spacer()

            Text(plan.price)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(PuffFreeTheme.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(PuffFreeTheme.backgroundCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(plan.isBest ? PuffFreeTheme.accentTeal : Color.clear, lineWidth: 2)
                )
        )
    }
}
