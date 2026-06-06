import SwiftUI

/// Citations + medical disclaimer for the health-recovery timeline.
/// Required by App Store Guideline 1.4.1 — every health/medical claim in the app
/// must point the user to credible sources. Presented from the Health screen.
struct HealthSourcesView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About this timeline")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(AppConstants.Health.disclaimer)
                            .font(.subheadline)
                            .foregroundColor(PuffFreeTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sources")
                            .font(.headline)
                            .foregroundColor(.white)

                        ForEach(AppConstants.Health.sources) { src in
                            Link(destination: src.url) {
                                HStack(spacing: 12) {
                                    Image(systemName: "link")
                                        .font(.caption)
                                        .foregroundColor(PuffFreeTheme.accentTeal)
                                    Text(src.title)
                                        .font(.subheadline)
                                        .foregroundColor(PuffFreeTheme.accentTeal)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption2)
                                        .foregroundColor(PuffFreeTheme.textTertiary)
                                }
                                .padding()
                                .background(PuffFreeTheme.backgroundCard)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .accessibilityHint("Opens \(src.title) in your browser")
                        }
                    }
                }
                .padding(20)
            }
            .background(PuffFreeTheme.backgroundPrimary.ignoresSafeArea())
            .navigationTitle("Health Sources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
