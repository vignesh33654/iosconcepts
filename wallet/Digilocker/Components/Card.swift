//
//  Card.swift
//  iosconcepts
//
//  Created by vignesh on 19/05/26.
//

import SwiftUI
import UIKit

struct WalletCardView: View {
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
    let borderEndColor: Color
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
                borderEndColor: borderEndColor
            )
            .opacity(isShowingBack ? hiddenOpacity : visibleOpacity)

            CardImageView(
                imageName: backImageName,
                width: width,
                cornerRadius: cornerRadius,
                strokeWidth: strokeWidth,
                borderEndColor: borderEndColor
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
        .offset(y: yOffset)
        .scaleEffect(displayScale)
        .rotationEffect(.degrees(isSelected ? 0 : rotation))
        .offset(x: selectedOffset.width, y: selectedOffset.height)
        .zIndex(zIndex)
        .allowsHitTesting(isExpanded)
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
}

private struct CardImageView: View {
    let imageName: String
    let width: CGFloat
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    let borderEndColor: Color

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
                                colors: [.white, borderEndColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                }
        }
    }
}

struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]

    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}
