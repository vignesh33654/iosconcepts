//
//  Wallet.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI
import UIKit

struct Wallet: View {
    let width: CGFloat
    let cardImageName: String
    let backCardImageName: String
    let screenCenter: CGPoint?

    init(
        width: CGFloat,
        cardImageName: String = "Arav front",
        backCardImageName: String = "Arav back",
        screenCenter: CGPoint? = nil
    ) {
        self.width = width
        self.cardImageName = cardImageName
        self.backCardImageName = backCardImageName
        self.screenCenter = screenCenter
    }

    private let backgroundImageName = "Background"
    private let pocketImageName = "Pocket 2"
    private let secondCardFrontImageName = "Nandhi front"
    private let secondCardBackImageName = "Nandhi back"

    private let backgroundOffsetY: CGFloat = -6
    private let pocketWidthExtra: CGFloat = 2
    private let pocketOffsetY: CGFloat = 44
    private let bottomPadding: CGFloat = 16
    private let cardCornerRadius: CGFloat = 10
    private let cardStrokeWidth: CGFloat = 2

    private let springResponse = 0.45
    private let springDamping = 0.69
    private let springBlendDuration = 0.08
    private let expandDelayStep = 0.08
    private let collapseDelayStep = 0.07
    private let autoExpandDelayNanoseconds: UInt64 = 500_000_000  // Auto-expand after 0.5s
    private let punchDelayNanoseconds: UInt64 = 80_000_000
    private let punchScale: CGFloat = 0.86

    private let flipAngle = 360.0
    private let flipDuration = 0.72
    private let flipBounce = 0.02
    private let selectedCardSpringResponse = 0.5
    private let selectedCardSpringDamping = 0.8
    private let selectedCardUp: CGFloat = -120

    // Simple card configuration - no more array index errors!
    private func cardConfig(for index: Int) -> (lift: CGFloat, rest: CGFloat, rotation: Double, scale: CGFloat, widthScale: CGFloat) {
        switch index {
        case 0: return (lift: -60, rest: 9, rotation: -1.4, scale: 1.025, widthScale: 0.86)
        case 1: return (lift: -28, rest: 10, rotation: 0.8, scale: 1.022, widthScale: 0.88)
        case 2: return (lift: 12, rest: 23, rotation: -0.4, scale: 1.012, widthScale: 0.9)
        default: return (lift: 0, rest: 0, rotation: 0, scale: 1.0, widthScale: 1.0)
        }
    }

    @State private var isExpanded = false
    @State private var displayScales: [CGFloat] = [1, 1, 1]
    @State private var flippedCardIndex: Int? = nil
    @State private var flipAngles: [Double] = [0, 0, 0]
    @State private var cardBaseCenters: [Int: CGPoint] = [:]

    var body: some View {
        ZStack(alignment: .top) {
            image(named: backgroundImageName)
                .frame(width: width)
                .offset(y: backgroundOffsetY)

            cardStack

            image(named: pocketImageName)
                .frame(width: width + pocketWidthExtra)
                .offset(y: pocketOffsetY)
                .zIndex(10)
        }
        .contentShape(Rectangle())
        .padding(.bottom, bottomPadding)
        .task {
            // Auto-expand on appear
            try? await Task.sleep(nanoseconds: autoExpandDelayNanoseconds)
            guard !Task.isCancelled else { return }
            
            withAnimation(walletSpring) {
                isExpanded = true
            }
        }
        .task(id: isExpanded, updateCardScales)
    }

    private var cardStack: some View {
        ZStack(alignment: .top) {
            walletCard(index: 0, frontImageName: cardImageName, backImageName: backCardImageName)
            walletCard(index: 1, frontImageName: secondCardFrontImageName, backImageName: secondCardBackImageName)
            walletCard(index: 2, frontImageName: cardImageName, backImageName: backCardImageName)
        }
        .onPreferenceChange(CardCenterPreferenceKey.self) { centers in
            cardBaseCenters = centers
        }
    }

    private func walletCard(index: Int, frontImageName: String, backImageName: String) -> some View {
        let isFlipped = flippedCardIndex == index
        let config = cardConfig(for: index)

        return WalletCardView(
            width: width * config.widthScale,
            frontImageName: frontImageName,
            backImageName: backImageName,
            isExpanded: isExpanded,
            isFlipped: isFlipped,
            flipAngle: flipAngles[index],
            displayScale: displayScales[index],
            yOffset: isExpanded ? config.lift : config.rest,
            rotation: isExpanded ? config.rotation : 0,
            selectedOffset: centerOffset(for: index),
            zIndex: isFlipped ? 100 : Double(index + 1),
            cornerRadius: cardCornerRadius,
            strokeWidth: cardStrokeWidth
        ) {
            toggleCardFlip(index: index)
        }
        .background {
            GeometryReader { proxy in
                let frame = proxy.frame(in: .global)
                Color.clear.preference(
                    key: CardCenterPreferenceKey.self,
                    value: [index: CGPoint(x: frame.midX, y: frame.midY)]
                )
            }
        }
        .animation(cardAnimation(index: index), value: isExpanded)
        .animation(.smooth(duration: flipDuration, extraBounce: flipBounce), value: flipAngles[index])
        .animation(
            .spring(response: selectedCardSpringResponse, dampingFraction: selectedCardSpringDamping),
            value: flippedCardIndex
        )
    }

    private func updateCardScales() async {
        if isExpanded {
            withAnimation(.none) {
                displayScales = Array(repeating: punchScale, count: 3)
            }
            try? await Task.sleep(nanoseconds: punchDelayNanoseconds)
            guard !Task.isCancelled else { return }
            withAnimation(walletSpring) {
                displayScales = [
                    cardConfig(for: 0).scale,
                    cardConfig(for: 1).scale,
                    cardConfig(for: 2).scale
                ]
            }
        } else {
            flipAngles = [0, 0, 0]
            flippedCardIndex = nil

            withAnimation(walletSpring) {
                displayScales = [1, 1, 1]
            }
        }
    }

    private func toggleCardFlip(index: Int) {
        guard isExpanded else { return }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            if flippedCardIndex == index {
                flipAngles[index] = 0
                flippedCardIndex = nil
            } else {
                if let previousIndex = flippedCardIndex {
                    flipAngles[previousIndex] = 0
                }

                flippedCardIndex = index
                flipAngles[index] = flipAngle
            }
        }
    }

    private func centerOffset(for index: Int) -> CGSize {
        guard
            flippedCardIndex == index,
            let center = cardBaseCenters[index],
            let screenCenter
        else {
            return .zero
        }

        return CGSize(
            width: screenCenter.x - center.x,
            height: screenCenter.y - center.y + selectedCardUp
        )
    }

    private func cardAnimation(index: Int) -> Animation {
        let delay = isExpanded
            ? Double(index) * expandDelayStep
            : Double(2 - index) * collapseDelayStep

        return walletSpring.delay(delay)
    }

    private var walletSpring: Animation {
        .spring(
            response: springResponse,
            dampingFraction: springDamping,
            blendDuration: springBlendDuration
        )
    }

    @ViewBuilder
    private func image(named name: String) -> some View {
        if let image = UIImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

private struct WalletCardView: View {
    let width: CGFloat
    let frontImageName: String
    let backImageName: String
    let isExpanded: Bool
    let isFlipped: Bool
    let flipAngle: Double
    let displayScale: CGFloat
    let yOffset: CGFloat
    let rotation: Double
    let selectedOffset: CGSize
    let zIndex: Double
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat
    let onTap: () -> Void

    var body: some View {
        ZStack {
            CardImageView(
                imageName: frontImageName,
                width: width,
                cornerRadius: cornerRadius,
                strokeWidth: strokeWidth
            )
            .opacity(isShowingBack ? 0 : 1)

            CardImageView(
                imageName: backImageName,
                width: width,
                cornerRadius: cornerRadius,
                strokeWidth: strokeWidth
            )
            .rotation3DEffect(.degrees(180), axis: (x: 1, y: 0, z: 0))
            .opacity(isShowingBack ? 1 : 0)
        }
        .contentShape(Rectangle())
        .allowsHitTesting(isExpanded)
        .rotation3DEffect(
            .degrees(flipAngle),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.5
        )
        .offset(y: yOffset)
        .scaleEffect(displayScale)
        .rotationEffect(.degrees(isFlipped ? 0 : rotation))
        .offset(x: selectedOffset.width, y: selectedOffset.height)
        .zIndex(zIndex)
        .onTapGesture(perform: onTap)
    }

    private var isShowingBack: Bool {
        let normalizedAngle = flipAngle.truncatingRemainder(dividingBy: 360)
        let positiveAngle = normalizedAngle < 0 ? normalizedAngle + 360 : normalizedAngle
        return positiveAngle >= 90 && positiveAngle <= 270
    }
}

private struct CardImageView: View {
    let imageName: String
    let width: CGFloat
    let cornerRadius: CGFloat
    let strokeWidth: CGFloat

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
                                colors: [.white, Color(red: 0.82, green: 0.82, blue: 0.82)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: strokeWidth
                        )
                }
        }
    }
}

private struct CardCenterPreferenceKey: PreferenceKey {
    static var defaultValue: [Int: CGPoint] = [:]

    static func reduce(value: inout [Int: CGPoint], nextValue: () -> [Int: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { _, newValue in newValue })
    }
}

#Preview {
    GeometryReader { geo in
        let screenFrame = geo.frame(in: .global)

        VStack {
            Spacer()

            Wallet(
                width: min(geo.size.width - 48, 340),
                screenCenter: CGPoint(x: screenFrame.midX, y: screenFrame.midY)
            )

            Spacer()
        }
    }
}
