import SwiftUI
import RevenueCat

@Observable
@MainActor
final class SubscriptionViewModel {
    var isPro: Bool = false
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var currentOfferings: Offerings? = nil

    nonisolated init() {}

    func refresh() async {
        isLoading = true
        defer { isLoading = false }
        async let offerings = RevenueCatManager.shared.fetchOfferings()
        async let proStatus = RevenueCatManager.shared.checkProStatus()
        currentOfferings = await offerings
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-SeedDemoData") {
            isPro = true   // demo mode: unlock Pro for App Store screenshots
            return
        }
        #endif
        isPro = await proStatus
    }

    func purchase(_ package: Package) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            isPro = try await RevenueCatManager.shared.purchase(package)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restore() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            isPro = try await RevenueCatManager.shared.restorePurchases()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Environment Key

extension EnvironmentValues {
    @Entry var subscriptionViewModel = SubscriptionViewModel()
}
