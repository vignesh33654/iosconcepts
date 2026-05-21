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
    let shaderTriggerID: Int
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
                shaderTriggerID: shaderTriggerID,
                strokeWidth: strokeWidth,
                borderColors: borderColors,
                showsStroke: showsStroke,
                showsAnimatedStrokeTrigger: shouldAnimateStroke,
                appliesShadow: appliesShadow
            )
            .opacity(isShowingBack ? hiddenOpacity : visibleOpacity)

            CardImageView(
                cardIndex: cardIndex,
                imageName: backImageName,
                width: width,
                cornerRadius: cornerRadius,
                shaderTriggerID: shaderTriggerID,
                strokeWidth: strokeWidth,
                borderColors: borderColors,
                showsStroke: showsStroke,
                showsAnimatedStrokeTrigger: shouldAnimateStroke,
                appliesShadow: appliesShadow
            )
            .rotation3DEffect(.degrees(backFaceRotationAngle), axis: (x: 0, y: 1, z: 0))
            .opacity(isShowingBack ? visibleOpacity : hiddenOpacity)

            if Config.isHolographicEnabled && isSelected {
                HolographicOverlay(
                    pitchAngle: gyroPitchAngle,
                    rollAngle: gyroRollAngle,
                    cornerRadius: cornerRadius
                )
            }
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

    private var shouldAnimateStroke: Bool {
        if Config.cardStrokeAnimationTriggersOnTilt {
            return isTiltedEnough
        }

        return showsStroke
    }

    private var isTiltedEnough: Bool {
        guard isExpanded, isSelected else { return false }

        return abs(gyroPitchAngle) >= Config.cardStrokeTiltActivationAngle
            || abs(gyroRollAngle) >= Config.cardStrokeTiltActivationAngle
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
    let shaderTriggerID: Int
    let strokeWidth: CGFloat
    let borderColors: [Color]
    let showsStroke: Bool
    let showsAnimatedStrokeTrigger: Bool
    let appliesShadow: Bool

    @State private var showsAnimatedStroke = false
    @State private var showsExpandedBackground = false

    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .background {
                    ZStack {
                        ExpandedCardBackground(
                            cardIndex: cardIndex,
                            isVisible: showsExpandedBackground
                        )

                        ExpandedCardShadow(
                            cornerRadius: cornerRadius,
                            isVisible: showsStroke
                        )
                    }
                }
                .overlay {
                    ZStack {
                        CardShaderOverlay(
                            cornerRadius: cornerRadius,
                            triggerID: shaderTriggerID
                        )

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
                    color: cardShadowColor,
                    radius: cardShadowRadius,
                    x: cardShadowX,
                    y: cardShadowY
                )
                .task(id: showsAnimatedStrokeTrigger) {
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

    private var cardShadowColor: Color {
        if showsStroke {
            return Config.expandedCardShadowColor
        }

        return appliesShadow ? Config.cardShadowColor : .clear
    }

    private var cardShadowRadius: CGFloat {
        showsStroke ? Config.expandedCardShadowRadius : Config.cardShadowRadius
    }

    private var cardShadowX: CGFloat {
        showsStroke ? Config.expandedCardShadowX : Config.cardShadowX
    }

    private var cardShadowY: CGFloat {
        showsStroke ? Config.expandedCardShadowY : Config.cardShadowY
    }

    private func updateAnimatedStrokeVisibility() async {
        guard Config.isCardStrokeAnimationEnabled, showsAnimatedStrokeTrigger else {
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

        guard Config.isCardExpandedBackgroundAnimationEnabled else {
            showsExpandedBackground = true
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

private struct ExpandedCardShadow: View {
    private typealias Config = WalletConfig

    let cornerRadius: CGFloat
    let isVisible: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Config.expandedCardShadowColor)
            .padding(-Config.expandedCardShadowSpread)
            .blur(radius: Config.expandedCardShadowRadius)
            .opacity(isVisible ? Config.visibleOpacity : Config.hiddenOpacity)
            .allowsHitTesting(false)
    }
}

private struct ExpandedCardBackground: View {
    private typealias Config = WalletConfig
    private let strokeColor = Color.white
    private let strokeWidth: CGFloat = 3
    private let shadowColor = Color(red: 0.447, green: 0.447, blue: 0.447).opacity(0.09)
    private let shadowBlur: CGFloat = 5
    private let shadowSpread: CGFloat = 4

    let cardIndex: Int
    let isVisible: Bool

    var body: some View {
        GeometryReader { proxy in
            let backgroundWidth = proxy.size.width * Config.cardExpandedBackgroundScale
            let backgroundHeight = proxy.size.height * Config.cardExpandedBackgroundScale
            let cornerRadius = min(backgroundWidth, backgroundHeight) * Config.cardExpandedBackgroundCornerRadiusRatio
            let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

            ZStack {
                shape
                    .fill(shadowColor)
                    .frame(
                        width: backgroundWidth + (shadowSpread * 2),
                        height: backgroundHeight + (shadowSpread * 2)
                    )
                    .blur(radius: shadowBlur)

                LinearGradient(
                    stops: gradientStops,
                    startPoint: Config.cardExpandedBackgroundGradientStartPoint,
                    endPoint: Config.cardExpandedBackgroundGradientEndPoint
                )
                .clipShape(shape)
                .overlay {
                    shape.stroke(strokeColor, lineWidth: strokeWidth)
                }
            }
            .frame(width: backgroundWidth, height: backgroundHeight)
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

private struct CardShaderOverlay: View {
    private typealias Config = WalletConfig

    let cornerRadius: CGFloat
    let triggerID: Int

    @State private var sweepXRatio = Config.cardShaderSweepStartXRatio
    @State private var isShowingSweep = false

    var body: some View {
        GeometryReader { proxy in
            LinearGradient(
                stops: Config.cardShaderGradientStops,
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(
                width: proxy.size.width * Config.cardShaderWidthScale,
                height: proxy.size.height * Config.cardShaderHeightScale
            )
            .rotationEffect(.degrees(Config.cardShaderRotationAngle))
            .blur(radius: Config.cardShaderBlur)
            .position(
                x: proxy.size.width * (sweepXRatio + Config.cardShaderOffsetXRatio),
                y: proxy.size.height * (0.5 + Config.cardShaderOffsetYRatio)
            )
            .opacity(isShowingSweep ? Config.cardShaderOpacity : Config.hiddenOpacity)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .allowsHitTesting(false)
        .task(id: triggerID) {
            await runSweepOnce()
        }
    }

    private func runSweepOnce() async {
        sweepXRatio = Config.cardShaderSweepStartXRatio
        isShowingSweep = false

        guard Config.isCardShaderEnabled, triggerID > 0 else { return }

        isShowingSweep = true

        withAnimation(.linear(duration: Config.cardShaderSweepDuration)) {
            sweepXRatio = Config.cardShaderSweepEndXRatio
        }

        let nanoseconds = UInt64(Config.cardShaderSweepDuration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)

        guard !Task.isCancelled else { return }
        isShowingSweep = false
    }
}

private struct StaticCardStroke: View {
    private typealias Config = WalletConfig

    let cornerRadius: CGFloat
    let strokeWidth: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(Color.white, lineWidth: strokeWidth)
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

private struct HolographicOverlay: View {
    private typealias Config = WalletConfig

    let pitchAngle: Double
    let rollAngle: Double
    let cornerRadius: CGFloat

    var body: some View {
        let xShift = CGFloat(rollAngle / Config.gyroscopeMaxTiltAngle) * Config.holographicShiftScale
        let yShift = CGFloat(pitchAngle / Config.gyroscopeMaxTiltAngle) * Config.holographicShiftScale

        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: Config.holographicColors,
                    startPoint: UnitPoint(x: 0.5 + xShift, y: 0.0 + yShift),
                    endPoint: UnitPoint(x: 0.5 - xShift, y: 1.0 - yShift)
                )
            )
            .blendMode(.screen)
            .opacity(Config.holographicOpacity)
            .allowsHitTesting(false)
    }
}

struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]

    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}
