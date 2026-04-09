import SwiftUI
import RevenueCat

struct PaywallView: View {
    @State private var viewModel = SubscriptionViewModel()
    @State private var selectedPackage: Package? = nil
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    // Entrance animations
    @State private var heroVisible   = false
    @State private var titleVisible  = false
    @State private var proofVisible  = false
    @State private var featVisible   = false
    @State private var plansVisible  = false
    @State private var ctaVisible    = false

    // Shimmer
    @State private var shimmerPos: CGFloat = -0.4

    var onDismiss: (() -> Void)?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ── Background ────────────────────────────────────────────
                Color(hex: "060A14").ignoresSafeArea()

                // Ambient orbs
                FloatingOrb(color: PuffFreeTheme.accentTeal, size: 320, xOffset: -140,
                            yRange: 28, duration: 5.0, startDelay: 0)
                    .offset(y: -geo.size.height * 0.28)

                FloatingOrb(color: Color(hex: "7C3AED"), size: 240, xOffset: 110,
                            yRange: 22, duration: 6.5, startDelay: 0.8)
                    .offset(y: geo.size.height * 0.12)

                FloatingOrb(color: PuffFreeTheme.success, size: 180, xOffset: -50,
                            yRange: 18, duration: 7.2, startDelay: 1.5)
                    .offset(y: geo.size.height * 0.42)

                // ── Content ───────────────────────────────────────────────
                VStack(spacing: 0) {

                    // Hero image — fills top portion with gradient fade at bottom
                    ZStack(alignment: .bottom) {
                        Image("OnboardingPaywall")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width,
                                   height: geo.size.height * 0.24)
                            .clipped()
                            .scaleEffect(heroVisible ? 1 : 1.06)
                            .animation(.easeOut(duration: 0.7), value: heroVisible)

                        // Bottom fade into background
                        LinearGradient(
                            colors: [.clear, Color(hex: "060A14").opacity(0.6),
                                     Color(hex: "060A14")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: geo.size.height * 0.12)
                    }
                    .opacity(heroVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: heroVisible)

                    // ── Title ─────────────────────────────────────────────
                    VStack(spacing: 3) {
                        Text("Quit for good.")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("For real this time.")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(PuffFreeTheme.primaryGradient)
                    }
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 16)
                    .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.12), value: titleVisible)

                    // ── Social proof ──────────────────────────────────────
                    SocialProofBar()
                        .padding(.top, 10)
                        .opacity(proofVisible ? 1 : 0)
                        .offset(y: proofVisible ? 0 : 10)
                        .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.22), value: proofVisible)

                    // ── Features (2-col grid) ─────────────────────────────
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 8
                    ) {
                        PaywallFeatureItem(icon: "lungs.fill",            text: "Health recovery tracking")
                        PaywallFeatureItem(icon: "dollarsign.circle.fill", text: "Real-time savings counter")
                        PaywallFeatureItem(icon: "brain.head.profile",    text: "AI craving insights")
                        PaywallFeatureItem(icon: "trophy.fill",           text: "Gamified milestones & XP")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .opacity(featVisible ? 1 : 0)
                    .offset(y: featVisible ? 0 : 14)
                    .animation(.spring(response: 0.45, dampingFraction: 0.75).delay(0.30), value: featVisible)

                    // ── Plans ─────────────────────────────────────────────
                    VStack(spacing: 8) {
                        if viewModel.isLoading && viewModel.currentOfferings == nil {
                            ProgressView()
                                .tint(PuffFreeTheme.accentTeal)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                        } else if let offering = viewModel.currentOfferings?.current {
                            ForEach(orderedPackages(from: offering), id: \.identifier) { pkg in
                                PremiumPackageCard(
                                    package: pkg,
                                    isSelected: selectedPackage?.identifier == pkg.identifier,
                                    onTap: {
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.65)) {
                                            selectedPackage = pkg
                                        }
                                        HapticManager.selection()
                                    }
                                )
                            }
                        } else {
                            ForEach(Array(fallbackPlans.enumerated()), id: \.element.title) { idx, plan in
                                PremiumFallbackCard(plan: plan, isSelected: plan.isBest)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .opacity(plansVisible ? 1 : 0)
                    .offset(y: plansVisible ? 0 : 18)
                    .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.38), value: plansVisible)

                    Spacer(minLength: 0)

                    // ── CTA ───────────────────────────────────────────────
                    VStack(spacing: 11) {
                        Button {
                            Task {
                                guard !viewModel.isLoading else { return }
                                let pkg = selectedPackage
                                    ?? viewModel.currentOfferings?.current?.availablePackages.first
                                if let pkg { await viewModel.purchase(pkg) }
                                if viewModel.isPro { onDismiss?() }
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

                                // Shimmer sweep
                                LinearGradient(
                                    colors: [.clear, .white.opacity(0.28), .clear],
                                    startPoint: UnitPoint(x: shimmerPos - 0.35, y: 0),
                                    endPoint: UnitPoint(x: shimmerPos + 0.35, y: 0)
                                )
                                .allowsHitTesting(false)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(PuffFreeTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: PuffFreeTheme.accentTeal.opacity(0.55), radius: 18, y: 6)
                        }
                        .disabled(viewModel.isLoading)

                        HStack(spacing: 24) {
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
                    .opacity(ctaVisible ? 1 : 0)
                    .offset(y: ctaVisible ? 0 : 18)
                    .animation(.spring(response: 0.5, dampingFraction: 0.72).delay(0.48), value: ctaVisible)
                }

                // ── Dismiss button (floating top-right) ───────────────────
                if onDismiss != nil {
                    VStack {
                        HStack {
                            Spacer()
                            Button { onDismiss?() } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.12))
                                        .frame(width: 32, height: 32)
                                    Image(systemName: "xmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                            .padding(.trailing, 20)
                            .padding(.top, geo.safeAreaInsets.top + 10)
                        }
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.refresh()
            // Default: yearly (best value), fallback monthly, fallback first
            if let yr = viewModel.currentOfferings?.current?.annual {
                selectedPackage = yr
            } else if let mo = viewModel.currentOfferings?.current?.monthly {
                selectedPackage = mo
            } else {
                selectedPackage = viewModel.currentOfferings?.current?.availablePackages.first
            }
        }
        .onAppear {
            heroVisible  = true
            titleVisible = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { proofVisible  = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { featVisible   = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { plansVisible  = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { ctaVisible    = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.linear(duration: 2.8).repeatForever(autoreverses: false)) {
                    shimmerPos = 1.4
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
    }

    // MARK: - Helpers

    private var ctaTitle: String {
        guard let pkg = selectedPackage else { return "Start Free Trial" }
        switch pkg.packageType {
        case .lifetime: return "Get Lifetime Access"
        default:        return "Start 3-Day Free Trial"
        }
    }

    private func orderedPackages(from offering: Offering) -> [Package] {
        let order: [PackageType] = [.weekly, .monthly, .annual, .lifetime]
        return order.compactMap { t in offering.availablePackages.first { $0.packageType == t } }
    }

    private var fallbackPlans: [(title: String, price: String, perDay: String, badge: String?, isBest: Bool)] {
        [
            (title: "Weekly",   price: "$4.99/wk",  perDay: "$0.71/day", badge: nil,            isBest: false),
            (title: "Monthly",  price: "$9.99/mo",  perDay: "$0.33/day", badge: nil,            isBest: false),
            (title: "Yearly",   price: "$49.99/yr", perDay: "$0.14/day", badge: "BEST VALUE",   isBest: true),
            (title: "Lifetime", price: "$79.99",    perDay: "one-time",  badge: nil,            isBest: false)
        ]
    }
}

// MARK: - Feature grid item

struct PaywallFeatureItem: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PuffFreeTheme.primaryGradient)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 11)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.07), lineWidth: 0.5))
    }
}

// MARK: - Premium package card (live RC)

struct PremiumPackageCard: View {
    let package: Package
    let isSelected: Bool
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

    private var priceLabel: String {
        switch package.packageType {
        case .weekly:   return "\(package.localizedPriceString)/wk"
        case .monthly:  return "\(package.localizedPriceString)/mo"
        case .annual:   return "\(package.localizedPriceString)/yr"
        case .lifetime: return package.localizedPriceString
        default:        return package.localizedPriceString
        }
    }

    private var subLabel: String {
        isLifetime ? "Pay once, quit forever" : "3-day free trial"
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Radio dot
                ZStack {
                    Circle()
                        .stroke(
                            isSelected ? PuffFreeTheme.accentTeal : Color.white.opacity(0.2),
                            lineWidth: isSelected ? 2 : 1.5
                        )
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(PuffFreeTheme.accentTeal)
                            .frame(width: 12, height: 12)
                    }
                }
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(.subheadline).fontWeight(.semibold)
                            .foregroundColor(.white)
                        if isBestValue {
                            Text("BEST VALUE")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(PuffFreeTheme.accentTeal)
                                .clipShape(Capsule())
                        }
                    }
                    Text(subLabel)
                        .font(.caption2)
                        .foregroundColor(isLifetime
                            ? .white.opacity(0.4)
                            : PuffFreeTheme.success)
                }

                Spacer()

                Text(priceLabel)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.55))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isSelected
                            ? LinearGradient(
                                colors: [Color(hex: "1A2038"),
                                         PuffFreeTheme.accentTeal.opacity(0.12)],
                                startPoint: .leading,
                                endPoint: .trailing)
                            : LinearGradient(
                                colors: [Color(hex: "141824"), Color(hex: "141824")],
                                startPoint: .leading,
                                endPoint: .trailing))
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isSelected
                                ? PuffFreeTheme.accentTeal.opacity(0.7)
                                : Color.white.opacity(0.07),
                            lineWidth: isSelected ? 1.5 : 1
                        )
                }
            )
            .shadow(
                color: isSelected ? PuffFreeTheme.accentTeal.opacity(0.18) : .clear,
                radius: 10, y: 3
            )
            .scaleEffect(isSelected ? 1.018 : 1.0)
            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fallback card (no RC)

struct PremiumFallbackCard: View {
    let plan: (title: String, price: String, perDay: String, badge: String?, isBest: Bool)
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(
                        isSelected ? PuffFreeTheme.accentTeal : Color.white.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1.5
                    )
                    .frame(width: 22, height: 22)
                if isSelected {
                    Circle().fill(PuffFreeTheme.accentTeal).frame(width: 12, height: 12)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(plan.title)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.white)
                    if let badge = plan.badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(PuffFreeTheme.accentTeal)
                            .clipShape(Capsule())
                    }
                }
                Text(plan.perDay == "one-time" ? "Pay once, quit forever" : "3-day free trial · \(plan.perDay)")
                    .font(.caption2)
                    .foregroundColor(plan.title == "Lifetime" ? .white.opacity(0.4) : PuffFreeTheme.success)
            }

            Spacer()

            Text(plan.price)
                .font(.subheadline).fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .white.opacity(0.55))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                        ? LinearGradient(
                            colors: [Color(hex: "1A2038"), PuffFreeTheme.accentTeal.opacity(0.12)],
                            startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(
                            colors: [Color(hex: "141824"), Color(hex: "141824")],
                            startPoint: .leading, endPoint: .trailing))
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isSelected ? PuffFreeTheme.accentTeal.opacity(0.7) : Color.white.opacity(0.07),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
        )
        .shadow(color: isSelected ? PuffFreeTheme.accentTeal.opacity(0.18) : .clear, radius: 10, y: 3)
    }
}
