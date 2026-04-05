import SwiftUI

struct AnimatedRingView: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: LinearGradient
    let size: CGFloat

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        lineWidth: CGFloat = 12,
        gradient: LinearGradient = PuffFreeTheme.primaryGradient,
        size: CGFloat = 200
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.gradient = gradient
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))

            // Glow effect
            Circle()
                .trim(from: max(0, animatedProgress - 0.02), to: animatedProgress)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth + 4,
                        lineCap: .round
                    )
                )
                .blur(radius: 6)
                .rotationEffect(.degrees(-90))
                .opacity(0.6)
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}
