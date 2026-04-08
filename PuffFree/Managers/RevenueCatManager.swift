import Foundation
import RevenueCat

final class RevenueCatManager: @unchecked Sendable {
    static let shared = RevenueCatManager()
    private init() {}

    func checkProStatus() async -> Bool {
        do {
            let info = try await Purchases.shared.customerInfo()
            return info.entitlements[AppConstants.RevenueCat.entitlement]?.isActive == true
        } catch {
            return false
        }
    }

    @discardableResult
    func purchase(_ package: Package) async throws -> Bool {
        let result = try await Purchases.shared.purchase(package: package)
        return result.customerInfo.entitlements[AppConstants.RevenueCat.entitlement]?.isActive == true
    }

    @discardableResult
    func restorePurchases() async throws -> Bool {
        let info = try await Purchases.shared.restorePurchases()
        return info.entitlements[AppConstants.RevenueCat.entitlement]?.isActive == true
    }

    func fetchOfferings() async -> Offerings? {
        do {
            return try await Purchases.shared.offerings()
        } catch {
            return nil
        }
    }
}
