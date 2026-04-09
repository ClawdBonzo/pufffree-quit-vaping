import SwiftUI
import RevenueCat

// MARK: - Paywall plan config
// Trial truth table (matches App Store Connect configuration):
//   Weekly   → $4.99/wk   NO trial
//   Monthly  → $9.99/mo   3-day free trial  ← BEST VALUE
//   Yearly   → $49.99/yr  3-day free trial
//   Lifetime → $79.99     NO trial (one-time)

struct PaywallView: View {
    @State private var viewModel    = SubscriptionViewModel()
    @State private var selectedID   = ""           // package identifier
    @State private var showRestore  = false
    @State private var restoreMsg   = ""

    // Entrance animations
    @State private var headerIn  = false
    @State private var proofIn   = false
    @State private var plansIn   = false
    @State private var featsIn   = false
    @State private var ctaIn     = false
    @State private var crownPulse = false

    // Shimmer
    @State private var shimX: CGFloat = -0.4

    var onDismiss: (() -> Void)?

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Background ──────────────────────────────────────────
                Color(hex: "060D12").ignoresSafeArea()

                // Ambient orbs (lower-opacity for subtlety)
                FloatingOrb(color: Color(hex: "0D9B6B"), size: 360, xOffset: -130,
                            yRange: 30, duration: 5.5, startDelay: 0)
                    .offset(y: -geo.size.height * 0.3)

                FloatingOrb(color: Color(hex: "7C3AED"), size: 260, xOffset: 120,
                            yRange: 24, duration: 7.0, startDelay: 1.0)
                    .offset(y: geo.size.height * 0.05)

                FloatingOrb(color: Color(hex: "FFD700"), size: 160, xOffset: -40,
                            yRange: 18, duration: 6.5, startDelay: 1.8)
                    .offset(y: geo.size.height * 0.38)

                // ── Content ─────────────────────────────────────────────
                VStack(spacing: 0) {

                    // ── Compact header ──────────────────────────────────
                    compactHeader(geo: geo)

                    // ── Social proof ────────────────────────────────────
                    SocialProofBar()
                        .padding(.top, 8)
                        .opacity(proofIn ? 1 : 0)
                        .offset(y: proofIn ? 0 : 8)
                        .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.18), value: proofIn)

                    // ── Plan cards ──────────────────────────────────────
                    plansSection
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .opacity(plansIn ? 1 : 0)
                        .offset(y: plansIn ? 0 : 20)
                        .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.28), value: plansIn)

                    // ── Feature bullets ─────────────────────────────────
                    featureRow
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .opacity(featsIn ? 1 : 0)
                        .offset(y: featsIn ? 0 : 12)
                        .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.38), value: featsIn)

                    Spacer(minLength: 0)

                    // ── CTA ─────────────────────────────────────────────
                    ctaSection(geo: geo)
                }

                // Dismiss button
                if onDismiss != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Button { onDismiss?() } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.1))
                                        .frame(width: 30, height: 30)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .padding(.trailing, 18)
                            .padding(.top, geo.safeAreaInsets.top + 8)
                        }
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.refresh()
            setDefaultSelection()
        }
        .onAppear {
            // Staggered entrance
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { headerIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08)  { proofIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18)  { plansIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28)  { featsIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.38)  { ctaIn   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)   { crownPulse = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation(.linear(duration: 2.6).repeatForever(autoreverses: false)) {
                    shimX = 1.4
                }
            }
        }
        .alert("Restore Purchases", isPresented: $showRestore) {
            Button("OK", role: .cancel) {}
        } message: { Text(restoreMsg) }
        .alert("Purchase Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: { Text(viewModel.errorMessage ?? "") }
    }

    // MARK: - Compact header (~100px tall)

    @ViewBuilder
    private func compactHeader(geo: GeometryProxy) -> some View {
        VStack(spacing: 6) {
            // Crown icon with pulsing glow
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "0D9B6B").opacity(0.35), .clear],
                            center: .center, startRadius: 0, endRadius: 44
                        )
                    )
                    .frame(width: 88, height: 88)
                    .scaleEffect(crownPulse ? 1.12 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: crownPulse)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "0D9B6B").opacity(0.3), Color(hex: "064028").opacity(0.5)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                colors: [Color(hex: "0D9B6B").opacity(0.7), Color(hex: "FFD700").opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                    )

                Image(systemName: "crown.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }

            Text("PuffFree Pro")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Quit for good. For real this time.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
        }
        .padding(.top, geo.safeAreaInsets.top + 10)
        .scaleEffect(headerIn ? 1 : 0.82)
        .opacity(headerIn ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.68), value: headerIn)
    }

    // MARK: - Plan cards

    @ViewBuilder
    private var plansSection: some View {
        VStack(spacing: 7) {
            if viewModel.isLoading && viewModel.currentOfferings == nil {
                ProgressView().tint(Color(hex: "0D9B6B")).frame(maxWidth: .infinity).padding(.vertical, 24)
            } else if let offering = viewModel.currentOfferings?.current {
                let ordered = orderedPackages(from: offering)
                ForEach(ordered, id: \.identifier) { pkg in
                    PaywallPlanCard(
                        package: pkg,
                        isSelected: selectedID == pkg.identifier,
                        savingsNote: yearlySavings(pkg, in: ordered),
                        onTap: {
                            withAnimation(.spring(response: 0.26, dampingFraction: 0.65)) {
                                selectedID = pkg.identifier
                            }
                            HapticManager.selection()
                        }
                    )
                }
            } else {
                ForEach(fallbackPlans, id: \.id) { plan in
                    PaywallFallbackPlanCard(plan: plan, isSelected: plan.isBest)
                }
            }
        }
    }

    // MARK: - Feature row (compact horizontal)

    private var featureRow: some View {
        HStack(spacing: 0) {
            FeaturePill(icon: "lungs.fill",             label: "Health")
            FeaturePill(icon: "dollarsign.circle.fill", label: "Savings")
            FeaturePill(icon: "trophy.fill",            label: "Quests & XP")
            FeaturePill(icon: "brain.head.profile",     label: "Insights")
        }
    }

    // MARK: - CTA section

    @ViewBuilder
    private func ctaSection(geo: GeometryProxy) -> some View {
        VStack(spacing: 10) {
            // Main purchase button
            Button {
                Task {
                    guard !viewModel.isLoading else { return }
                    if let pkg = resolvedPackage() {
                        await viewModel.purchase(pkg)
                        if viewModel.isPro { onDismiss?() }
                    }
                }
            } label: {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView().tint(.black)
                    } else {
                        Text(ctaTitle)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.black)
                    }
                    // Shimmer
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.25), .clear],
                        startPoint: UnitPoint(x: shimX - 0.35, y: 0),
                        endPoint: UnitPoint(x: shimX + 0.35, y: 0)
                    ).allowsHitTesting(false)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "0D9B6B"), Color(hex: "06B6A0")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: Color(hex: "0D9B6B").opacity(0.5), radius: 18, y: 6)
            }
            .disabled(viewModel.isLoading)

            HStack(spacing: 22) {
                Button {
                    Task {
                        await viewModel.restore()
                        restoreMsg = viewModel.isPro
                            ? "Purchases restored successfully!"
                            : "No active subscription found."
                        showRestore = true
                    }
                } label: {
                    Text("Restore")
                        .font(.footnote).foregroundColor(.white.opacity(0.55))
                }
                .disabled(viewModel.isLoading)

                if let onDismiss {
                    Button { onDismiss() } label: {
                        Text("Maybe Later")
                            .font(.footnote).foregroundColor(.white.opacity(0.35))
                    }
                }
            }

            Text("Auto-renews unless cancelled. See Terms & Privacy.")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, max(geo.safeAreaInsets.bottom, 16) + 4)
        .opacity(ctaIn ? 1 : 0)
        .offset(y: ctaIn ? 0 : 16)
        .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.38), value: ctaIn)
    }

    // MARK: - Helpers

    private func setDefaultSelection() {
        // Default to Monthly (BEST VALUE for trial + best conversion)
        if let monthly = viewModel.currentOfferings?.current?.monthly {
            selectedID = monthly.identifier
        } else if let annual = viewModel.currentOfferings?.current?.annual {
            selectedID = annual.identifier
        } else {
            selectedID = viewModel.currentOfferings?.current?.availablePackages.first?.identifier ?? ""
        }
    }

    private func resolvedPackage() -> Package? {
        viewModel.currentOfferings?.current?.availablePackages
            .first { $0.identifier == selectedID }
        ?? viewModel.currentOfferings?.current?.availablePackages.first
    }

    private var ctaTitle: String {
        guard let pkg = resolvedPackage() else { return "Start Free Trial" }
        switch pkg.packageType {
        case .weekly:   return "Subscribe Weekly — \(pkg.localizedPriceString)"
        case .lifetime: return "Get Lifetime Access — \(pkg.localizedPriceString)"
        default:        return "Start 3-Day Free Trial"
        }
    }

    private func orderedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.weekly, .monthly, .annual, .lifetime]
        return order.compactMap { t in offering.availablePackages.first { $0.packageType == t } }
    }

    /// Compute yearly savings vs monthly, e.g. "Save 58%"
    private func yearlySavings(_ pkg: Package, in packages: [Package]) -> String? {
        guard pkg.packageType == .annual,
              let monthly = packages.first(where: { $0.packageType == .monthly })
        else { return nil }
        let annualizedMonthly = NSDecimalNumber(decimal: monthly.storeProduct.price).doubleValue * 12
        let annualPrice = NSDecimalNumber(decimal: pkg.storeProduct.price).doubleValue
        guard annualizedMonthly > 0 else { return nil }
        let pct = Int(((annualizedMonthly - annualPrice) / annualizedMonthly * 100).rounded())
        return "Save \(pct)%"
    }

    // Fallback plans shown when RC offerings haven't loaded
    private var fallbackPlans: [FallbackPlan] {
        [
            FallbackPlan(id: "wk", title: "Weekly",   price: "$4.99/wk", subNote: "$0.71/day",            badge: nil,        badgeIsGold: false, hasTrial: false, isBest: false),
            FallbackPlan(id: "mo", title: "Monthly",  price: "$9.99/mo", subNote: "3-day free trial",      badge: "BEST VALUE", badgeIsGold: true, hasTrial: true,  isBest: true),
            FallbackPlan(id: "yr", title: "Yearly",   price: "$49.99/yr",subNote: "3-day free trial · save 58%", badge: nil, badgeIsGold: false, hasTrial: true,  isBest: false),
            FallbackPlan(id: "lt", title: "Lifetime", price: "$79.99",   subNote: "One-time purchase",     badge: nil,        badgeIsGold: false, hasTrial: false, isBest: false)
        ]
    }
}

// MARK: - Supporting types

struct FallbackPlan {
    let id: String
    let title: String
    let price: String
    let subNote: String
    let badge: String?
    let badgeIsGold: Bool
    let hasTrial: Bool
    let isBest: Bool
}

// MARK: - Live RC plan card

struct PaywallPlanCard: View {
    let package: Package
    let isSelected: Bool
    let savingsNote: String?
    let onTap: () -> Void

    private var isBestValue: Bool { package.packageType == .monthly }
    private var isLifetime:  Bool { package.packageType == .lifetime }
    private var isWeekly:    Bool { package.packageType == .weekly }
    private var hasTrial:    Bool { package.packageType == .monthly || package.packageType == .annual }

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
        default:        return package.localizedPriceString
        }
    }

    private var subNote: String {
        if isLifetime { return "One-time purchase" }
        if isWeekly   { return "$0.71/day" }
        if let sav = savingsNote { return "3-day free trial · \(sav)" }
        return "3-day free trial included"
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topLeading) {
                // Card background
                cardBackground

                HStack(spacing: 11) {
                    // Radio indicator
                    radioIndicator

                    // Labels
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 6) {
                            Text(title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            if isBestValue {
                                bestValueBadge
                            }
                        }
                        Text(subNote)
                            .font(.system(size: 11))
                            .foregroundColor(hasTrial
                                ? Color(hex: "34D399")
                                : .white.opacity(0.42))
                    }

                    Spacer()

                    Text(priceLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
            }
            .scaleEffect(isSelected ? 1.016 : 1.0)
            .animation(.spring(response: 0.26, dampingFraction: 0.65), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder private var cardBackground: some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "0D2820"), Color(hex: "091C14")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isBestValue
                                ? LinearGradient(colors: [Color(hex: "0D9B6B"), Color(hex: "34D399")],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color(hex: "0D9B6B").opacity(0.55), Color(hex: "0D9B6B").opacity(0.3)],
                                                 startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: Color(hex: "0D9B6B").opacity(0.22), radius: 10, y: 3)
        } else {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private var radioIndicator: some View {
        ZStack {
            Circle()
                .stroke(
                    isSelected ? Color(hex: "0D9B6B") : Color.white.opacity(0.22),
                    lineWidth: isSelected ? 2 : 1.5
                )
                .frame(width: 20, height: 20)
            if isSelected {
                Circle()
                    .fill(Color(hex: "0D9B6B"))
                    .frame(width: 10, height: 10)
            }
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.7), value: isSelected)
    }

    private var bestValueBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "crown.fill")
                .font(.system(size: 7, weight: .bold))
            Text("BEST VALUE")
                .font(.system(size: 8, weight: .bold))
        }
        .foregroundColor(Color(hex: "1A1A0A"))
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            LinearGradient(
                colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                startPoint: .leading, endPoint: .trailing
            )
        )
        .clipShape(Capsule())
    }
}

// MARK: - Fallback plan card

struct PaywallFallbackPlanCard: View {
    let plan: FallbackPlan
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 11) {
            // Radio
            ZStack {
                Circle()
                    .stroke(isSelected ? Color(hex: "0D9B6B") : Color.white.opacity(0.22), lineWidth: isSelected ? 2 : 1.5)
                    .frame(width: 20, height: 20)
                if isSelected {
                    Circle().fill(Color(hex: "0D9B6B")).frame(width: 10, height: 10)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(plan.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    if let badge = plan.badge {
                        HStack(spacing: 3) {
                            if plan.badgeIsGold {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 7, weight: .bold))
                            }
                            Text(badge)
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundColor(plan.badgeIsGold ? Color(hex: "1A1A0A") : .black)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            plan.badgeIsGold
                                ? LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                                                 startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color(hex: "0D9B6B"), Color(hex: "06B6A0")],
                                                 startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                    }
                }
                Text(plan.subNote)
                    .font(.system(size: 11))
                    .foregroundColor(plan.hasTrial
                        ? Color(hex: "34D399")
                        : .white.opacity(0.42))
            }

            Spacer()

            Text(plan.price)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                        ? LinearGradient(colors: [Color(hex: "0D2820"), Color(hex: "091C14")],
                                         startPoint: .topLeading, endPoint: .bottomTrailing)
                        : LinearGradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.05)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: "0D9B6B").opacity(0.65) : Color.white.opacity(0.08),
                            lineWidth: isSelected ? 1.5 : 1)
            }
        )
        .shadow(color: isSelected ? Color(hex: "0D9B6B").opacity(0.2) : .clear, radius: 10, y: 3)
    }
}

// MARK: - Feature pill

private struct FeaturePill: View {
    let icon: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "0D9B6B"), Color(hex: "34D399")],
                        startPoint: .top, endPoint: .bottom
                    )
                )
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
        .padding(.horizontal, 3)
    }
}
