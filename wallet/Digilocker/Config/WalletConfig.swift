//
//  WalletConfig.swift
//  iosconcepts
//
//  Created by vignesh on 19/05/26.
//

import SwiftUI

struct WalletConfigItem: Identifiable {
    let name: String
    let defaultValue: String

    var id: String { name }
}

struct WalletConfigNumberItem: Identifiable {
    let name: String
    let defaultValue: Double
    let section: String

    var id: String { name }
}

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
    static let firstCardFrontImageName = "Arav front 4"
    static let firstCardBackImageName = "Aadhar card"
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
    static let cardStaticStrokeGradientStartPoint = UnitPoint.topLeading
    static let cardStaticStrokeGradientEndPoint = UnitPoint.bottomTrailing
    static let isCardStrokeAnimationEnabled = false
    static let cardStrokeAnimationTriggersOnTilt = true
    static let cardStrokeTiltActivationAngle = 1.2
    static let cardAnimatedStrokeWidth: CGFloat = 2
    static let cardStrokeOpacity = 1.0
    static let cardStrokeGlowWidth: CGFloat = 0
    static let cardStrokeGlowBlur: CGFloat = 0
    static let cardStrokeGlowOpacity = 0.0
    static let cardStrokeGradientScale: CGFloat = 0.7
    static let cardStrokeGradientStartPoint = UnitPoint.leading
    static let cardStrokeGradientEndPoint = UnitPoint.trailing
    static let cardStrokeAnimationStartAngle = 0.0
    static let cardStrokeAnimationEndAngle = 252.0
    static let cardStrokeAnimationDuration = 1.5
    static let cardStrokeAnimationRepeatCount = 1
    static let cardStrokeAnimationAutoreverses = false
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
    static let cardShaderBlur: CGFloat = 10
    static let cardShaderWidthScale: CGFloat = 0.38
    static let cardShaderHeightScale: CGFloat = 1.9
    static let cardShaderRotationAngle = 24.0
    static let cardShaderOffsetXRatio: CGFloat = 0.0
    static let cardShaderOffsetYRatio: CGFloat = 0.0
    static let cardShaderSweepStartXRatio: CGFloat = -0.35
    static let cardShaderSweepEndXRatio: CGFloat = 1.35
    static let cardShaderSweepDuration = 1.15
    static let cardShaderGradientStops: [Gradient.Stop] = [
        Gradient.Stop(color: .white.opacity(0), location: 0),
        Gradient.Stop(color: .white.opacity(0.95), location: 0.5),
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
    static let cardBorderColors = [
        Color.white,
        Color(red: 0.82, green: 0.82, blue: 0.82)
    ]
    static let cardAnimatedBorderColors = [
        Color.clear,
        Color.clear,
        Color(red: 1.0, green: 0.431, blue: 0.0),
        Color(red: 1.0, green: 0.431, blue: 0.0),
        Color.clear,
        Color.clear
    ]
    static let gyroscopeNeutralAngle = 0.0
    static let gyroscopeMaxTiltAngle = 4.5
    static let gyroscopeMotionScale = 20.0
    static let gyroscopeUpdateInterval = 1.0 / 60.0
    static let gyroscopeResetDuration = 0.45
    static let cardLayouts: [WalletCardLayout] = [
        WalletCardLayout(lift: -62, rest: 10, rotation: 0, scale: 0.98, widthScale: 0.9),
        WalletCardLayout(lift: -20, rest: 10, rotation: 0, scale: 0.98, widthScale: 0.9),
        WalletCardLayout(lift: 12, rest: 12, rotation: 0, scale: 0.98, widthScale: 0.9)
    ]

    static let settingsPanelTitle = "Wallet Config"
    static let settingsPanelWidthRatio: CGFloat = 0.5
    static let settingsPanelHeightRatio: CGFloat = 0.5
    static let settingsIconName = "gearshape.fill"
    static let settingsCloseIconName = "xmark"
    static let settingsCopyIconName = "doc.on.doc"
    static let settingsResetIconName = "arrow.counterclockwise"
    static let settingsResetAllIconName = "arrow.clockwise"
    static let settingsButtonSize: CGFloat = 42
    static let settingsButtonPadding: CGFloat = 18
    static let settingsOuterPadding: CGFloat = 10
    static let settingsContentPadding: CGFloat = 12
    static let settingsHeaderVerticalPadding: CGFloat = 10
    static let settingsHeaderSpacing: CGFloat = 10
    static let settingsRowSpacing: CGFloat = 8
    static let settingsRowInnerSpacing: CGFloat = 6
    static let settingsSectionSpacing: CGFloat = 8
    static let settingsSectionHeaderFontSize: CGFloat = 13
    static let settingsSliderSpacing: CGFloat = 6
    static let settingsValueSpacing: CGFloat = 8
    static let settingsValuePadding: CGFloat = 8
    static let settingsCornerRadius: CGFloat = 14
    static let settingsRowCornerRadius: CGFloat = 10
    static let settingsValueCornerRadius: CGFloat = 8
    static let settingsTitleFontSize: CGFloat = 15
    static let settingsKeyFontSize: CGFloat = 12
    static let settingsValueFontSize: CGFloat = 11
    static let settingsTitleMinimumScale: CGFloat = 0.75
    static let settingsKeyMinimumScale: CGFloat = 0.7
    static let settingsShadowColor = Color.black.opacity(0.18)
    static let settingsShadowRadius: CGFloat = 18
    static let settingsShadowX: CGFloat = 0
    static let settingsShadowY: CGFloat = 8
    static let settingsRowPadding: CGFloat = 10
    static let settingsRowBackground = Color.white.opacity(0.3)
    static let settingsValueBackground = Color.white.opacity(0.28)
    static let settingsValueLineLimit = 3
    static let settingsButtonAccessibilityLabel = "Open wallet configuration"
    static let settingsCloseAccessibilityLabel = "Close configuration"
    static let settingsCopyAccessibilityLabel = "Copy value"
    static let settingsResetAccessibilityLabel = "Reset value"
    static let settingsResetAllAccessibilityLabel = "Reset all values"

    static let settingsItems: [WalletConfigItem] = [
        WalletConfigItem(name: "defaultResetFlipAngle", defaultValue: "0.0"),
        WalletConfigItem(name: "defaultInitialCardScale", defaultValue: "1"),
        WalletConfigItem(name: "defaultCardCount", defaultValue: "3"),
        WalletConfigItem(name: "previewHorizontalPadding", defaultValue: "38"),
        WalletConfigItem(name: "previewMaxWalletWidth", defaultValue: "320"),
        WalletConfigItem(name: "mainMaxWalletWidth", defaultValue: "450"),
        WalletConfigItem(name: "mainWalletHorizontalPadding", defaultValue: "40"),
        WalletConfigItem(name: "mainWalletWidthScale", defaultValue: "0.9"),
        WalletConfigItem(name: "title", defaultValue: "Welcome to digilocker"),
        WalletConfigItem(name: "subtitle", defaultValue: "Use your Face ID to check out all your ID"),
        WalletConfigItem(name: "headerTopSpacing", defaultValue: "80"),
        WalletConfigItem(name: "headerSpacing", defaultValue: "8"),
        WalletConfigItem(name: "headerHorizontalPadding", defaultValue: "24"),
        WalletConfigItem(name: "titleFontSize", defaultValue: "20"),
        WalletConfigItem(name: "subtitleFontSize", defaultValue: "15"),
        WalletConfigItem(name: "titleMinimumScale", defaultValue: "0.8"),
        WalletConfigItem(name: "subtitleMinimumScale", defaultValue: "0.75"),
        WalletConfigItem(name: "headerLineLimit", defaultValue: "1"),
        WalletConfigItem(name: "backgroundImageName", defaultValue: "Background"),
        WalletConfigItem(name: "pocketImageName", defaultValue: "Pocket 2"),
        WalletConfigItem(name: "firstCardFrontImageName", defaultValue: "Arav front 4"),
        WalletConfigItem(name: "firstCardBackImageName", defaultValue: "Aadhar card"),
        WalletConfigItem(name: "secondCardFrontImageName", defaultValue: "Voter ID"),
        WalletConfigItem(name: "secondCardBackImageName", defaultValue: "Aadhar card"),
        WalletConfigItem(name: "lastCardFrontImageName", defaultValue: "Aadhar card"),
        WalletConfigItem(name: "lastCardBackImageName", defaultValue: "Voter ID"),
        WalletConfigItem(name: "mainStackSpacing", defaultValue: "0"),
        WalletConfigItem(name: "backgroundOffsetY", defaultValue: "-6"),
        WalletConfigItem(name: "pocketWidthExtra", defaultValue: "2"),
        WalletConfigItem(name: "pocketOffsetY", defaultValue: "44"),
        WalletConfigItem(name: "pocketShadowColor", defaultValue: "black opacity 0.8"),
        WalletConfigItem(name: "pocketShadowRadius", defaultValue: "4"),
        WalletConfigItem(name: "pocketShadowX", defaultValue: "0"),
        WalletConfigItem(name: "pocketShadowY", defaultValue: "-5"),
        WalletConfigItem(name: "bottomPadding", defaultValue: "16"),
        WalletConfigItem(name: "cardCornerRadius", defaultValue: "8"),
        WalletConfigItem(name: "cardStrokeWidth", defaultValue: "2.5"),
        WalletConfigItem(name: "isCardStrokeAnimationEnabled", defaultValue: "false"),
        WalletConfigItem(name: "cardStrokeAnimationTriggersOnTilt", defaultValue: "true"),
        WalletConfigItem(name: "cardStrokeTiltActivationAngle", defaultValue: "1.2"),
        WalletConfigItem(name: "cardAnimatedStrokeWidth", defaultValue: "2"),
        WalletConfigItem(name: "cardStrokeOpacity", defaultValue: "1.0"),
        WalletConfigItem(name: "cardStrokeGlowWidth", defaultValue: "0"),
        WalletConfigItem(name: "cardStrokeGlowBlur", defaultValue: "0"),
        WalletConfigItem(name: "cardStrokeGlowOpacity", defaultValue: "0.0"),
        WalletConfigItem(name: "cardStrokeGradientScale", defaultValue: "0.7"),
        WalletConfigItem(name: "cardStrokeAnimationStartAngle", defaultValue: "0.0"),
        WalletConfigItem(name: "cardStrokeAnimationEndAngle", defaultValue: "252.0"),
        WalletConfigItem(name: "cardStrokeAnimationDuration", defaultValue: "1.5"),
        WalletConfigItem(name: "cardStrokeAnimationRepeatCount", defaultValue: "1"),
        WalletConfigItem(name: "cardStrokeAnimationAutoreverses", defaultValue: "false"),
        WalletConfigItem(name: "cardExpandedBackgroundDelay", defaultValue: "0.75"),
        WalletConfigItem(name: "cardExpandedBackgroundFadeDuration", defaultValue: "0.7"),
        WalletConfigItem(name: "cardExpandedBackgroundOpacity", defaultValue: "0.5"),
        WalletConfigItem(name: "cardExpandedBackgroundBlur", defaultValue: "32"),
        WalletConfigItem(name: "cardExpandedBackgroundScale", defaultValue: "1.3"),
        WalletConfigItem(name: "cardExpandedBackgroundCornerRadiusRatio", defaultValue: "0.5"),
        WalletConfigItem(name: "isCardShaderEnabled", defaultValue: "true"),
        WalletConfigItem(name: "cardShaderOpacity", defaultValue: "0.72"),
        WalletConfigItem(name: "cardShaderBlur", defaultValue: "10"),
        WalletConfigItem(name: "cardShaderWidthScale", defaultValue: "0.38"),
        WalletConfigItem(name: "cardShaderHeightScale", defaultValue: "1.9"),
        WalletConfigItem(name: "cardShaderRotationAngle", defaultValue: "24.0"),
        WalletConfigItem(name: "cardShaderOffsetXRatio", defaultValue: "0.0"),
        WalletConfigItem(name: "cardShaderOffsetYRatio", defaultValue: "0.0"),
        WalletConfigItem(name: "cardShaderSweepStartXRatio", defaultValue: "-0.35"),
        WalletConfigItem(name: "cardShaderSweepEndXRatio", defaultValue: "1.35"),
        WalletConfigItem(name: "cardShaderSweepDuration", defaultValue: "1.15"),
        WalletConfigItem(name: "cardShadowColor", defaultValue: "black opacity 0.22"),
        WalletConfigItem(name: "cardShadowRadius", defaultValue: "20"),
        WalletConfigItem(name: "cardShadowX", defaultValue: "-5"),
        WalletConfigItem(name: "cardShadowY", defaultValue: "5"),
        WalletConfigItem(name: "pocketZIndex", defaultValue: "10.0"),
        WalletConfigItem(name: "selectedCardZIndex", defaultValue: "100.0"),
        WalletConfigItem(name: "secondCardIndex", defaultValue: "1"),
        WalletConfigItem(name: "collapsedRotation", defaultValue: "0.0"),
        WalletConfigItem(name: "baseCardZIndexOffset", defaultValue: "0.0"),
        WalletConfigItem(name: "springResponse", defaultValue: "0.45"),
        WalletConfigItem(name: "springDamping", defaultValue: "0.69"),
        WalletConfigItem(name: "springBlendDuration", defaultValue: "0.08"),
        WalletConfigItem(name: "expandDelayStep", defaultValue: "0.07"),
        WalletConfigItem(name: "collapseDelayStep", defaultValue: "0.07"),
        WalletConfigItem(name: "autoExpandDelayNanoseconds", defaultValue: "500_000_000"),
        WalletConfigItem(name: "punchDelayNanoseconds", defaultValue: "80_000_000"),
        WalletConfigItem(name: "punchScale", defaultValue: "0.86"),
        WalletConfigItem(name: "flipAngle", defaultValue: "180.0"),
        WalletConfigItem(name: "openFlipAngle", defaultValue: "360.0"),
        WalletConfigItem(name: "flipDuration", defaultValue: "0.4"),
        WalletConfigItem(name: "flipBounce", defaultValue: "0.02"),
        WalletConfigItem(name: "cardSwipeMinimumDistance", defaultValue: "28"),
        WalletConfigItem(name: "selectedCardSpringResponse", defaultValue: "0.5"),
        WalletConfigItem(name: "selectedCardSpringDamping", defaultValue: "0.8"),
        WalletConfigItem(name: "selectedCardUp", defaultValue: "-60"),
        WalletConfigItem(name: "selectedCardScale", defaultValue: "1.12"),
        WalletConfigItem(name: "swipeSpringResponse", defaultValue: "0.6"),
        WalletConfigItem(name: "swipeSpringDamping", defaultValue: "0.75"),
        WalletConfigItem(name: "backFaceRotationAngle", defaultValue: "180.0"),
        WalletConfigItem(name: "flipPerspective", defaultValue: "0.5"),
        WalletConfigItem(name: "backVisibleStartAngle", defaultValue: "90.0"),
        WalletConfigItem(name: "backVisibleEndAngle", defaultValue: "270.0"),
        WalletConfigItem(name: "fullRotationAngle", defaultValue: "360.0"),
        WalletConfigItem(name: "hiddenOpacity", defaultValue: "0.0"),
        WalletConfigItem(name: "visibleOpacity", defaultValue: "1.0"),
        WalletConfigItem(name: "gyroscopeNeutralAngle", defaultValue: "0.0"),
        WalletConfigItem(name: "gyroscopeMaxTiltAngle", defaultValue: "4.5"),
        WalletConfigItem(name: "gyroscopeMotionScale", defaultValue: "20.0"),
        WalletConfigItem(name: "gyroscopeUpdateInterval", defaultValue: "1.0 / 60.0"),
        WalletConfigItem(name: "gyroscopeResetDuration", defaultValue: "0.45"),
        WalletConfigItem(name: "cardLayouts", defaultValue: "[-62/10/0/0.98/0.9, -20/10/0/0.98/0.9, 12/12/0/0.98/0.9]")
    ]

    static let settingsDefaultValues = Dictionary(
        uniqueKeysWithValues: settingsItems.map { ($0.id, $0.defaultValue) }
    )
}
