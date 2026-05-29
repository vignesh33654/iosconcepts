import SwiftUI

// MARK: - HolographicShadeView

/// A full-screen animated Metal gradient that replicates the holographic
/// "metal shade" effect — configurable speed, angle, wavelength, and colours.
struct HolographicShadeView: View {

    // Animation speed. 0 = frozen. 0.2 = slow drift. 1.0 = fast pulse.
    var speed: Double = 0.2

    // Flow direction in radians.
    // 0 = horizontal →  |  π/2 = vertical ↓  |  π*0.6 ≈ diagonal (screenshot default)
    var angle: Double = .pi * 0.6

    // Pixels per complete colour cycle. Larger = wider bands.
    var wavelength: Double = 860

    // 1 = simple  |  2 = adds shimmer  |  3 = full depth (default)
    var layers: Int = 3

    var colorA: Color = Color(red: 0.02, green: 0.02, blue: 0.28)   // deep navy
    var colorB: Color = Color(red: 0.00, green: 0.28, blue: 0.92)   // electric blue
    var colorC: Color = Color(red: 0.00, green: 0.83, blue: 0.73)   // cyan-teal

    var body: some View {
        TimelineView(.animation) { context in
            let t = Float(context.date.timeIntervalSinceReferenceDate)
            Rectangle()
                .colorEffect(
                    ShaderLibrary.holographicShade(
                        .float(t),
                        .float(Float(angle)),
                        .float(Float(speed)),
                        .float(Float(wavelength)),
                        .float(Float(layers)),
                        .color(colorA),
                        .color(colorB),
                        .color(colorC)
                    )
                )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Presets

extension HolographicShadeView {

    // Matches the deep-blue → cyan screenshot.
    static var blueCyan: HolographicShadeView {
        HolographicShadeView()
    }

    // Purple → pink aurora.
    static var aurora: HolographicShadeView {
        HolographicShadeView(
            speed: 0.18,
            angle: .pi * 0.55,
            wavelength: 780,
            colorA: Color(red: 0.08, green: 0.02, blue: 0.30),
            colorB: Color(red: 0.55, green: 0.10, blue: 0.90),
            colorC: Color(red: 1.00, green: 0.35, blue: 0.65)
        )
    }

    // Deep ocean — dark teal to aquamarine.
    static var ocean: HolographicShadeView {
        HolographicShadeView(
            speed: 0.12,
            angle: .pi * 0.7,
            wavelength: 1100,
            layers: 2,
            colorA: Color(red: 0.00, green: 0.08, blue: 0.18),
            colorB: Color(red: 0.00, green: 0.38, blue: 0.52),
            colorC: Color(red: 0.00, green: 0.75, blue: 0.60)
        )
    }

    // Sunset — deep indigo to orange-gold.
    static var sunset: HolographicShadeView {
        HolographicShadeView(
            speed: 0.15,
            angle: .pi * 0.45,
            wavelength: 950,
            colorA: Color(red: 0.08, green: 0.03, blue: 0.22),
            colorB: Color(red: 0.75, green: 0.20, blue: 0.10),
            colorC: Color(red: 1.00, green: 0.68, blue: 0.00)
        )
    }
}

// MARK: - Previews

#Preview("Blue Cyan (screenshot)") {
    HolographicShadeView.blueCyan
}

#Preview("Aurora") {
    HolographicShadeView.aurora
}

#Preview("Ocean") {
    HolographicShadeView.ocean
}

#Preview("Sunset") {
    HolographicShadeView.sunset
}

#Preview("Custom — fast + tight") {
    HolographicShadeView(
        speed: 0.8,
        angle: .pi / 4,
        wavelength: 320,
        layers: 3,
        colorA: Color(red: 0.05, green: 0.05, blue: 0.05),
        colorB: Color(red: 0.10, green: 0.80, blue: 0.40),
        colorC: Color(red: 0.85, green: 1.00, blue: 0.20)
    )
}
