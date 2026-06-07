import SwiftUI
import RevenueCat

// MARK: - Paywall plan config
// Trial truth table (matches App Store Connect configuration):
//   Weekly   → $6.99/wk   3-day free trial
//   Monthly  → $14.99/mo  3-day free trial
//   Yearly   → $49.99/yr  3-day free trial  ← BEST VALUE
//   Lifetime → $89.99     NO trial (one-time)

struct PaywallView: View {
    @Environment(\.subscriptionViewModel) private var viewModel
    @State private var selectedID   = ""
    @State private var showRestore  = false
    @State private var restoreMsg   = ""

    // Entrance animations
    @State private var headerIn  = false
    @State private var featsIn   = false
    @State private var plansIn   = false
    @State private var ctaIn     = false
    @State private var crownPulse = false

    // Shimmer
    @State private var shimX: CGFloat = -0.4

    var onDismiss: (() -> Void)?

    // MARK: - Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Background ──────────────────────────────────────
                Color(hex: "060D12").ignoresSafeArea()

                FloatingOrb(color: Color(hex: "0D9B6B"), size: 320, xOffset: -130,
                            yRange: 25, duration: 5.5, startDelay: 0)
                    .offset(y: -geo.size.height * 0.28)

                FloatingOrb(color: Color(hex: "7C3AED"), size: 220, xOffset: 120,
                            yRange: 20, duration: 7.0, startDelay: 1.0)
                    .offset(y: geo.size.height * 0.1)

                // ── Content (scrollable so it works on every screen size,
                //    including iPhone apps run on iPad) ───────────────
                ScrollView {
                    VStack(spacing: 0) {

                        // ── Header ──────────────────────────────────
                        paywallHeader(geo: geo)

                        // ── Feature rows ────────────────────────────
                        featureList
                            .padding(.horizontal, 24)
                            .padding(.top, 14)
                            .opacity(featsIn ? 1 : 0)
                            .offset(y: featsIn ? 0 : 10)
                            .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.12), value: featsIn)

                        // ── Plan cards ──────────────────────────────
                        plansSection
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .opacity(plansIn ? 1 : 0)
                            .offset(y: plansIn ? 0 : 14)
                            .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.22), value: plansIn)
                    }
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)
                // CTA + legal links stay pinned and always reachable.
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    ctaSection(geo: geo)
                        .background(Color(hex: "060D12").opacity(0.97))
                }

                // ── Dismiss button ──────────────────────────────────
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
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) { headerIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { featsIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { plansIn = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { ctaIn   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)  { crownPulse = true }
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

    // MARK: - Header

    @ViewBuilder
    private func paywallHeader(geo: GeometryProxy) -> some View {
        VStack(spacing: 4) {
            // Crown icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "0D9B6B").opacity(0.3), .clear],
                            center: .center, startRadius: 0, endRadius: 30
                        )
                    )
                    .frame(width: 64, height: 64)
                    .scaleEffect(crownPulse ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: crownPulse)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "0D9B6B").opacity(0.25), Color(hex: "064028").opacity(0.4)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle().stroke(
                            LinearGradient(
                                colors: [Color(hex: "0D9B6B").opacity(0.6), Color(hex: "FFD700").opacity(0.3)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                    )

                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
            }

            Text("Unlock Your")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "0D9B6B"), Color(hex: "34D399")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )

            Text("Full Phoenix")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
        }
        .padding(.top, geo.safeAreaInsets.top + 12)
        .scaleEffect(headerIn ? 1 : 0.85)
        .opacity(headerIn ? 1 : 0)
        .animation(.spring(response: 0.55, dampingFraction: 0.68), value: headerIn)
    }

    // MARK: - Feature rows (icon circle + text + checkmark)

    private var featureList: some View {
        VStack(spacing: 10) {
            PaywallFeatureRow(icon: "lungs.fill",             color: Color(hex: "0D9B6B"), text: "Health recovery timeline & milestones")
            PaywallFeatureRow(icon: "trophy.fill",            color: Color(hex: "F59E0B"), text: "Quests, XP, badges & level system")
            PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", color: Color(hex: "6366F1"), text: "Advanced craving insights & analytics")
            PaywallFeatureRow(icon: "book.fill",              color: Color(hex: "EC4899"), text: "Private journal & daily check-ins")
        }
    }

    // MARK: - Plan cards

    @ViewBuilder
    private var plansSection: some View {
        VStack(spacing: 8) {
            if viewModel.isLoading && viewModel.currentOfferings == nil {
                ProgressView().tint(Color(hex: "0D9B6B")).frame(maxWidth: .infinity).padding(.vertical, 20)
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

    // MARK: - CTA

    @ViewBuilder
    private func ctaSection(geo: GeometryProxy) -> some View {
        VStack(spacing: 8) {
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
                        HStack(spacing: 8) {
                            Text(ctaTitle)
                                .font(.system(size: 17, weight: .bold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 14, weight: .bold))
                        }
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
                .frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "0D9B6B"), Color(hex: "06B6A0")],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color(hex: "0D9B6B").opacity(0.45), radius: 14, y: 5)
            }
            .disabled(viewModel.isLoading)
            .accessibilityIdentifier("paywall_cta")

            // Trial terms
            Text(trialTerms)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            // Auto-renew disclosure (App Store Guideline 3.1.2)
            Text(autoRenewDisclosure)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.3))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Legal links (required by 3.1.2): Terms of Use · Privacy Policy
            HStack(spacing: 6) {
                Link(destination: AppConstants.Legal.termsOfUseURL) {
                    Text("Terms of Use")
                        .font(.system(size: 10)).foregroundColor(.white.opacity(0.5))
                }
                footerDot
                Link(destination: AppConstants.Legal.privacyPolicyURL) {
                    Text("Privacy Policy")
                        .font(.system(size: 10)).foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(.top, 1)

            // Restore · Maybe Later
            HStack(spacing: 6) {
                Button {
                    Task {
                        await viewModel.restore()
                        restoreMsg = viewModel.isPro
                            ? "Purchases restored successfully!"
                            : "No active subscription found."
                        showRestore = true
                    }
                } label: {
                    Text("Restore Purchase")
                        .font(.system(size: 10)).foregroundColor(.white.opacity(0.4))
                }
                .disabled(viewModel.isLoading)

                if onDismiss != nil {
                    footerDot
                    Button { onDismiss?() } label: {
                        Text("Maybe Later")
                            .font(.system(size: 10)).foregroundColor(.white.opacity(0.3))
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, max(geo.safeAreaInsets.bottom, 12) + 4)
        .opacity(ctaIn ? 1 : 0)
        .offset(y: ctaIn ? 0 : 14)
        .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.32), value: ctaIn)
    }

    // MARK: - Helpers

    private func setDefaultSelection() {
        if let annual = viewModel.currentOfferings?.current?.annual {
            selectedID = annual.identifier
        } else if let monthly = viewModel.currentOfferings?.current?.monthly {
            selectedID = monthly.identifier
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
        case .weekly:   return "Start 3-Day Free Trial"
        case .annual:   return "Start 3-Day Free Trial"
        case .monthly:  return "Start 3-Day Free Trial"
        case .lifetime: return "Get Lifetime Access"
        default:        return "Start Free Trial"
        }
    }

    private var footerDot: some View {
        Text("·").font(.system(size: 10)).foregroundColor(.white.opacity(0.25))
    }

    // Auto-renew disclosure required by App Store Guideline 3.1.2.
    private var autoRenewDisclosure: String {
        guard let pkg = resolvedPackage(), pkg.packageType != .lifetime else {
            return "One-time purchase charged to your Apple Account. No subscription, no auto-renewal."
        }
        return "Payment is charged to your Apple Account at confirmation of purchase. The subscription renews automatically at the same price unless canceled at least 24 hours before the end of the current period. Manage or cancel anytime in your Apple Account settings."
    }

    private var trialTerms: String {
        guard let pkg = resolvedPackage() else { return "Cancel anytime." }
        switch pkg.packageType {
        case .weekly:   return "3-day free trial, then \(pkg.localizedPriceString)/week. Cancel anytime."
        case .annual:   return "3-day free trial, then \(pkg.localizedPriceString)/year. Cancel anytime."
        case .monthly:  return "3-day free trial, then \(pkg.localizedPriceString)/month. Cancel anytime."
        case .lifetime: return "One-time purchase of \(pkg.localizedPriceString). No subscription."
        default:        return "Cancel anytime."
        }
    }

    private func orderedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.weekly, .monthly, .annual, .lifetime]
        return order.compactMap { t in offering.availablePackages.first { $0.packageType == t } }
    }

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

    private var fallbackPlans: [FallbackPlan] {
        [
            FallbackPlan(id: "wk", title: "Weekly",   price: "$6.99",  period: "/wk", subNote: "3-Day Free Trial",            badge: nil,          isBest: false),
            FallbackPlan(id: "mo", title: "Monthly",  price: "$14.99", period: "/mo", subNote: "3-Day Free Trial",            badge: nil,          isBest: false),
            FallbackPlan(id: "yr", title: "Yearly",   price: "$49.99", period: "/yr", subNote: "3-Day Free Trial",            badge: "BEST VALUE", isBest: true),
            FallbackPlan(id: "lt", title: "Lifetime",  price: "$89.99", period: "",    subNote: "Pay once, use forever",       badge: "One-Time",   isBest: false)
        ]
    }
}

// MARK: - Feature Row

private struct PaywallFeatureRow: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: "0D9B6B"))
        }
    }
}

// MARK: - Supporting types

struct FallbackPlan {
    let id: String
    let title: String
    let price: String
    let period: String
    let subNote: String
    let badge: String?
    let isBest: Bool
}

// MARK: - Live RC plan card

struct PaywallPlanCard: View {
    let package: Package
    let isSelected: Bool
    let savingsNote: String?
    let onTap: () -> Void

    private var isBestValue: Bool { package.packageType == .annual }
    private var isLifetime:  Bool { package.packageType == .lifetime }

    private var title: String {
        switch package.packageType {
        case .weekly:   return "Weekly"
        case .monthly:  return "Monthly"
        case .annual:   return "Yearly"
        case .lifetime: return "Lifetime"
        default:        return package.identifier
        }
    }

    private var price: String {
        package.localizedPriceString
    }

    private var period: String {
        switch package.packageType {
        case .weekly:   return "/wk"
        case .monthly:  return "/mo"
        case .annual:   return "/yr"
        default:        return ""
        }
    }

    private var subNote: String {
        if isLifetime { return "Pay once, use forever" }
        if package.packageType == .annual {
            if let sav = savingsNote { return "3-Day Free Trial  ·  \(sav)" }
            return "3-Day Free Trial"
        }
        return "3-Day Free Trial"
    }

    private var badgeText: String? {
        if isBestValue { return "BEST VALUE" }
        if isLifetime  { return "One-Time" }
        return nil
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // Left side: title + badge + sub-note
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)

                        if let badge = badgeText {
                            Text(badge)
                                .font(.system(size: 8, weight: .heavy))
                                .foregroundColor(isBestValue ? Color(hex: "1A1A0A") : .white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(
                                    isBestValue
                                        ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                                                                        startPoint: .leading, endPoint: .trailing))
                                        : AnyShapeStyle(Color.white.opacity(0.15))
                                )
                                .clipShape(Capsule())
                        }
                    }

                    HStack(spacing: 4) {
                        if !isLifetime {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: "34D399"))
                        }
                        Text(subNote)
                            .font(.system(size: 11))
                            .foregroundColor(isLifetime ? .white.opacity(0.45) : Color(hex: "34D399"))
                    }
                }

                Spacer()

                // Right side: price
                VStack(alignment: .trailing, spacing: 0) {
                    Text(price)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    if !period.isEmpty {
                        Text(period)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.45))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                        ? Color.white.opacity(0.08)
                        : Color.white.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected
                            ? (isBestValue
                                ? Color(hex: "FFD700")
                                : Color(hex: "0D9B6B"))
                            : Color.white.opacity(0.08),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fallback plan card

struct PaywallFallbackPlanCard: View {
    let plan: FallbackPlan
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text(plan.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    if let badge = plan.badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .heavy))
                            .foregroundColor(plan.isBest ? Color(hex: "1A1A0A") : .white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                plan.isBest
                                    ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "FFD700"), Color(hex: "F59E0B")],
                                                                    startPoint: .leading, endPoint: .trailing))
                                    : AnyShapeStyle(Color.white.opacity(0.15))
                            )
                            .clipShape(Capsule())
                    }
                }
                Text(plan.subNote)
                    .font(.system(size: 11))
                    .foregroundColor(plan.isBest ? Color(hex: "34D399") : .white.opacity(0.45))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 0) {
                Text(plan.price)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                if !plan.period.isEmpty {
                    Text(plan.period)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(isSelected ? Color.white.opacity(0.08) : Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected
                        ? (plan.isBest ? Color(hex: "FFD700") : Color(hex: "0D9B6B"))
                        : Color.white.opacity(0.08),
                    lineWidth: isSelected ? 1.5 : 1
                )
        )
    }
}
