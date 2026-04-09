import SwiftUI

struct QuitDateStepView: View {
    @Binding var quitDate: Date
    let onNext: () -> Void

    @State private var heroVisible    = false
    @State private var contentVisible = false
    @State private var ctaVisible     = false
    @State private var heroFloat      = false

    private var isToday: Bool {
        Calendar.current.isDateInToday(quitDate)
    }

    var body: some View {
        ZStack {
            // Ambient orbs
            FloatingOrb(color: PuffFreeTheme.accentTeal, size: 300, xOffset: 100,
                        yRange: 24, duration: 5.5, startDelay: 0)
                .offset(y: -200)
            FloatingOrb(color: Color(hex: "7C3AED"), size: 200, xOffset: -80,
                        yRange: 20, duration: 7.0, startDelay: 0.8)
                .offset(y: 160)

            VStack(spacing: 0) {
                // ── Hero ──────────────────────────────────────────────────
                ZStack {
                    Circle()
                        .fill(PuffFreeTheme.accentTeal.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .blur(radius: 24)
                        .scaleEffect(heroFloat ? 1.2 : 1.0)
                        .animation(
                            .easeInOut(duration: 3.2).repeatForever(autoreverses: true),
                            value: heroFloat
                        )

                    Image("OnboardingQuitDate")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: PuffFreeTheme.accentTeal.opacity(0.35), radius: 24, y: 8)
                }
                .scaleEffect(heroVisible ? 1 : 0.8)
                .opacity(heroVisible ? 1 : 0)
                .offset(y: heroFloat ? -6 : 6)
                .animation(.spring(response: 0.55, dampingFraction: 0.68), value: heroVisible)
                .animation(.easeInOut(duration: 3.2).repeatForever(autoreverses: true), value: heroFloat)
                .padding(.top, 24)

                // ── Heading ───────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Mark your first day free")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    if isToday {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(Color(hex: "FFD700"))
                            Text("Today is Day 1 of your new life!")
                                .font(.subheadline)
                                .foregroundStyle(PuffFreeTheme.primaryGradient)
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundColor(Color(hex: "FFD700"))
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        Text("When did you quit, or when will you?")
                            .font(.subheadline)
                            .foregroundColor(PuffFreeTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, 24)
                .opacity(contentVisible ? 1 : 0)
                .offset(y: contentVisible ? 0 : 12)
                .animation(.spring(response: 0.45, dampingFraction: 0.72).delay(0.15), value: contentVisible)

                // ── Date picker in glass card ─────────────────────────────
                VStack {
                    DatePicker(
                        "Quit Date",
                        selection: $quitDate,
                        in: ...Date(),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .tint(PuffFreeTheme.accentTeal)
                    .colorScheme(.dark)
                }
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "0E1520").opacity(0.6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .opacity(contentVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.4).delay(0.25), value: contentVisible)

                Spacer(minLength: 0)

                // ── CTA ───────────────────────────────────────────────────
                Button(action: onNext) {
                    Text("Continue")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(PuffFreeTheme.primaryGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: PuffFreeTheme.accentTeal.opacity(0.4), radius: 14, y: 5)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .scaleEffect(ctaVisible ? 1 : 0.88)
                .opacity(ctaVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.7).delay(0.38), value: ctaVisible)
            }
        }
        .onAppear {
            heroVisible    = true
            contentVisible = true
            ctaVisible     = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { heroFloat = true }
        }
    }
}
