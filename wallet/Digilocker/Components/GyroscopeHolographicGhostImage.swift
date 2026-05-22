//
//  GyroscopeHolographicGhostImage.swift
//  iosconcepts
//
//  Created by vignesh on 21/05/26.
//

import SwiftUI
import UIKit
import CoreMotion

struct GyroscopeHolographicGhostImage: View {
    // Basic Controls
    private static let beforeImageName = "Before"
    private static let afterImageName = "After"
    private static let maxWidth: CGFloat = 70
    private static let trailingPadding: CGFloat = 12
    private static let bottomPadding: CGFloat = 20
    private static let beforeOpacity = 0.35
    private static let afterMaxOpacity = 1.0
    private static let tiltScale: CGFloat = 2.0
    private static let tiltDeadZone: CGFloat = 0.05
    private static let tiltSmoothing: CGFloat = 0.18

    // Advanced Controls
    private static let widthRatio: CGFloat = 0.72
    private static let imageSaturation = 0.0
    private static let imageContrast = 1.12
    private static let imageBrightness = 0.03
    private static let blurRadius: CGFloat = 0.18
    private static let tiltLimit: CGFloat = 1
    private static let tiltNeutral: CGFloat = 0
    private static let tiltRotationMultiplier: CGFloat = 3
    private static let tiltRotationYAxis: CGFloat = 1
    private static let tiltRotationPerspective: CGFloat = 0.45
    private static let simulatorPreviewTilt: CGFloat = 0.28
    private static let resetAnimationDuration = 0.35
    private static let motionUpdateInterval = 1.0 / 60.0
    private static let placement = Alignment.bottomTrailing
    private static let easingStart: CGFloat = 0
    private static let easingEnd: CGFloat = 1
    private static let smoothstepMultiplier: CGFloat = 3
    private static let smoothstepExponentMultiplier: CGFloat = 2
    fileprivate static let previewBackgroundOpacity = 0.08

    private static let foilColors: [Color] = [
        Color(hue: 0.92, saturation: 0.42, brightness: 1.0),  // pink
        Color(hue: 0.70, saturation: 0.40, brightness: 1.0),  // violet
        Color(hue: 0.55, saturation: 0.38, brightness: 1.0),  // soft blue
        Color(hue: 0.13, saturation: 0.40, brightness: 1.0),  // warm gold
        Color(hue: 0.92, saturation: 0.42, brightness: 1.0),  // back to pink (loops cleanly)
    ]
    private static let foilBaseOpacity: Double = 0.04
    private static let foilTiltOpacityScale: Double = 0.35  // was 0.55 — calmer at full tilt
    private static let foilShiftScale: Double = 0.5          // was 0.65 — slower spectrum drift
    private static let sheenOpacity: Double = 0.10           // was 0.18 — gentler highlight

    @State private var tilt = CGSize.zero
    @State private var revealProgress: CGFloat = Self.easingStart

    #if !targetEnvironment(simulator)
    private let motionManager = CMMotionManager()
    #endif

    var body: some View {
        GeometryReader { proxy in
            if let beforeImage = UIImage(named: Self.beforeImageName), let afterImage = UIImage(named: Self.afterImageName) {
                let imageWidth = min(proxy.size.width * Self.widthRatio, Self.maxWidth)

                ZStack {
                    beforeGhostImage(beforeImage)
                        .opacity(Self.beforeOpacity)

                    exactImage(afterImage)
                        .opacity(Self.afterMaxOpacity * naturalRevealProgress)

                    ZStack {
                        holographicFoil
                        metallicSheen
                    }
                    .mask {
                        exactImage(afterImage)
                    }
                }
                .frame(width: imageWidth)
                .rotation3DEffect(
                    .degrees(Double(tilt.width * Self.tiltRotationMultiplier)),
                    axis: (x: Self.tiltNeutral, y: Self.tiltRotationYAxis, z: Self.tiltNeutral),
                    perspective: Self.tiltRotationPerspective
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Self.placement)
                .padding(.trailing, Self.trailingPadding)
                .padding(.bottom, Self.bottomPadding)
                .allowsHitTesting(false)
            }
        }
        .task {
            startGyroscope()
        }
        .onDisappear {
            stopGyroscope()
        }
    }

    // Rainbow foil: diagonal gradient whose start/end shift laterally with tilt,
    // so the spectrum drifts across the image like a holographic sticker.
    private var holographicFoil: some View {
        let shift = Double(tilt.width) * Self.foilShiftScale
        return LinearGradient(
            colors: Self.foilColors,
            startPoint: UnitPoint(x: shift, y: 0),
            endPoint: UnitPoint(x: 1 + shift, y: 1)
        )
        .blendMode(.softLight)
        .opacity(Self.foilBaseOpacity + abs(Double(tilt.width)) * Self.foilTiltOpacityScale)
        .allowsHitTesting(false)
    }

    // Narrow white band that travels with tilt — the "polished metal" specular highlight.
    private var metallicSheen: some View {
        let center = 0.5 + Double(tilt.width) * 0.4
        return LinearGradient(
            stops: [
                .init(color: .white.opacity(0), location: 0),
                .init(color: .white.opacity(0.0), location: 0.5),
                .init(color: .white.opacity(0), location: 1),
            ],
            startPoint: UnitPoint(x: center - 0.3, y: 0),
            endPoint: UnitPoint(x: center + 0.3, y: 1)
        )
        .blendMode(.screen)
        .opacity(Self.sheenOpacity * abs(Double(tilt.width)))
        .allowsHitTesting(false)
    }

    private var naturalRevealProgress: CGFloat {
        let eased = revealProgress * revealProgress * (Self.smoothstepMultiplier - (Self.smoothstepExponentMultiplier * revealProgress))
        return min(max(eased, Self.easingStart), Self.easingEnd)
    }

    private func beforeGhostImage(_ image: UIImage) -> some View {
        exactImage(image)
            .saturation(Self.imageSaturation)
            .contrast(Self.imageContrast)
            .brightness(Self.imageBrightness)
            .blur(radius: Self.blurRadius)
    }

    private func exactImage(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
    }

    private func updateHorizontalTilt(_ horizontalTilt: CGFloat) {
        let nextTilt = clamped(horizontalTilt)
        let targetProgress = revealAmount(for: nextTilt)

        tilt = CGSize(
            width: tilt.width + ((nextTilt - tilt.width) * Self.tiltSmoothing),
            height: Self.tiltNeutral
        )
        revealProgress += (targetProgress - revealProgress) * Self.tiltSmoothing
    }

    private func revealAmount(for horizontalTilt: CGFloat) -> CGFloat {
        let adjustedTilt = max(abs(horizontalTilt) - Self.tiltDeadZone, Self.easingStart)
        return min(adjustedTilt / (Self.tiltLimit - Self.tiltDeadZone), Self.easingEnd)
    }

    #if targetEnvironment(simulator)
    private func startGyroscope() {
        updateHorizontalTilt(Self.simulatorPreviewTilt)
    }

    private func stopGyroscope() {
        tilt = .zero
        revealProgress = Self.easingStart
    }
    #else
    private func startGyroscope() {
        guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else { return }

        motionManager.deviceMotionUpdateInterval = Self.motionUpdateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion else { return }

            updateHorizontalTilt(CGFloat(motion.gravity.x) * Self.tiltScale)
        }
    }

    private func stopGyroscope() {
        motionManager.stopDeviceMotionUpdates()
        withAnimation(.smooth(duration: Self.resetAnimationDuration)) {
            tilt = .zero
            revealProgress = Self.easingStart
        }
    }
    #endif

    private func clamped(_ value: CGFloat) -> CGFloat {
        min(max(value, -Self.tiltLimit), Self.tiltLimit)
    }
}

#Preview {
    GyroscopeHolographicGhostImage()
        .background(Color.black.opacity(GyroscopeHolographicGhostImage.previewBackgroundOpacity))
}
