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

    static let title = ""
    static let subtitle = ""
    static let showsSubtitle = true
    static let headerFontName = "SeasonSerif-Regular-TRIAL"
    static let headerFontFileName = "SeasonSerif-TRIAL-Regular"
    static let headerFontFileExtension = "otf"
    static let headerTopSpacing: CGFloat = 120
    static let headerSpacing: CGFloat = 8
    static let headerHorizontalPadding: CGFloat = 24
    static let titleFontSize: CGFloat = 24
    static let subtitleFontSize: CGFloat = 17
    static let titleColor = Color(red: 0.063, green: 0.063, blue: 0.063)
    static let subtitleColor = Color(red: 0.38, green: 0.38, blue: 0.38)
    static let titleMinimumScale: CGFloat = 0.0
    static let subtitleMinimumScale: CGFloat = 0.0
    static let headerLineLimit = 0

    static let backgroundImageName = "Background"
    static let pocketImageName = "Pocket 2"
    static let firstCardFrontImageName = "Arav front 4"
    static let firstCardBackImageName = "Arav back"
    static let secondCardFrontImageName = "Voter ID"
    static let secondCardBackImageName = "Aadhar card"
    static let lastCardFrontImageName = "Aadhar card"
    static let lastCardBackImageName = "Voter ID"

    static let mainStackSpacing: CGFloat = 0
    static let backgroundOffsetY: CGFloat = -6
    static let pocketWidthExtra: CGFloat = 2
    static let pocketOffsetY: CGFloat = 44
    static let pocketShadowColor = Color.black.opacity(0.8)
    static let pocketShadowRadius: CGFloat = 4
    static let pocketShadowX: CGFloat = 0
    static let pocketShadowY: CGFloat = -5
    static let bottomPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 10
    static let cardStrokeWidth: CGFloat = 2.5
    static let isCardExpandedBackgroundAnimationEnabled = true
    static let cardExpandedBackgroundDelay = 0.75
    static let cardExpandedBackgroundFadeDuration = 0.7
    static let cardExpandedBackgroundOpacity = 0.4
    static let cardExpandedBackgroundBlur: CGFloat = 40
    static let cardExpandedBackgroundScale: CGFloat = 1.0
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
    static let isCardShaderEnabled = true
    static let cardShaderOpacity = 0.72
    static let cardShaderBlur: CGFloat = 24
    static let cardShaderWidthScale: CGFloat = 0.38
    static let cardShaderHeightScale: CGFloat = 1.9
    static let cardShaderRotationAngle = 24.0
    static let cardShaderOffsetXRatio: CGFloat = 0.0
    static let cardShaderOffsetYRatio: CGFloat = 0.0
    static let cardShaderSweepStartXRatio: CGFloat = -0.35
    static let cardShaderSweepEndXRatio: CGFloat = 1.35
    static let cardShaderSweepDuration = 1.15
    static let cardShaderNudgeX: CGFloat = 3
    static let cardShaderNudgeY: CGFloat = -2
    static let cardShaderNudgeDuration = 0.16
    static let cardShaderNudgeReturnDuration = 0.45
    static let cardShaderGradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: .white.opacity(0), location: 0),
        Gradient.Stop(color: .white.opacity(0.28), location: 0.34),
        Gradient.Stop(color: .white.opacity(0.86), location: 0.5),
        Gradient.Stop(color: .white.opacity(0.28), location: 0.66),
        Gradient.Stop(color: .white.opacity(0), location: 1)
    ]
    static let cardShadowColor = Color.black.opacity(0.22)
    static let cardShadowRadius: CGFloat = 20
    static let cardShadowX: CGFloat = -5
    static let cardShadowY: CGFloat = 5
    static let expandedCardShadowColor = Color(red: 0.447, green: 0.447, blue: 0.447).opacity(0.09)
    static let expandedCardShadowRadius: CGFloat = 5
    static let expandedCardShadowSpread: CGFloat = 4
    static let expandedCardShadowX: CGFloat = 0
    static let expandedCardShadowY: CGFloat = 0
    static let pocketZIndex = 10.0
    static let secondCardIndex = 1
    static let collapsedRotation = 0.0

    static let springResponse = 0.45
    static let springDamping = 0.69
    static let springBlendDuration = 0.08
    static let expandDelayStep = 0.07
    static let collapseDelayStep = 0.07
    static let faceIDSuccessAnimationDelay = 1.0  // Wait for Face ID checkmark.
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
    static let walletReturnDipOffset: CGFloat = 8
    static let walletReturnDipDelay: Double = 0.30
    static let walletReturnSpringResponse = 0.82
    static let walletReturnSpringDamping = 0.40
    static let selectedCardScale: CGFloat = 1.12
    static let swipeSpringResponse = 0.6
    static let swipeSpringDamping = 0.75
    static let backFaceRotationAngle = 180.0
    static let flipPerspective: CGFloat = 0.5
    static let backVisibleStartAngle = 90.0
    static let backVisibleEndAngle = 270.0
    static let fullRotationAngle = 360.0
    static let hiddenOpacity = 0.0
    static let visibleOpacity = 1.0
    static let gyroscopeNeutralAngle = 0.0
    static let gyroscopeMaxTiltAngle = 4.5
    static let gyroscopeMotionScale = 20.0
    static let gyroscopeUpdateInterval = 1.0 / 60.0
    static let gyroscopeResetDuration = 0.45
    static let cardLayouts: [WalletCardLayout] = [
        WalletCardLayout(lift: -56, lockedLift: 16, rest: 0, rotation: 0, scale: 0.98, widthScale: 0.9),
        WalletCardLayout(lift: -22, lockedLift: 20, rest: 0, rotation: 0, scale: 0.98, widthScale: 0.9),
        WalletCardLayout(lift: 12, lockedLift: 24, rest: 0, rotation: 0, scale: 0.98, widthScale: 0.9)
    ]

    // Full-screen tint that shifts to the selected card's identity colour.
    // Each layer fades in/out independently so switching cards cross-fades cleanly.
    static let cardThemeColors: [Int: Color] = [
        0: Color(red: 0.212, green: 0.667, blue: 0.953),  // Arav card tint
        1: Color(red: 0.35, green: 0.75, blue: 0.55),  // fresh teal  — Voter ID   ← adjust
        2: Color(red: 1.0, green: 0.447, blue: 0.098),  // Aadhar card tint
    ]
    static let cardThemeBottomOpacity: Double = 0.08   // ← tint strength at bottom
    static let cardThemeTopOpacity: Double = 0.24      // ← tint strength at top
    static let cardThemeFadeDuration: Double = 0.50   // ← fade speed in/out

    // Card name overlay (appears above the selected card)
    static let cardNames: [String] = ["PAN", "VOTER ID", "AADHAR"]
    static let cardNameFontName = "RalewayDots-Regular"
    static let cardNameFontFileName = "RalewayDots-Regular"
    static let cardNameFontFileExtension = "ttf"
    static let cardNameFontSize: CGFloat = 64
    static let cardNameTopPadding: CGFloat = 152
    static let cardNameRevealDelay: Double = 0.4
    static let cardNameRevealDuration: Double = 0.3
    static let cardNameStartYOffset: CGFloat = 18
    static let cardNameTracking: CGFloat = 1.0
    static let cardNameZIndex = 2.0
    static let cardStackZIndex = 3.0
}
