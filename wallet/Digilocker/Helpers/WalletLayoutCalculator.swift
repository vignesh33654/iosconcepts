//
//  WalletLayoutCalculator.swift
//  iosconcepts
//
//  Created by vignesh on 19/05/26.
//

import SwiftUI

/// This file only does the small math for the wallet.
/// Change WalletConfig.swift to move cards, resize them, or change when the back side shows.
enum WalletLayoutCalculator {
    static func scales(from layouts: [WalletCardLayout]) -> [CGFloat] {
        layouts.map(\.scale)
    }

    static func repeatedScales(_ scale: CGFloat, count: Int) -> [CGFloat] {
        Array(repeating: scale, count: count)
    }

    static func repeatedAngles(_ angle: Double, count: Int) -> [Double] {
        Array(repeating: angle, count: count)
    }

    static func imageName(for index: Int, primaryName: String, secondaryName: String, secondaryIndex: Int) -> String {
        index == secondaryIndex ? secondaryName : primaryName
    }

    static func selectedOffset(
        selectedCardIndex: Int?,
        index: Int,
        cardCenter: CGPoint?,
        screenCenter: CGPoint?,
        selectedCardUp: CGFloat
    ) -> CGSize {
        guard
            selectedCardIndex == index,
            let cardCenter,
            let screenCenter
        else {
            return .zero
        }

        return CGSize(
            width: screenCenter.x - cardCenter.x,
            height: screenCenter.y - cardCenter.y + selectedCardUp
        )
    }

    static func cardAnimation(
        index: Int,
        cardCount: Int,
        isExpanded: Bool,
        expandDelayStep: Double,
        collapseDelayStep: Double,
        spring: Animation
    ) -> Animation {
        let delay = isExpanded
            ? Double(index) * expandDelayStep
            : Double(cardCount - 1 - index) * collapseDelayStep

        return spring.delay(delay)
    }

    static func isShowingBack(
        flipAngle: Double,
        fullRotationAngle: Double,
        backVisibleStartAngle: Double,
        backVisibleEndAngle: Double
    ) -> Bool {
        let normalizedAngle = flipAngle.truncatingRemainder(dividingBy: fullRotationAngle)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + fullRotationAngle : normalizedAngle
        return positiveAngle >= backVisibleStartAngle && positiveAngle <= backVisibleEndAngle
    }
}
