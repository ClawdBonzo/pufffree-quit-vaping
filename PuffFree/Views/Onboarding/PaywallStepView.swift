import SwiftUI

struct PaywallStepView: View {
    let onComplete: () -> Void

    var body: some View {
        PaywallView(onDismiss: onComplete)
    }
}
