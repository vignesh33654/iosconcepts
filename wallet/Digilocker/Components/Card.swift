//
//  Card.swift
//  iosconcepts
//
//  Created by vignesh on 18/05/26.
//

import SwiftUI
import UIKit

struct Card: View {
    let width: CGFloat
    let centerX: CGFloat
    let expandedY: CGFloat
    let collapsedY: CGFloat
    let isExpanded: Bool
    let frontImageName: String
    let backImageName: String
    let onTap: () -> Void
    var isPositioned: Bool = true
    var isInteractive: Bool = true
    var shadowOpacity: Double = 0.22
    var shadowRadius: CGFloat = 80
    var shadowX: CGFloat = -5
    var shadowY: CGFloat = 5

    // Tweak card animation here.
    private let flipDuration = 0.65
    private let flipBounce = 0.02
    private let flipDegrees = 180.0
    private let dragFlipThreshold = 45.0
    private let flipAxisX = 1.0
    private let flipAxisY = 0.0
    private let flipAxisZ = 0.0
    private let flipPerspective = 1.0

    // Tweak card styling here.
    private let cornerRadius = 10.0
    private let strokeWidth = 2.0

    @State private var flipAngle = 0.0
    @State private var dragFlipAngle = 0.0

    var body: some View {
        positionedCard
            .onChange(of: isExpanded) { _, newValue in
                handleExpansionChange(newValue)
            }
    }

    @ViewBuilder
    private var positionedCard: some View {
        if isPositioned {
            interactiveCard
                .position(x: centerX, y: isExpanded ? expandedY : collapsedY)
        } else {
            interactiveCard
        }
    }

    @ViewBuilder
    private var interactiveCard: some View {
        if isInteractive {
            cardContent
                .onTapGesture { onTap() }
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            updateDrag(value)
                        }
                        .onEnded { value in
                            finishDrag(value)
                        }
                )
        } else {
            cardContent
        }
    }

    private var cardContent: some View {
        ZStack {
            cardImage(named: frontImageName)
                .opacity(isShowingBack ? 0 : 1)

            cardImage(named: backImageName)
                .rotation3DEffect(
                    .degrees(flipDegrees),
                    axis: (flipAxisX, flipAxisY, flipAxisZ),
                    perspective: flipPerspective
                )
                .opacity(isShowingBack ? 1 : 0)
        }
        .opacity(isExpanded ? 1 : 0)
        .allowsHitTesting(isInteractive && isExpanded)
        .rotation3DEffect(
            .degrees(displayedFlipAngle),
            axis: (flipAxisX, flipAxisY, flipAxisZ),
            perspective: flipPerspective
        )
    }

    private func handleExpansionChange(_ expanded: Bool) {
        flipAngle = 0
        dragFlipAngle = 0
    }

    private func updateDrag(_ value: DragGesture.Value) {
        let horizontalDrag = abs(value.translation.width)
        let verticalDrag = abs(value.translation.height)

        guard horizontalDrag > verticalDrag else {
            dragFlipAngle = 0
            return
        }

        dragFlipAngle = min(horizontalDrag / dragFlipThreshold, 1) * flipDegrees
    }

    private func finishDrag(_ value: DragGesture.Value) {
        let horizontalDrag = abs(value.translation.width)
        let verticalDrag = abs(value.translation.height)
        let shouldShowBack = horizontalDrag > dragFlipThreshold && horizontalDrag > verticalDrag

        withAnimation(flipAnimation) {
            flipAngle = shouldShowBack ? flipDegrees : 0
            dragFlipAngle = 0
        }
    }

    private var displayedFlipAngle: Double {
        flipAngle + dragFlipAngle
    }

    private var flipAnimation: Animation {
        .smooth(duration: flipDuration, extraBounce: flipBounce)
    }

    private var isShowingBack: Bool {
        let normalizedAngle = displayedFlipAngle.truncatingRemainder(dividingBy: 360)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
        return positiveAngle >= 90 && positiveAngle <= 270
    }

    @ViewBuilder
    private func cardImage(named name: String) -> some View {
        if let image = UIImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: width)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white, Color(red: 0.82, green: 0.82, blue: 0.82)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                }
                .shadow(color: .black.opacity(shadowOpacity), radius: shadowRadius, x: shadowX, y: shadowY)
        }
    }
}

#Preview {
    Card(
        width: 320,
        centerX: 180,
        expandedY: 260,
        collapsedY: 620,
        isExpanded: true,
        frontImageName: "Arav front",
        backImageName: "Arav back",
        onTap: {}
    )
}
