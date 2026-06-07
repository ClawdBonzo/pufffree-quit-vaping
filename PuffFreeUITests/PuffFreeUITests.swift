import XCTest

/// End-to-end check of the free-tier Daily Ritual loop: the affirm button must
/// appear for a non-Pro user, be tappable, and — after one tap — disable itself
/// and flip to the completed state (driven by GamificationViewModel.completeDailyRitual).
final class PuffFreeUITests: XCTestCase {

    override func setUp() {
        continueAfterFailure = false
    }

    func testDailyRitualTapMarksCompleted() throws {
        let app = XCUIApplication()
        // Seed aspirational data, force the free tier, land on the dashboard.
        app.launchArguments = ["-SeedDemoData", "1", "-FreeTier", "1", "-Screen", "Dashboard"]
        app.launch()

        let affirm = app.buttons["ritual_affirm_button"]
        XCTAssertTrue(affirm.waitForExistence(timeout: 15),
                      "Free-tier Daily Ritual button should be present on the dashboard")
        XCTAssertTrue(affirm.isEnabled,
                      "Ritual button should be enabled before today's ritual is completed")

        affirm.tap()

        // Completing the ritual disables the button (label also flips to the done state).
        let disabled = NSPredicate(format: "isEnabled == false")
        expectation(for: disabled, evaluatedWith: affirm, handler: nil)
        waitForExpectations(timeout: 8)
        XCTAssertFalse(affirm.isEnabled,
                       "Ritual button should be disabled after completing today's ritual")
    }

    /// Guards the Guideline 4 fix: the paywall's purchase button must be on-screen
    /// and tappable on every device (it previously fell below the fold on iPad
    /// because the screen didn't scroll).
    func testPaywallPurchaseButtonIsReachable() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-SeedDemoData", "1", "-FreeTier", "1", "-Paywall", "1"]
        app.launch()

        let cta = app.buttons["paywall_cta"]
        XCTAssertTrue(cta.waitForExistence(timeout: 15),
                      "Paywall purchase button should be present")
        XCTAssertTrue(cta.isHittable,
                      "Paywall purchase button must be reachable (not below the fold) on this device")
    }
}
