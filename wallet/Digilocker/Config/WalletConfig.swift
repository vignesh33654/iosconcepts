//
//  WalletConfig.swift
//  iosconcepts
//
//  Created by vignesh on 19/05/26.
//

import SwiftUI

enum WalletConfig {
    static let defaultResetFlipAngle = 0.0
    static let defaultInitialCardScale: CGFloat = 1
    static let defaultCardCount = 3
    static let previewHorizontalPadding: CGFloat = 38
    static let previewMaxWalletWidth: CGFloat = 320
    static let mainMaxWalletWidth: CGFloat = 450
    static let mainWalletHorizontalPadding: CGFloat = 40
    static let mainWalletWidthScale: CGFloat = 0.9

    static let title = "Welcome to digilocker"
    static let subtitle = "Use your Face ID to check out all your ID"
    static let headerTopSpacing: CGFloat = 80
    static let headerSpacing: CGFloat = 8
    static let headerHorizontalPadding: CGFloat = 24
    static let titleFontSize: CGFloat = 20
    static let subtitleFontSize: CGFloat = 15
    static let titleMinimumScale: CGFloat = 0.8
    static let subtitleMinimumScale: CGFloat = 0.75
    static let headerLineLimit = 1

    static let backgroundImageName = "Background"
    static let pocketImageName = "Pocket 2"
    static let secondCardFrontImageName = "Nandhi front"
    static let secondCardBackImageName = "Nandhi back"

    static let mainStackSpacing: CGFloat = 0
    static let backgroundOffsetY: CGFloat = -6
    static let pocketWidthExtra: CGFloat = 2
    static let pocketOffsetY: CGFloat = 44
    static let pocketShadowColor = Color.black.opacity(0.8)
    static let pocketShadowRadius: CGFloat = 4
    static let pocketShadowX: CGFloat = 0
    static let pocketShadowY: CGFloat = -5
    static let bottomPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 12
    static let cardStrokeWidth: CGFloat = 2
    static let cardStaticStrokeGradientStartPoint = UnitPoint.topLeading
    static let cardStaticStrokeGradientEndPoint = UnitPoint.bottomTrailing
    static let isCardStrokeAnimationEnabled = false
    static let cardAnimatedStrokeWidth: CGFloat = 2
    static let cardStrokeOpacity = 0.4
    static let cardStrokeGlowWidth: CGFloat = 8
    static let cardStrokeGlowBlur: CGFloat = 10
    static let cardStrokeGlowOpacity = 0.7
    static let cardStrokeGradientScale: CGFloat = 1.7
    static let cardStrokeGradientStartPoint = UnitPoint.leading
    static let cardStrokeGradientEndPoint = UnitPoint.trailing
    static let cardStrokeAnimationStartAngle = 0.0
    static let cardStrokeAnimationEndAngle = 360.0
    static let cardStrokeAnimationDuration = 0.8
    static let cardStrokeAnimationRepeatCount = 1
    static let cardStrokeAnimationAutoreverses = false
    static let cardExpandedBackgroundDelay = 0.75
    static let cardExpandedBackgroundFadeDuration = 0.7
    static let cardExpandedBackgroundOpacity = 0.5
    static let cardExpandedBackgroundBlur: CGFloat = 32
    static let cardExpandedBackgroundScale: CGFloat = 1.3
    static let cardExpandedBackgroundCornerRadiusRatio: CGFloat = 0.5
    static let cardExpandedBackgroundTransform = CGAffineTransform.identity
    static let cardExpandedBackgroundGradientStartPoint = UnitPoint(x: 0.25, y: 0.5)
    static let cardExpandedBackgroundGradientEndPoint = UnitPoint(x: 0.75, y: 0.5)
    static let cardExpandedBackgroundGradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: Color(red: 0.918, green: 0.557, blue: 0.282), location: 0),
        Gradient.Stop(color: Color(red: 0.212, green: 0.667, blue: 0.953), location: 0.46),
        Gradient.Stop(color: Color(red: 0.612, green: 0.89, blue: 0.654), location: 0.88)
    ]
    static let cardExpandedBackgroundGradientStopsByIndex: [Int: [Gradient.Stop]] = [
        0: cardExpandedBackgroundGradientStops,
        1: cardExpandedBackgroundGradientStops,
        2: cardExpandedBackgroundGradientStops
    ]
    static let cardShadowColor = Color.black.opacity(0.22)
    static let cardShadowRadius: CGFloat = 20
    static let cardShadowX: CGFloat = -5
    static let cardShadowY: CGFloat = 5
    static let pocketZIndex = 10.0
    static let selectedCardZIndex = 100.0
    static let secondCardIndex = 1
    static let collapsedRotation = 0.0
    static let baseCardZIndexOffset = 0.0

    static let springResponse = 0.45
    static let springDamping = 0.69
    static let springBlendDuration = 0.08
    static let expandDelayStep = 0.07
    static let collapseDelayStep = 0.07
    static let autoExpandDelayNanoseconds: UInt64 = 500_000_000  // Auto-expand after 0.5s
    static let punchDelayNanoseconds: UInt64 = 80_000_000
    static let punchScale: CGFloat = 0.86

    static let flipAngle = 180.0
    static let openFlipAngle = 360.0
    static let flipDuration = 0.4
    static let flipBounce = 0.02
    static let cardSwipeMinimumDistance: CGFloat = 28
    static let selectedCardSpringResponse = 0.5
    static let selectedCardSpringDamping = 0.8
    static let selectedCardUp: CGFloat = -60
    static let cardBounceOffset: CGFloat = 12
    static let cardPullOutDipOffset: CGFloat = 8
    static let cardBounceSpringResponse = 0.5
    static let cardBounceSpringDamping = 0.35
    static let cardBounceDelayStep = 0.05
    static let swipeSpringResponse = 0.6
    static let swipeSpringDamping = 0.75
    static let backFaceRotationAngle = 180.0
    static let flipPerspective: CGFloat = 0.5
    static let backVisibleStartAngle = 90.0
    static let backVisibleEndAngle = 270.0
    static let fullRotationAngle = 360.0
    static let hiddenOpacity = 0.0
    static let visibleOpacity = 1.0
    static let cardBorderColors = [
        Color.white,
        Color(red: 0.82, green: 0.82, blue: 0.82)
    ]
    static let cardAnimatedBorderColors = [
        Color(red: 1.0, green: 0.28, blue: 0.32),
        Color(red: 0.72, green: 0.36, blue: 1.0),
        Color(red: 0.22, green: 0.82, blue: 1.0),
        Color(red: 1.0, green: 0.78, blue: 0.26),
        Color(red: 1.0, green: 0.28, blue: 0.32)
    ]
    static let gyroscopeNeutralAngle = 0.0
    static let gyroscopeMaxTiltAngle = 8.0
    static let gyroscopeMotionScale = 20.0
    static let gyroscopeUpdateInterval = 1.0 / 60.0
    static let gyroscopeResetDuration = 0.45
    static let cardLayouts: [WalletCardLayout] = [
        WalletCardLayout(lift: -60, rest: 9, rotation: 0, scale: 1.025, widthScale: 0.86),
        WalletCardLayout(lift: -28, rest: 10, rotation: 0, scale: 1.022, widthScale: 0.88),
        WalletCardLayout(lift: 12, rest: 23, rotation: 0, scale: 1.012, widthScale: 0.9)
    ]
}
