import SwiftUI

struct NotificationStepView: View {
    @Binding var notificationsEnabled: Bool
    let onComplete: () -> Void

    @State private var animateIn = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image("OnboardingAnalyzing")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaleEffect(animateIn ? 1 : 0.9)

                Text("Stay Motivated")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Get milestone celebrations, daily check-in reminders, and motivational nudges")
                    .font(.subheadline)
                    .foregroundColor(PuffFreeTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            VStack(spacing: 16) {
                NotificationOptionRow(
                    icon: "trophy.fill",
                    title: "Milestone Alerts",
                    subtitle: "Celebrate your achievements"
                )
                NotificationOptionRow(
                    icon: "checkmark.circle.fill",
                    title: "Daily Check-Ins",
                    subtitle: "Track your mood & progress"
                )
                NotificationOptionRow(
                    icon: "heart.fill",
                    title: "Motivation Boosts",
                    subtitle: "Stay inspired on tough days"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    notificationsEnabled = true
                    onComplete()
                }) {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(PuffFreeTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
            .padding(.bottom, 32)
        }
        .onAppear {
            withAnimation(.spring(duration: 0.6)) {
                animateIn = true
            }
        }
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
                    .font(.subheadline)
                    .fontWeight(.semibold)
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
