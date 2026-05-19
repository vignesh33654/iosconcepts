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
    static let bottomPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 10
    static let cardStrokeWidth: CGFloat = 2
    static let pocketZIndex = 10.0
    static let selectedCardZIndex = 100.0
    static let secondCardIndex = 1
    static let collapsedRotation = 0.0
    static let baseCardZIndexOffset = 1

    static let springResponse = 0.45
    static let springDamping = 0.69
    static let springBlendDuration = 0.08
    static let expandDelayStep = 0.08
    static let collapseDelayStep = 0.07
    static let autoExpandDelayNanoseconds: UInt64 = 500_000_000  // Auto-expand after 0.5s
    static let punchDelayNanoseconds: UInt64 = 80_000_000
    static let punchScale: CGFloat = 0.86

    static let flipAngle = 180.0
    static let openFlipAngle = 360.0
    static let flipDuration = 0.72
    static let flipBounce = 0.02
    static let cardSwipeMinimumDistance: CGFloat = 28
    static let selectedCardSpringResponse = 0.5
    static let selectedCardSpringDamping = 0.8
    static let selectedCardUp: CGFloat = -80
    static let swipeSpringResponse = 0.6
    static let swipeSpringDamping = 0.75
    static let backFaceRotationAngle = 180.0
    static let flipPerspective: CGFloat = 0.5
    static let backVisibleStartAngle = 90.0
    static let backVisibleEndAngle = 270.0
    static let fullRotationAngle = 360.0
    static let hiddenOpacity = 0.0
    static let visibleOpacity = 1.0
    static let cardBorderEndColor = Color(red: 0.82, green: 0.82, blue: 0.82)
    static let cardLayouts: [WalletCardLayout] = [
        WalletCardLayout(lift: -60, rest: 9, rotation: 0, scale: 1.025, widthScale: 0.86),
        WalletCardLayout(lift: -28, rest: 10, rotation: 0, scale: 1.022, widthScale: 0.88),
        WalletCardLayout(lift: 12, rest: 23, rotation: 0, scale: 1.012, widthScale: 0.9)
    ]
}
