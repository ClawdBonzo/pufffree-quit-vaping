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
        VStack(spacing: 0) {
            Spacer()

            // Hero
            ZStack {
                Circle()
                    .fill(PuffFreeTheme.accentTeal.opacity(0.12))
                    .frame(width: 120, height: 120)
                    .scaleEffect(heroFloat ? 1.12 : 1.0)
                    .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true), value: heroFloat)

                Image("OnboardingAnalyzing")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .scaleEffect(heroVisible ? 1 : 0.7)
            .opacity(heroVisible ? 1 : 0)
            .animation(.spring(response: 0.52, dampingFraction: 0.65), value: heroVisible)
            .offset(y: heroFloat ? -4 : 4)
            .animation(.easeInOut(duration: 2.8).repeatForever(autoreverses: true), value: heroFloat)

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

            VStack(spacing: 10) {
                ForEach(notifRows.indices, id: \.self) { i in
                    NotificationOptionRow(
                        icon: notifRows[i].icon,
                        title: notifRows[i].title,
                        subtitle: notifRows[i].subtitle
                    )
                    .opacity(rowsVisible[i] ? 1 : 0)
                    .offset(x: rowsVisible[i] ? 0 : -24)
                    .animation(
                        .spring(response: 0.42, dampingFraction: 0.72).delay(0.22 + Double(i) * 0.1),
                        value: rowsVisible[i]
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 10) {
                Button(action: {
                    notificationsEnabled = true
                    onComplete()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.badge.fill")
                        Text("Enable Notifications")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PuffFreeTheme.primaryGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: PuffFreeTheme.accentTeal.opacity(0.3), radius: 12, y: 4)
                }

                Button(action: {
                    notificationsEnabled = false
                    onComplete()
                }) {
                    Text("Maybe Later")
                        .font(.subheadline)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
            .scaleEffect(ctaVisible ? 1 : 0.9)
            .opacity(ctaVisible ? 1 : 0)
            .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.5), value: ctaVisible)
        }
        .onAppear {
            heroVisible  = true
            titleVisible = true
            ctaVisible   = true
            for i in rowsVisible.indices {
                rowsVisible[i] = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                heroFloat = true
            }
        }
    }

    private var notifRows: [(icon: String, title: String, subtitle: String)] {
        [
            ("trophy.fill",        "Milestone Alerts",  "Celebrate every achievement"),
            ("checkmark.circle.fill","Daily Check-Ins", "Track your mood & progress"),
            ("heart.fill",         "Motivation Boosts", "Stay inspired on tough days")
        ]
    }
}

struct NotificationOptionRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(PuffFreeTheme.primaryGradient)
                .frame(width: 36)

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
                .foregroundColor(PuffFreeTheme.success)
        }
        .padding()
        .background(PuffFreeTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
