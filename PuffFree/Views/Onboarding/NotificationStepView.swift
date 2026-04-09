import SwiftUI

struct NotificationStepView: View {
    @Binding var notificationsEnabled: Bool
    let onComplete: () -> Void

    @State private var heroVisible   = false
    @State private var heroFloat     = false
    @State private var titleVisible  = false
    @State private var rowsVisible: [Bool] = [false, false, false]
    @State private var ctaVisible    = false

    var body: some View {
        ZStack {
            // Ambient orbs
            FloatingOrb(color: PuffFreeTheme.accentTeal, size: 280, xOffset: 120,
                        yRange: 26, duration: 5.8, startDelay: 0)
                .offset(y: -180)
            FloatingOrb(color: Color(hex: "F59E0B"), size: 200, xOffset: -100,
                        yRange: 20, duration: 7.2, startDelay: 1.1)
                .offset(y: 140)

            VStack(spacing: 0) {
                Spacer()

                // ── Hero ──────────────────────────────────────────────────
                ZStack {
                    // Pulsing glow ring
                    Circle()
                        .fill(PuffFreeTheme.accentTeal.opacity(0.14))
                        .frame(width: 150, height: 150)
                        .scaleEffect(heroFloat ? 1.22 : 1.0)
                        .blur(radius: 16)
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(autoreverses: true),
                            value: heroFloat
                        )

                    Image("OnboardingAnalyzing")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: PuffFreeTheme.accentTeal.opacity(0.4), radius: 20, y: 6)
                }
                .scaleEffect(heroVisible ? 1 : 0.75)
                .opacity(heroVisible ? 1 : 0)
                .offset(y: heroFloat ? -5 : 5)
                .animation(.spring(response: 0.55, dampingFraction: 0.65), value: heroVisible)
                .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: heroFloat)

                // ── Heading ───────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Stay Motivated")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Get celebrated every step of the way")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 20)
                .opacity(titleVisible ? 1 : 0)
                .offset(y: titleVisible ? 0 : 10)
                .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.14), value: titleVisible)

                // ── Notification rows ─────────────────────────────────────
                VStack(spacing: 10) {
                    ForEach(notifRows.indices, id: \.self) { i in
                        PremiumNotificationRow(
                            icon: notifRows[i].icon,
                            iconColor: notifRows[i].color,
                            title: notifRows[i].title,
                            subtitle: notifRows[i].subtitle
                        )
                        .opacity(rowsVisible[i] ? 1 : 0)
                        .offset(x: rowsVisible[i] ? 0 : -28)
                        .animation(
                            .spring(response: 0.42, dampingFraction: 0.72)
                                .delay(0.22 + Double(i) * 0.1),
                            value: rowsVisible[i]
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)

                Spacer()

                // ── CTA ───────────────────────────────────────────────────
                VStack(spacing: 12) {
                    Button(action: {
                        notificationsEnabled = true
                        onComplete()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                                .font(.system(size: 15, weight: .semibold))
                            Text("Enable Notifications")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(PuffFreeTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: PuffFreeTheme.accentTeal.opacity(0.45), radius: 16, y: 5)
                    }

                    Button(action: {
                        notificationsEnabled = false
                        onComplete()
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(PuffFreeTheme.textTertiary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .scaleEffect(ctaVisible ? 1 : 0.88)
                .opacity(ctaVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.5), value: ctaVisible)
            }
        }
        .onAppear {
            heroVisible  = true
            titleVisible = true
            ctaVisible   = true
            for i in rowsVisible.indices { rowsVisible[i] = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { heroFloat = true }
        }
    }

    private var notifRows: [(icon: String, color: Color, title: String, subtitle: String)] {
        [
            ("trophy.fill",         Color(hex: "FFD700"), "Milestone Alerts",   "Celebrate every achievement"),
            ("checkmark.circle.fill", PuffFreeTheme.success, "Daily Check-Ins", "Track your mood & progress"),
            ("heart.fill",          Color(hex: "F472B6"),  "Motivation Boosts", "Stay inspired on tough days")
        ]
    }
}

// MARK: - Premium notification row

private struct PremiumNotificationRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(PuffFreeTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(PuffFreeTheme.success)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "141824"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 6, y: 2)
    }
}
