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

    let cardIndex: Int
    let width: CGFloat
    let frontImageName: String
    let backImageName: String
    let isExpanded: Bool
    let isSelected: Bool
    let flipAngle: Double
    let openFlipAngle: Double
    let displayScale: CGFloat
    let yOffset: CGFloat
    let bounceOffset: CGFloat
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
                cardIndex: cardIndex,
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
                cardIndex: cardIndex,
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
        .offset(y: yOffset + bounceOffset)
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

    let cardIndex: Int
    let imageName: String
    let width: CGFloat
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    let borderColors: [Color]
    let showsStroke: Bool
    let appliesShadow: Bool

    @State private var showsAnimatedStroke = false
    @State private var showsExpandedBackground = false

    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .background {
                    ExpandedCardBackground(
                        cardIndex: cardIndex,
                        isVisible: showsExpandedBackground
                    )
                }
                .overlay {
                    ZStack {
                        StaticCardStroke(
                            cornerRadius: cornerRadius,
                            strokeWidth: strokeWidth
                        )
                        .opacity(isAnimatedStrokeVisible ? Config.hiddenOpacity : Config.visibleOpacity)

                        AnimatedCardStroke(
                            cornerRadius: cornerRadius,
                            colors: borderColors,
                            isVisible: isAnimatedStrokeVisible
                        )
                    }
                }
                .shadow(
                    color: appliesShadow ? Config.cardShadowColor : .clear,
                    radius: Config.cardShadowRadius,
                    x: Config.cardShadowX,
                    y: Config.cardShadowY
                )
                .task(id: showsStroke) {
                    await updateAnimatedStrokeVisibility()
                }
                .task(id: showsStroke) {
                    await updateExpandedBackgroundVisibility()
                }
        }
    }

    private var isAnimatedStrokeVisible: Bool {
        Config.isCardStrokeAnimationEnabled && showsAnimatedStroke
    }

    private func updateAnimatedStrokeVisibility() async {
        guard Config.isCardStrokeAnimationEnabled, showsStroke else {
            showsAnimatedStroke = false
            return
        }

        showsAnimatedStroke = true

        let animationDuration = Config.cardStrokeAnimationDuration * Double(Config.cardStrokeAnimationRepeatCount)
        let nanoseconds = UInt64(animationDuration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)

        guard !Task.isCancelled else { return }
        showsAnimatedStroke = false
    }

    private func updateExpandedBackgroundVisibility() async {
        guard showsStroke else {
            showsExpandedBackground = false
            return
        }

        showsExpandedBackground = false

        let nanoseconds = UInt64(Config.cardExpandedBackgroundDelay * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)

        guard !Task.isCancelled, showsStroke else { return }
        withAnimation(.easeInOut(duration: Config.cardExpandedBackgroundFadeDuration)) {
            showsExpandedBackground = true
        }
    }
}

private struct ExpandedCardBackground: View {
    private typealias Config = WalletConfig

    let cardIndex: Int
    let isVisible: Bool

    var body: some View {
        GeometryReader { proxy in
            let backgroundWidth = proxy.size.width * Config.cardExpandedBackgroundScale
            let backgroundHeight = proxy.size.height * Config.cardExpandedBackgroundScale
            let cornerRadius = min(backgroundWidth, backgroundHeight) * Config.cardExpandedBackgroundCornerRadiusRatio

            LinearGradient(
                stops: gradientStops,
                startPoint: Config.cardExpandedBackgroundGradientStartPoint,
                endPoint: Config.cardExpandedBackgroundGradientEndPoint
            )
            .frame(width: backgroundWidth, height: backgroundHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .transformEffect(Config.cardExpandedBackgroundTransform)
            .blur(radius: Config.cardExpandedBackgroundBlur)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
            .opacity(isVisible ? Config.cardExpandedBackgroundOpacity : Config.hiddenOpacity)
        }
        .allowsHitTesting(false)
    }

    private var gradientStops: [Gradient.Stop] {
        Config.cardExpandedBackgroundGradientStopsByIndex[cardIndex]
            ?? Config.cardExpandedBackgroundGradientStops
    }
}

private struct StaticCardStroke: View {
    private typealias Config = WalletConfig

    let cornerRadius: CGFloat
    let strokeWidth: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: Config.cardBorderColors,
                    startPoint: Config.cardStaticStrokeGradientStartPoint,
                    endPoint: Config.cardStaticStrokeGradientEndPoint
                ),
                lineWidth: strokeWidth
            )
            .allowsHitTesting(false)
    }
}

private struct AnimatedCardStroke: View {
    private typealias Config = WalletConfig

    let cornerRadius: CGFloat
    let colors: [Color]
    let isVisible: Bool

    @State private var rotationAngle = Config.cardStrokeAnimationStartAngle

    var body: some View {
        GeometryReader { proxy in
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            let gradientSize = max(proxy.size.width, proxy.size.height) * Config.cardStrokeGradientScale

            ZStack {
                Color.clear
                    .overlay {
                        movingGradient(size: gradientSize)
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    }
                    .mask {
                        shape.stroke(lineWidth: Config.cardStrokeGlowWidth)
                    }
                    .blur(radius: Config.cardStrokeGlowBlur)
                    .opacity(Config.cardStrokeGlowOpacity)

                Color.clear
                    .overlay {
                        movingGradient(size: gradientSize)
                            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                    }
                    .mask {
                        shape.strokeBorder(lineWidth: Config.cardAnimatedStrokeWidth)
                    }
                    .opacity(Config.cardStrokeOpacity)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .opacity(isVisible ? Config.visibleOpacity : Config.hiddenOpacity)
        .allowsHitTesting(false)
        .task(id: isVisible) {
            guard isVisible else {
                rotationAngle = Config.cardStrokeAnimationStartAngle
                return
            }

            rotationAngle = Config.cardStrokeAnimationStartAngle
            withAnimation(
                .linear(duration: Config.cardStrokeAnimationDuration)
                    .repeatCount(
                        Config.cardStrokeAnimationRepeatCount,
                        autoreverses: Config.cardStrokeAnimationAutoreverses
                    )
            ) {
                rotationAngle = Config.cardStrokeAnimationEndAngle
            }
        }
    }

    private func movingGradient(size: CGFloat) -> some View {
        LinearGradient(
            colors: colors,
            startPoint: Config.cardStrokeGradientStartPoint,
            endPoint: Config.cardStrokeGradientEndPoint
        )
        .frame(width: size, height: size)
        .rotationEffect(.degrees(rotationAngle))
    }
}

struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]

    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}
