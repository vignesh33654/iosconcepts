import SwiftUI

// MARK: - Portal Shape

struct PortalShape: Shape {
    var origin: CGPoint
    var radius: CGFloat

    nonisolated var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path(ellipseIn: CGRect(
            x: origin.x - radius,
            y: origin.y - radius,
            width: radius * 2,
            height: radius * 2
        ))
    }
}

// MARK: - Aurora Ring

struct AuroraRingView: View {
    let origin: CGPoint
    let radius: CGFloat
    let opacity: Double

    private let colors: [Color] = [
        .purple,
        Color(red: 0.3, green: 0.1, blue: 1),
        .cyan,
        Color(red: 0, green: 0.9, blue: 1),
        .white,
        .blue,
        .purple,
        Color(red: 1, green: 0.45, blue: 0),
        .purple
    ]

    var body: some View {
        ZStack {
            // Wide outer glow
            Circle()
                .strokeBorder(
                    AngularGradient(colors: colors, center: .center),
                    lineWidth: 32
                )
                .blur(radius: 20)
                .opacity(opacity * 0.5)

            // Medium halo
            Circle()
                .strokeBorder(
                    AngularGradient(colors: colors, center: .center),
                    lineWidth: 12
                )
                .blur(radius: 8)
                .opacity(opacity * 0.65)

            // Sharp crisp edge
            Circle()
                .strokeBorder(
                    AngularGradient(colors: colors, center: .center),
                    lineWidth: 2
                )
                .opacity(opacity * 0.9)
        }
        .frame(width: radius * 2, height: radius * 2)
        .position(origin)
        .allowsHitTesting(false)
    }
}

// MARK: - Ripple Rings

struct RippleRingsView: View {
    let origin: CGPoint
    let trigger: Int

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                RippleRing(
                    origin: origin,
                    trigger: trigger,
                    delay: Double(i) * 0.1
                )
            }
        }
        .allowsHitTesting(false)
    }
}

private struct RippleRing: View {
    let origin: CGPoint
    let trigger: Int
    let delay: Double

    @State private var radius: CGFloat = 8
    @State private var opacity: Double = 0

    var body: some View {
        Circle()
            .strokeBorder(Color.white, lineWidth: 1.5)
            .frame(width: radius * 2, height: radius * 2)
            .position(origin)
            .opacity(opacity)
            .task(id: trigger) {
                guard trigger > 0 else { return }
                await animate()
            }
    }

    private func animate() async {
        var tx = Transaction()
        tx.disablesAnimations = true
        withTransaction(tx) {
            radius = 8
            opacity = 0.75
        }

        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        guard !Task.isCancelled else { return }

        withAnimation(.easeOut(duration: 0.65)) {
            radius = 170
            opacity = 0
        }
    }
}
