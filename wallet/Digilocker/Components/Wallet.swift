//
//  Wallet.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI
import UIKit

struct Wallet: View {
    private typealias Config = WalletConfig

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

    @State private var isExpanded = false
    @State private var displayScales: [CGFloat] = WalletLayoutCalculator.repeatedScales(
        Config.defaultInitialCardScale,
        count: Config.defaultCardCount
    )
    @State private var flippedCardIndex: Int? = nil
    @State private var flipAngles: [Double] = WalletLayoutCalculator.repeatedAngles(
        Config.defaultResetFlipAngle,
        count: Config.defaultCardCount
    )
    @State private var cardBaseCenters: [Int: CGPoint] = [:]

    var body: some View {
        VStack(spacing: Config.mainStackSpacing) {
            Spacer().frame(height: Config.headerTopSpacing)
            header
            Spacer()
            walletContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var header: some View {
        VStack(spacing: Config.headerSpacing) {
            Text(Config.title)
                .font(.system(size: Config.titleFontSize, weight: .regular, design: .serif))
                .foregroundStyle(.black)
                .minimumScaleFactor(Config.titleMinimumScale)
                .lineLimit(Config.headerLineLimit)

            Text(Config.subtitle)
                .font(.system(size: Config.subtitleFontSize, weight: .regular, design: .serif))
                .foregroundStyle(.secondary)
                .minimumScaleFactor(Config.subtitleMinimumScale)
                .lineLimit(Config.headerLineLimit)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Config.headerHorizontalPadding)
    }

    private var walletContent: some View {
        ZStack(alignment: .top) {
            image(named: Config.backgroundImageName)
                .frame(width: width)
                .offset(y: Config.backgroundOffsetY)

            cardStack

            image(named: Config.pocketImageName)
                .frame(width: width + Config.pocketWidthExtra)
                .offset(y: Config.pocketOffsetY)
                .zIndex(Config.pocketZIndex)
        }
        .contentShape(Rectangle())
        .padding(.bottom, Config.bottomPadding)
        .task {
            // Auto-expand on appear
            try? await Task.sleep(nanoseconds: Config.autoExpandDelayNanoseconds)
            guard !Task.isCancelled else { return }

            withAnimation(walletSpring) {
                isExpanded = true
            }
        }
        .task(id: isExpanded, updateCardScales)
    }

    private var cardStack: some View {
        ZStack(alignment: .top) {
            ForEach(Config.cardLayouts.indices, id: \.self) { index in
                walletCard(
                    index: index,
                    frontImageName: frontImageName(for: index),
                    backImageName: backImageName(for: index)
                )
            }
        }
        .onPreferenceChange(CardCenterPreferenceKey.self) { centers in
            cardBaseCenters = centers
        }
    }

    private func walletCard(index: Int, frontImageName: String, backImageName: String) -> some View {
        let isFlipped = flippedCardIndex == index
        let layout = Config.cardLayouts[index]

        return WalletCardView(
            width: width * layout.widthScale,
            frontImageName: frontImageName,
            backImageName: backImageName,
            isExpanded: isExpanded,
            isFlipped: isFlipped,
            flipAngle: flipAngles[index],
            displayScale: displayScales[index],
            yOffset: isExpanded ? layout.lift : layout.rest,
            rotation: isExpanded ? layout.rotation : Config.collapsedRotation,
            selectedOffset: centerOffset(for: index),
            zIndex: isFlipped ? Config.selectedCardZIndex : Double(index + Config.baseCardZIndexOffset),
            cornerRadius: Config.cardCornerRadius,
            strokeWidth: Config.cardStrokeWidth,
            backFaceRotationAngle: Config.backFaceRotationAngle,
            flipPerspective: Config.flipPerspective,
            backVisibleStartAngle: Config.backVisibleStartAngle,
            backVisibleEndAngle: Config.backVisibleEndAngle,
            fullRotationAngle: Config.fullRotationAngle,
            hiddenOpacity: Config.hiddenOpacity,
            visibleOpacity: Config.visibleOpacity,
            borderEndColor: Config.cardBorderEndColor
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
        .animation(.smooth(duration: Config.flipDuration, extraBounce: Config.flipBounce), value: flipAngles[index])
        .animation(
            .spring(response: Config.selectedCardSpringResponse, dampingFraction: Config.selectedCardSpringDamping),
            value: flippedCardIndex
        )
    }

    private func updateCardScales() async {
        if isExpanded {
            withAnimation(.none) {
                displayScales = WalletLayoutCalculator.repeatedScales(Config.punchScale, count: Config.defaultCardCount)
            }
            try? await Task.sleep(nanoseconds: Config.punchDelayNanoseconds)
            guard !Task.isCancelled else { return }
            withAnimation(walletSpring) {
                displayScales = WalletLayoutCalculator.scales(from: Config.cardLayouts)
            }
        } else {
            flipAngles = WalletLayoutCalculator.repeatedAngles(Config.defaultResetFlipAngle, count: Config.defaultCardCount)
            flippedCardIndex = nil

            withAnimation(walletSpring) {
                displayScales = WalletLayoutCalculator.repeatedScales(Config.defaultInitialCardScale, count: Config.defaultCardCount)
            }
        }
    }

    private func toggleCardFlip(index: Int) {
        guard isExpanded else { return }

        withAnimation(.spring(response: Config.tapSpringResponse, dampingFraction: Config.tapSpringDamping)) {
            if flippedCardIndex == index {
                flipAngles[index] = Config.defaultResetFlipAngle
                flippedCardIndex = nil
            } else {
                if let previousIndex = flippedCardIndex {
                    flipAngles[previousIndex] = Config.defaultResetFlipAngle
                }

                flippedCardIndex = index
                flipAngles[index] = Config.flipAngle
            }
        }
    }

    private func frontImageName(for index: Int) -> String {
        WalletLayoutCalculator.imageName(
            for: index,
            primaryName: cardImageName,
            secondaryName: Config.secondCardFrontImageName,
            secondaryIndex: Config.secondCardIndex
        )
    }

    private func backImageName(for index: Int) -> String {
        WalletLayoutCalculator.imageName(
            for: index,
            primaryName: backCardImageName,
            secondaryName: Config.secondCardBackImageName,
            secondaryIndex: Config.secondCardIndex
        )
    }

    private func centerOffset(for index: Int) -> CGSize {
        WalletLayoutCalculator.selectedOffset(
            flippedCardIndex: flippedCardIndex,
            index: index,
            cardCenter: cardBaseCenters[index],
            screenCenter: screenCenter,
            selectedCardUp: Config.selectedCardUp
        )
    }

    private func cardAnimation(index: Int) -> Animation {
        WalletLayoutCalculator.cardAnimation(
            index: index,
            cardCount: Config.defaultCardCount,
            isExpanded: isExpanded,
            expandDelayStep: Config.expandDelayStep,
            collapseDelayStep: Config.collapseDelayStep,
            spring: walletSpring
        )
    }

    private var walletSpring: Animation {
        .spring(
            response: Config.springResponse,
            dampingFraction: Config.springDamping,
            blendDuration: Config.springBlendDuration
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
    let backFaceRotationAngle: Double
    let flipPerspective: CGFloat
    let backVisibleStartAngle: Double
    let backVisibleEndAngle: Double
    let fullRotationAngle: Double
    let hiddenOpacity: Double
    let visibleOpacity: Double
    let borderEndColor: Color
    let onTap: () -> Void

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
            .rotation3DEffect(.degrees(backFaceRotationAngle), axis: (x: 1, y: 0, z: 0))
            .opacity(isShowingBack ? visibleOpacity : hiddenOpacity)
        }
        .contentShape(Rectangle())
        .allowsHitTesting(isExpanded)
        .rotation3DEffect(
            .degrees(flipAngle),
            axis: (x: 1, y: 0, z: 0),
            perspective: flipPerspective
        )
        .offset(y: yOffset)
        .scaleEffect(displayScale)
        .rotationEffect(.degrees(isFlipped ? 0 : rotation))
        .offset(x: selectedOffset.width, y: selectedOffset.height)
        .zIndex(zIndex)
        .onTapGesture(perform: onTap)
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
                width: min(geo.size.width - WalletConfig.previewHorizontalPadding, WalletConfig.previewMaxWalletWidth),
                screenCenter: CGPoint(x: screenFrame.midX, y: screenFrame.midY)
            )

            Spacer()
        }
    }
}
