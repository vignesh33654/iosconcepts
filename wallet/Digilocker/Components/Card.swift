//
//  Card.swift
//  iosconcepts
//
//  Created by vignesh on 19/05/26.
//

import SwiftUI
import UIKit
import CoreMotion

struct WalletCardView: View {
    private typealias Config = WalletConfig

    @State private var gyroPitchAngle = Config.gyroscopeNeutralAngle
    @State private var gyroRollAngle = Config.gyroscopeNeutralAngle

    #if !targetEnvironment(simulator)
    private let motionManager = CMMotionManager()
    #endif

    let width: CGFloat
    let frontImageName: String
    let backImageName: String
    let isExpanded: Bool
    let isSelected: Bool
    let flipAngle: Double
    let openFlipAngle: Double
    let displayScale: CGFloat
    let yOffset: CGFloat
    let rotation: Double
    let selectedOffset: CGSize
    let zIndex: Double
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    let backFaceRotationAngle: Double
    let flipPerspective: CGFloat
    let backVisibleStartAngle: Double
    let backVisibleEndAngle: Double
    let fullRotationAngle: Double
    let hiddenOpacity: Double
    let visibleOpacity: Double
    let borderColors: [Color]
    let showsStroke: Bool
    let appliesShadow: Bool
    let swipeMinimumDistance: CGFloat
    let onTap: () -> Void
    let onSwipe: (CGFloat) -> Void

    var body: some View {
        ZStack {
            CardImageView(
                imageName: frontImageName,
                width: width,
                cornerRadius: cornerRadius,
                strokeWidth: strokeWidth,
                borderColors: borderColors,
                showsStroke: showsStroke,
                appliesShadow: appliesShadow
            )
            .opacity(isShowingBack ? hiddenOpacity : visibleOpacity)

            CardImageView(
                imageName: backImageName,
                width: width,
                cornerRadius: cornerRadius,
                strokeWidth: strokeWidth,
                borderColors: borderColors,
                showsStroke: showsStroke,
                appliesShadow: appliesShadow
            )
            .rotation3DEffect(.degrees(backFaceRotationAngle), axis: (x: 0, y: 1, z: 0))
            .opacity(isShowingBack ? visibleOpacity : hiddenOpacity)
        }
        .compositingGroup()
        .rotation3DEffect(
            .degrees(flipAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: flipPerspective
        )
        .rotation3DEffect(
            .degrees(openFlipAngle),
            axis: (x: 1, y: 0, z: 0),
            perspective: flipPerspective
        )
        .rotation3DEffect(
            .degrees(isSelected ? gyroPitchAngle : Config.gyroscopeNeutralAngle),
            axis: (x: 1, y: 0, z: 0),
            perspective: flipPerspective
        )
        .rotation3DEffect(
            .degrees(isSelected ? gyroRollAngle : Config.gyroscopeNeutralAngle),
            axis: (x: 0, y: 1, z: 0),
            perspective: flipPerspective
        )
        .offset(y: yOffset)
        .scaleEffect(displayScale)
        .rotationEffect(.degrees(isSelected ? 0 : rotation))
        .offset(x: selectedOffset.width, y: selectedOffset.height)
        .zIndex(zIndex)
        .allowsHitTesting(isExpanded)
        .onAppear {
            updateGyroscopeState()
        }
        .onDisappear {
            stopGyroscope()
        }
        .onChange(of: isSelected) { _, isSelected in
            isSelected ? startGyroscope() : stopGyroscope()
        }
        .onTapGesture(perform: onTap)
        .simultaneousGesture(
            DragGesture(minimumDistance: swipeMinimumDistance)
                .onEnded { value in
                    let horizontalDistance = value.translation.width
                    let verticalDistance = value.translation.height

                    guard
                        abs(horizontalDistance) >= swipeMinimumDistance,
                        abs(horizontalDistance) > abs(verticalDistance)
                    else { return }

                    onSwipe(horizontalDistance)
                }
        )
    }

    private var isShowingBack: Bool {
        WalletLayoutCalculator.isShowingBack(
            flipAngle: flipAngle,
            fullRotationAngle: fullRotationAngle,
            backVisibleStartAngle: backVisibleStartAngle,
            backVisibleEndAngle: backVisibleEndAngle
        )
    }

    private func updateGyroscopeState() {
        if isSelected {
            startGyroscope()
        } else {
            stopGyroscope()
        }
    }

    #if targetEnvironment(simulator)
    private func startGyroscope() {
        resetGyroscopeTilt()
    }

    private func stopGyroscope() {
        resetGyroscopeTilt()
    }
    #else
    private func startGyroscope() {
        guard motionManager.isDeviceMotionAvailable, !motionManager.isDeviceMotionActive else { return }

        motionManager.deviceMotionUpdateInterval = Config.gyroscopeUpdateInterval
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let motion else { return }

            gyroPitchAngle = Self.clamped(
                -motion.attitude.pitch * Config.gyroscopeMotionScale,
                 limit: Double(Config.gyroscopeMaxTiltAngle)
            )
            gyroRollAngle = Self.clamped(
                motion.attitude.roll * Config.gyroscopeMotionScale,
                limit: Double(Config.gyroscopeMaxTiltAngle)
            )
        }
    }

    private func stopGyroscope() {
        motionManager.stopDeviceMotionUpdates()
        resetGyroscopeTilt()
    }
    #endif

    private func resetGyroscopeTilt() {
        withAnimation(.smooth(duration: Config.gyroscopeResetDuration)) {
            gyroPitchAngle = Config.gyroscopeNeutralAngle
            gyroRollAngle = Config.gyroscopeNeutralAngle
        }
    }

    private static func clamped(_ value: Double, limit: Double) -> Double {
        min(max(value, -limit), limit)
    }
}

private struct CardImageView: View {
    private typealias Config = WalletConfig

    let imageName: String
    let width: CGFloat
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    let borderColors: [Color]
    let showsStroke: Bool
    let appliesShadow: Bool

    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: borderColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                        .opacity(showsStroke ? Config.visibleOpacity : Config.hiddenOpacity)
                }
                .shadow(
                    color: appliesShadow ? Config.cardShadowColor : .clear,
                    radius: Config.cardShadowRadius,
                    x: Config.cardShadowX,
                    y: Config.cardShadowY
                )
        }
    }
}

struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]

    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}
