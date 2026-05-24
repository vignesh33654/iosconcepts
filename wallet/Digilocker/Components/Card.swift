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
    @State private var shaderNudgeOffset = CGSize.zero

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
                showsStroke: showsStroke,
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
        .offset(
            x: selectedOffset.width + shaderNudgeOffset.width,
            y: selectedOffset.height + shaderNudgeOffset.height
        )
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
        .task(id: shaderTriggerID) {
            await runShaderNudge()
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

    @MainActor
    private func runShaderNudge() async {
        shaderNudgeOffset = .zero

        guard Config.isCardShaderEnabled, shaderTriggerID > 0 else { return }

        withAnimation(.easeOut(duration: Config.cardShaderNudgeDuration)) {
            shaderNudgeOffset = CGSize(
                width: Config.cardShaderNudgeX,
                height: Config.cardShaderNudgeY
            )
        }

        let nanoseconds = UInt64(Config.cardShaderNudgeDuration * 1_000_000_000)
        try? await Task.sleep(nanoseconds: nanoseconds)

        guard !Task.isCancelled else { return }

        withAnimation(.smooth(duration: Config.cardShaderNudgeReturnDuration)) {
            shaderNudgeOffset = .zero
        }
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
    let showsStroke: Bool
    let appliesShadow: Bool

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
                        if showsGyroscopeGhostImage {
                            GyroscopeHolographicGhostImage()
                        }

                        CardShaderOverlay(
                            cornerRadius: cornerRadius,
                            triggerID: shaderTriggerID
                        )

                        StaticCardStroke(
                            cornerRadius: cornerRadius,
                            strokeWidth: strokeWidth
                        )
                    }
                }
                .shadow(
                    color: cardShadowColor,
                    radius: cardShadowRadius,
                    x: cardShadowX,
                    y: cardShadowY
                )
                .task(id: showsStroke) {
                    await updateExpandedBackgroundVisibility()
                }
        }
    }

    private var showsGyroscopeGhostImage: Bool {
        imageName == Config.firstCardFrontImageName
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

struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]

    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}
