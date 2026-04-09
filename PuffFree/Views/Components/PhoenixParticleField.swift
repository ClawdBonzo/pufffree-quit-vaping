import SwiftUI

// MARK: - Phoenix Particle Field
// Ambient background of rising ember sparks + smoke wisps.
// Canvas-based for performance. Non-interactive.
// Automatically hidden when Reduce Motion is enabled.

struct PhoenixParticleField: View {
    private let particles: [PhoenixParticle]
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(intensity: Double = 1.0) {
        particles = PhoenixParticle.generate(intensity: intensity)
    }

    var body: some View {
        if reduceMotion {
            // Respect user's motion preference — show nothing instead of animating
            Color.clear
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    for p in particles {
                        let elapsed = (now - p.birthOffset)
                            .truncatingRemainder(dividingBy: p.lifetime)
                        let progress = max(0, elapsed) / p.lifetime

                        // Rise from bottom
                        let y = size.height * (1.0 - progress * 1.1) + p.yStartOffset
                        let x = p.baseX * size.width
                            + sin(progress * .pi * 2.0 * p.swayFreq + p.swayPhase) * p.swayAmp

                        // Alpha: fade in, hold, fade out
                        let alpha: Double = {
                            if progress < 0.12 { return progress / 0.12 }
                            if progress > 0.72 { return (1.0 - progress) / 0.28 }
                            return 1.0
                        }()

                        var ctx = context
                        ctx.opacity = alpha * p.opacity
                        let side = p.radius * 2.0
                        let rect = CGRect(x: x - p.radius, y: y - p.radius, width: side, height: side)
                        ctx.fill(Path(ellipseIn: rect), with: .color(p.color))
                    }
                }
            }
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }
}

// MARK: - Particle Model

struct PhoenixParticle {
    let baseX: Double
    let radius: Double
    let lifetime: Double
    let birthOffset: Double
    let swayFreq: Double
    let swayAmp: Double
    let swayPhase: Double
    let yStartOffset: Double
    let color: Color
    let opacity: Double

    static func generate(intensity: Double = 1.0) -> [PhoenixParticle] {
        let now = Date.timeIntervalSinceReferenceDate

        let emberColors: [Color] = [
            Color(hex: "E85D04"),
            Color(hex: "F97316"),
            Color(hex: "FFD700"),
            Color(hex: "FFF9C4"),
            Color(hex: "FBBF24"),
        ]
        let smokeColors: [Color] = [
            Color(hex: "0D9B6B"),
            Color(hex: "06B6D4"),
            Color(hex: "9CA3AF"),
        ]

        let emberCount = Int(Double(22) * intensity)
        let smokeCount = Int(Double(12) * intensity)
        var result: [PhoenixParticle] = []

        for i in 0..<emberCount {
            result.append(PhoenixParticle(
                baseX: Double.random(in: 0.04...0.96),
                radius: Double.random(in: 1.2...3.2),
                lifetime: Double.random(in: 3.5...7.5),
                birthOffset: now - Double.random(in: 0...7.5),
                swayFreq: Double.random(in: 0.8...2.0),
                swayAmp: Double.random(in: 6...22),
                swayPhase: Double(i) * 0.41,
                yStartOffset: Double.random(in: 0...50),
                color: emberColors[i % emberColors.count],
                opacity: Double.random(in: 0.45...0.85)
            ))
        }

        for i in 0..<smokeCount {
            result.append(PhoenixParticle(
                baseX: Double.random(in: 0.04...0.96),
                radius: Double.random(in: 5...14),
                lifetime: Double.random(in: 6...11),
                birthOffset: now - Double.random(in: 0...11),
                swayFreq: Double.random(in: 0.3...0.9),
                swayAmp: Double.random(in: 18...45),
                swayPhase: Double(i) * 0.73,
                yStartOffset: Double.random(in: 0...30),
                color: smokeColors[i % smokeColors.count],
                opacity: Double.random(in: 0.06...0.16)
            ))
        }

        return result
    }
}

// MARK: - Phoenix Flame Badge
// The living streak counter. Intensity, glow radius, and color scale with streak length.
// Respects Reduce Motion — pulsing is disabled automatically.

struct PhoenixFlameBadge: View {
    let streakDays: Int
    let isPulsing: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var flameScale: CGFloat {
        switch streakDays {
        case 0...2:   return 1.0
        case 3...6:   return 1.1
        case 7...13:  return 1.2
        case 14...29: return 1.3
        case 30...99: return 1.4
        default:      return 1.55
        }
    }

    private var glowRadius: CGFloat {
        switch streakDays {
        case 0...2:   return 8
        case 3...6:   return 12
        case 7...13:  return 18
        case 14...29: return 22
        case 30...99: return 28
        default:      return 36
        }
    }

    private var outerRingColor: Color {
        streakDays >= 30 ? PuffFreeTheme.phoenixGold : PuffFreeTheme.emberOrange
    }

    // Effective pulsing: disabled when Reduce Motion is on
    private var effectivePulse: Bool { isPulsing && !reduceMotion }

    var body: some View {
        VStack(spacing: 3) {
            ZStack {
                // Outermost ambient glow
                Circle()
                    .fill(outerRingColor.opacity(0.08))
                    .frame(width: 72, height: 72)
                    .scaleEffect(effectivePulse ? 1.18 : 1.0)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1.6).repeatForever(autoreverses: true),
                        value: effectivePulse
                    )
                    .blur(radius: 6)

                // Mid glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [PuffFreeTheme.emberOrange.opacity(0.28), .clear],
                            center: .center, startRadius: 0, endRadius: 28
                        )
                    )
                    .frame(width: 56, height: 56)
                    .scaleEffect(effectivePulse ? 1.12 : 1.0)
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.2),
                        value: effectivePulse
                    )

                // Inner circle
                Circle()
                    .fill(Color(hex: "1C0A00"))
                    .frame(width: 44, height: 44)

                // Flame icon — multi-layer for depth
                ZStack {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(PuffFreeTheme.emberOrange.opacity(0.4))
                        .blur(radius: 4)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(PuffFreeTheme.flameGradient)
                }
                .scaleEffect(flameScale)
                .shadow(color: PuffFreeTheme.emberOrange, radius: glowRadius)
                .scaleEffect(effectivePulse ? 1.06 : 1.0)
                .animation(
                    reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.05),
                    value: effectivePulse
                )
            }
            .frame(width: 72, height: 72)

            Text("\(streakDays)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(streakDays >= 7 ? AnyShapeStyle(PuffFreeTheme.goldGradient) : AnyShapeStyle(AnyShapeStyle(.white)))
            Text("streak")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(PuffFreeTheme.textTertiary)
                .textCase(.uppercase)
        }
        // Accessibility: combine into a single readable element
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(streakDays) day streak")
    }
}

// MARK: - Ember Burst Effect
// Radiates particles outward from center — used in celebrations.
// Hidden from accessibility (purely decorative).

struct EmberBurstView: View {
    let particleCount: Int
    @State private var burst = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // Pre-computed per-particle data to avoid random() inside body
    private struct BurstParticle {
        let angle: Double
        let distance: CGFloat
        let size: CGFloat
        let colorIndex: Int
    }

    private let particleData: [BurstParticle]

    init(particleCount: Int = 12) {
        self.particleCount = particleCount
        self.particleData = (0..<particleCount).map { i in
            BurstParticle(
                angle: Double(i) / Double(particleCount) * 2.0 * .pi,
                distance: CGFloat.random(in: 60...120),
                size: CGFloat.random(in: 3...6),
                colorIndex: i % 3
            )
        }
    }

    private let emberColors: [Color] = [
        PuffFreeTheme.emberOrange,
        PuffFreeTheme.phoenixGold,
        Color(hex: "F97316"),
    ]

    var body: some View {
        if reduceMotion {
            Color.clear.accessibilityHidden(true)
        } else {
            ZStack {
                ForEach(0..<particleCount, id: \.self) { i in
                    let p = particleData[i]
                    Circle()
                        .fill(emberColors[p.colorIndex])
                        .frame(width: p.size, height: p.size)
                        .offset(
                            x: burst ? p.distance * CGFloat(cos(p.angle)) : 0,
                            y: burst ? p.distance * CGFloat(sin(p.angle)) : 0
                        )
                        .opacity(burst ? 0 : 1)
                        .animation(
                            .easeOut(duration: 0.8).delay(Double(i) * 0.02),
                            value: burst
                        )
                }
            }
            .accessibilityHidden(true)
            .onAppear {
                withAnimation { burst = true }
            }
        }
    }
}
