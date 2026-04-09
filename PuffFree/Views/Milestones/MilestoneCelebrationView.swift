import SwiftUI

struct MilestoneCelebrationView: View {
    let milestone: MilestoneType
    @Binding var isPresented: Bool

    @State private var animateIn = false
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            // Background
            PuffFreeTheme.backgroundPrimary
                .ignoresSafeArea()

            // Confetti particles
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }

            VStack(spacing: 32) {
                Spacer()

                // Icon
                Image(systemName: milestone.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(PuffFreeTheme.celebrationGradient)
                    .scaleEffect(animateIn ? 1 : 0)
                    .rotationEffect(.degrees(animateIn ? 0 : -180))

                // Title
                VStack(spacing: 12) {
                    Text("MILESTONE UNLOCKED!")
                        .font(.caption)
                        .fontWeight(.bold)
                        .tracking(3)
                        .foregroundStyle(PuffFreeTheme.celebrationGradient)

                    Text(milestone.rawValue)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(milestone.celebrationMessage)
                        .font(.body)
                        .foregroundColor(PuffFreeTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 30)

                Spacer()

                // Dismiss button
                Button {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                } label: {
                    Text("Continue My Journey")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(PuffFreeTheme.celebrationGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            HapticManager.celebration()
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animateIn = true
            }
            withAnimation(.easeIn.delay(0.3)) {
                showConfetti = true
            }
        }
    }
}

// Simple confetti effect
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = (0..<50).map { _ in ConfettiParticle() }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for particle in particles {
                    let x = particle.startX * size.width
                    let progress = (time - particle.startTime).truncatingRemainder(dividingBy: particle.duration) / particle.duration
                    let y = progress * size.height * 1.2 - 50
                    let rotation = Angle.degrees(progress * particle.rotation)

                    context.opacity = 1 - progress
                    context.translateBy(x: x + sin(progress * .pi * 2) * 30, y: y)
                    context.rotate(by: rotation)

                    let rect = CGRect(x: -4, y: -4, width: 8, height: 8)
                    context.fill(Path(rect), with: .color(particle.color))
                    context.rotate(by: -rotation)
                    context.translateBy(x: -(x + sin(progress * .pi * 2) * 30), y: -y)
                }
            }
        }
    }
}

struct ConfettiParticle {
    let startX: Double = .random(in: 0...1)
    let startTime: Double = Date.now.timeIntervalSinceReferenceDate - .random(in: 0...3)
    let duration: Double = .random(in: 2...4)
    let rotation: Double = .random(in: 180...720)
    let color: Color = [
        Color(hex: "F59E0B"),
        Color(hex: "EF4444"),
        Color(hex: "8B5CF6"),
        Color(hex: "06B6D4"),
        Color(hex: "10B981"),
        Color(hex: "EC4899")
    ].randomElement() ?? Color(hex: "F59E0B")
}
