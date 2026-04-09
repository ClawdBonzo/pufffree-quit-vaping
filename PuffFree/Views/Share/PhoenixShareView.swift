import SwiftUI

// MARK: - Phoenix Share View
// "Phoenix Rising — Day X" viral story card.
// Renders the card via ImageRenderer and presents a ShareLink.

struct PhoenixShareView: View {
    let profile: UserProfile
    @State private var capturedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                PuffFreeTheme.backgroundPrimary.ignoresSafeArea()
                PhoenixParticleField(intensity: 0.5)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack(spacing: 28) {
                    // Live card preview
                    PhoenixShareCard(profile: profile)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(color: PuffFreeTheme.emberOrange.opacity(0.45), radius: 24, y: 6)
                        .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.2), radius: 40, y: 10)
                        .padding(.horizontal, 28)
                        .scaleEffect(0.88)

                    // Share / generate button
                    if let uiImage = capturedImage {
                        let shareImage = Image(uiImage: uiImage)
                        ShareLink(
                            item: shareImage,
                            preview: SharePreview(
                                "Phoenix Rising — Day \(profile.daysSinceQuit)",
                                image: shareImage
                            )
                        ) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Share My Journey")
                                    .font(.system(size: 17, weight: .bold))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(PuffFreeTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: PuffFreeTheme.emberOrange.opacity(0.5), radius: 16, y: 4)
                        }
                        .padding(.horizontal, 24)
                    } else {
                        // Generating...
                        HStack(spacing: 10) {
                            ProgressView()
                                .tint(.black)
                            Text("Generating card…")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(PuffFreeTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 24)
                    }

                    Text("Inspire others on their journey 🔥")
                        .font(.caption)
                        .foregroundColor(PuffFreeTheme.textTertiary)
                }
                .padding(.top, 16)
            }
            .navigationTitle("Share Your Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
            }
        }
        .onAppear { renderCard() }
    }

    @MainActor
    private func renderCard() {
        let renderer = ImageRenderer(
            content: PhoenixShareCard(profile: profile)
                .frame(width: 390, height: 693)
        )
        renderer.scale = 3.0
        renderer.proposedSize = ProposedViewSize(width: 390, height: 693)
        capturedImage = renderer.uiImage
    }
}

// MARK: - Phoenix Share Card
// The actual card rendered as an image — 390×693 (9:16 story ratio).

struct PhoenixShareCard: View {
    let profile: UserProfile

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "060204"),
                    Color(hex: "0E0600"),
                    Color(hex: "060A08"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Deep ember radial glow
            RadialGradient(
                colors: [PuffFreeTheme.emberOrange.opacity(0.22), .clear],
                center: UnitPoint(x: 0.5, y: 0.4),
                startRadius: 0,
                endRadius: 240
            )

            // Teal smoke glow from below
            RadialGradient(
                colors: [PuffFreeTheme.smokeTeal.opacity(0.15), .clear],
                center: UnitPoint(x: 0.5, y: 0.85),
                startRadius: 0,
                endRadius: 160
            )

            // Grid lines (subtle)
            VStack(spacing: 0) {
                ForEach(0..<12) { _ in
                    Divider()
                        .background(Color.white.opacity(0.03))
                    Spacer()
                }
            }

            VStack(spacing: 0) {
                Spacer()

                // App logo strip at top
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(PuffFreeTheme.flameGradient)
                    Text("PUFFFREE")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(3)
                }
                .padding(.bottom, 36)

                // Phoenix icon
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    PuffFreeTheme.phoenixGold.opacity(0.6),
                                    PuffFreeTheme.emberOrange.opacity(0.3),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                        .frame(width: 130, height: 130)

                    // Inner glow
                    Circle()
                        .fill(PuffFreeTheme.emberOrange.opacity(0.15))
                        .frame(width: 100, height: 100)
                        .blur(radius: 12)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 54, weight: .bold))
                        .foregroundStyle(PuffFreeTheme.flameGradient)
                        .shadow(color: PuffFreeTheme.emberOrange, radius: 16)
                }
                .padding(.bottom, 20)

                // "PHOENIX RISING" label
                Text("PHOENIX RISING")
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(PuffFreeTheme.goldGradient)
                    .tracking(4)
                    .padding(.bottom, 10)

                // Day count — the hero number
                Text("DAY \(profile.daysSinceQuit)")
                    .font(.system(size: 78, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, PuffFreeTheme.phoenixGold, PuffFreeTheme.emberOrange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: PuffFreeTheme.phoenixGold.opacity(0.5), radius: 16)
                    .padding(.bottom, 4)

                Text("Smoke-Free")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))
                    .padding(.bottom, 32)

                // Stats row
                HStack(spacing: 0) {
                    ShareStatChip(
                        icon: "dollarsign.circle.fill",
                        value: String(format: "$%.0f", profile.moneySaved),
                        label: "Saved"
                    )
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 1, height: 36)
                    ShareStatChip(
                        icon: "nosign",
                        value: "\(profile.puffsAvoided)",
                        label: "Avoided"
                    )
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 1, height: 36)
                    ShareStatChip(
                        icon: "shield.fill",
                        value: "\(profile.totalCravingsResisted)",
                        label: "Cravings Won"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            PuffFreeTheme.phoenixGold.opacity(0.3),
                                            PuffFreeTheme.emberOrange.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .padding(.horizontal, 24)

                Spacer()

                // Watermark
                Text("Download PuffFree • Your turn to rise")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.bottom, 28)
            }
        }
        .frame(width: 390, height: 693)
    }
}

private struct ShareStatChip: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(PuffFreeTheme.goldGradient)
            Text(value)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity)
    }
}
