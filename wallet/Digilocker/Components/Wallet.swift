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

    @State private var displayScales: [CGFloat] =
        WalletLayoutCalculator.repeatedScales(
            Config.defaultInitialCardScale,
            count: Config.defaultCardCount
        )

    @State private var selectedCardIndex: Int? = nil

    @State private var flipAngles: [Double] =
        WalletLayoutCalculator.repeatedAngles(
            Config.defaultResetFlipAngle,
            count: Config.defaultCardCount
        )

    @State private var openFlipAngles: [Double] =
        WalletLayoutCalculator.repeatedAngles(
            Config.defaultResetFlipAngle,
            count: Config.defaultCardCount
        )

    @State private var cardBaseCenters: [Int: CGPoint] = [:]
    @State private var cardBounceOffsets: [CGFloat] = Array(repeating: 0, count: Config.defaultCardCount)

    var body: some View {
        VStack(spacing: Config.mainStackSpacing) {

            Spacer()
                .frame(height: Config.headerTopSpacing)

            header

            Spacer()

            walletContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Config.headerSpacing) {

            Text(Config.title)
                .font(
                    .system(
                        size: Config.titleFontSize,
                        weight: .regular,
                        design: .serif
                    )
                )
                .foregroundStyle(.black)
                .minimumScaleFactor(Config.titleMinimumScale)
                .lineLimit(Config.headerLineLimit)

            Text(Config.subtitle)
                .font(
                    .system(
                        size: Config.subtitleFontSize,
                        weight: .regular,
                        design: .serif
                    )
                )
                .foregroundStyle(.secondary)
                .minimumScaleFactor(Config.subtitleMinimumScale)
                .lineLimit(Config.headerLineLimit)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Config.headerHorizontalPadding)
    }

    // MARK: - Wallet Content

    private var walletContent: some View {
        ZStack(alignment: .top) {

            image(named: Config.backgroundImageName)
                .frame(width: width)
                .offset(y: Config.backgroundOffsetY)
                .allowsHitTesting(false)

            cardStack

            image(named: Config.pocketImageName)
                .frame(width: width + Config.pocketWidthExtra)
                .shadow(
                    color: Config.pocketShadowColor,
                    radius: Config.pocketShadowRadius,
                    x: Config.pocketShadowX,
                    y: Config.pocketShadowY
                )
                .offset(y: Config.pocketOffsetY)
                .zIndex(Config.pocketZIndex)
                .allowsHitTesting(false)
        }
        .padding(.bottom, Config.bottomPadding)

        .task {

            try? await Task.sleep(
                nanoseconds: Config.autoExpandDelayNanoseconds
            )

            guard !Task.isCancelled else { return }

            withAnimation(walletSpring) {
                isExpanded = true
            }
        }

        .task(id: isExpanded, updateCardScales)
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack(alignment: .top) {

            ForEach(
                0..<Config.defaultCardCount,
                id: \.self
            ) { index in

                walletCard(
                    index: index,
                    slot: index,
                    frontImageName: frontImageName(for: index),
                    backImageName: backImageName(for: index)
                )
            }
        }
        .onPreferenceChange(CardCenterPreferenceKey.self) { centers in
            cardBaseCenters = centers
        }
    }

    // MARK: - Wallet Card

    private func walletCard(
        index: Int,
        slot: Int,
        frontImageName: String,
        backImageName: String
    ) -> some View {

        let isSelected = selectedCardIndex == index
        let layout = Config.cardLayouts[slot]
        let isTopWalletCard = slot == Config.defaultCardCount - 1

        let flipAnimation: Animation? = isSelected
            ? .smooth(
                duration: Config.flipDuration,
                extraBounce: Config.flipBounce
            )
            : nil

        return WalletCardView(
            cardIndex: index,
            width: width * layout.widthScale,

            frontImageName: frontImageName,
            backImageName: backImageName,

            isExpanded: isExpanded,
            isSelected: isSelected,

            flipAngle: flipAngles[index],
            openFlipAngle: openFlipAngles[index],

            displayScale: displayScales[slot],

            yOffset: isExpanded
                ? layout.lift
                : layout.rest,

            bounceOffset: cardBounceOffsets[index],

            rotation: isExpanded
                ? layout.rotation
                : Config.collapsedRotation,

            selectedOffset: isSelected
                ? centerOffset(for: index)
                : .zero,

            zIndex: isSelected
                ? 1000
                : Double(slot),

            cornerRadius: Config.cardCornerRadius,
            strokeWidth: Config.cardStrokeWidth,

            backFaceRotationAngle: Config.backFaceRotationAngle,
            flipPerspective: Config.flipPerspective,

            backVisibleStartAngle: Config.backVisibleStartAngle,
            backVisibleEndAngle: Config.backVisibleEndAngle,

            fullRotationAngle: Config.fullRotationAngle,

            hiddenOpacity: Config.hiddenOpacity,
            visibleOpacity: Config.visibleOpacity,

            borderColors: Config.cardAnimatedBorderColors,
            showsStroke: isExpanded && isSelected,
            appliesShadow: (isExpanded || !isTopWalletCard) && !isSelected,

            swipeMinimumDistance: Config.cardSwipeMinimumDistance

        ) {

            selectCard(index: index)

        } onSwipe: { horizontalDistance in

            flipSelectedCard(
                index: index,
                horizontalDistance: horizontalDistance
            )
        }

        .background {

            GeometryReader { proxy in

                let frame = proxy.frame(in: .global)

                Color.clear.preference(
                    key: CardCenterPreferenceKey.self,
                    value: [
                        index: CGPoint(
                            x: frame.midX,
                            y: frame.midY
                        )
                    ]
                )
            }
        }

        .animation(
            cardAnimation(index: slot),
            value: isExpanded
        )

        .animation(
            flipAnimation,
            value: flipAngles[index]
        )

        .animation(
            flipAnimation,
            value: openFlipAngles[index]
        )

        .animation(
            .spring(
                response: Config.selectedCardSpringResponse,
                dampingFraction: Config.selectedCardSpringDamping
            ),
            value: selectedCardIndex
        )
    }

    // MARK: - Update Scales

    private func updateCardScales() async {

        if isExpanded {

            withAnimation(.none) {

                displayScales =
                    WalletLayoutCalculator.repeatedScales(
                        Config.punchScale,
                        count: Config.defaultCardCount
                    )
            }

            try? await Task.sleep(
                nanoseconds: Config.punchDelayNanoseconds
            )

            guard !Task.isCancelled else { return }

            withAnimation(walletSpring) {

                displayScales =
                    WalletLayoutCalculator.scales(
                        from: Config.cardLayouts
                    )
            }

        } else {

            flipAngles =
                WalletLayoutCalculator.repeatedAngles(
                    Config.defaultResetFlipAngle,
                    count: Config.defaultCardCount
                )

            openFlipAngles =
                WalletLayoutCalculator.repeatedAngles(
                    Config.defaultResetFlipAngle,
                    count: Config.defaultCardCount
                )

            selectedCardIndex = nil
            cardBounceOffsets = Array(repeating: 0, count: Config.defaultCardCount)

            withAnimation(walletSpring) {

                displayScales =
                    WalletLayoutCalculator.repeatedScales(
                        Config.defaultInitialCardScale,
                        count: Config.defaultCardCount
                    )
            }
        }
    }

    // MARK: - Select Card

    private func selectCard(index: Int) {

        guard isExpanded else { return }

        let spring = Animation.spring(
            response: 0.45,
            dampingFraction: 0.88
        )

        // CLOSE CARD

        if selectedCardIndex == index {

            var transaction = Transaction()
            transaction.disablesAnimations = true

            withTransaction(transaction) {

                flipAngles[index] = 0
                openFlipAngles[index] = 0
            }

            withAnimation(spring) {
                selectedCardIndex = nil
            }

            let dismissedIndex = index
            for j in 0..<Config.defaultCardCount where j != dismissedIndex {
                let delay = Double(abs(j - dismissedIndex)) * Config.cardBounceDelayStep
                Task { @MainActor in
                    if delay > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { cardBounceOffsets[j] = Config.cardBounceOffset }
                    try? await Task.sleep(nanoseconds: 16_666_667)
                    withAnimation(.spring(
                        response: Config.cardBounceSpringResponse,
                        dampingFraction: Config.cardBounceSpringDamping
                    )) {
                        cardBounceOffsets[j] = 0
                    }
                }
            }

        } else {

            // RESET PREVIOUS CARD

            if let previousIndex = selectedCardIndex {

                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {

                    flipAngles[previousIndex] = 0
                    openFlipAngles[previousIndex] = 0
                }
            }

            // OPEN NEW CARD

            withAnimation(spring) {

                selectedCardIndex = index
                openFlipAngles[index] = Config.openFlipAngle
            }

            // Pull-out dip: cards above the selected card drop into the gap it leaves
            let newIndex = index
            for j in 0..<Config.defaultCardCount where j < newIndex {
                let delay = Double(newIndex - j - 1) * Config.cardBounceDelayStep
                Task { @MainActor in
                    if delay > 0 {
                        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    }
                    var t = Transaction()
                    t.disablesAnimations = true
                    withTransaction(t) { cardBounceOffsets[j] = Config.cardPullOutDipOffset }
                    try? await Task.sleep(nanoseconds: 16_666_667)
                    withAnimation(.spring(
                        response: Config.cardBounceSpringResponse,
                        dampingFraction: Config.cardBounceSpringDamping
                    )) {
                        cardBounceOffsets[j] = 0
                    }
                }
            }
        }
    }

    // MARK: - Flip Card

    private func flipSelectedCard(
        index: Int,
        horizontalDistance: CGFloat
    ) {

        guard
            isExpanded,
            selectedCardIndex == index
        else {
            return
        }

        withAnimation(
            .spring(
                response: Config.swipeSpringResponse,
                dampingFraction: Config.swipeSpringDamping
            )
        ) {

            if isShowingBack(index: index) {

                flipAngles[index] =
                    Config.defaultResetFlipAngle

            } else {

                flipAngles[index] =
                    horizontalDistance < 0
                    ? -Config.flipAngle
                    : Config.flipAngle
            }
        }
    }

    // MARK: - Back Visibility

    private func isShowingBack(index: Int) -> Bool {

        WalletLayoutCalculator.isShowingBack(
            flipAngle: flipAngles[index],
            fullRotationAngle: Config.fullRotationAngle,
            backVisibleStartAngle: Config.backVisibleStartAngle,
            backVisibleEndAngle: Config.backVisibleEndAngle
        )
    }

    // MARK: - Images

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

    // MARK: - Offset

    private func centerOffset(for index: Int) -> CGSize {

        WalletLayoutCalculator.selectedOffset(
            selectedCardIndex: selectedCardIndex,
            index: index,
            cardCenter: cardBaseCenters[index],
            screenCenter: screenCenter,
            selectedCardUp: Config.selectedCardUp,
            visualYOffset: Config.cardLayouts[index].lift
        )
    }

    // MARK: - Card Animation

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

    // MARK: - Spring

    private var walletSpring: Animation {

        .spring(
            response: Config.springResponse,
            dampingFraction: Config.springDamping,
            blendDuration: Config.springBlendDuration
        )
    }

    // MARK: - Image Builder

    @ViewBuilder
    private func image(named name: String) -> some View {

        if let image = UIImage(named: name) {

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

// MARK: - Preview

#Preview {

    GeometryReader { geo in

        let screenFrame = geo.frame(in: .global)

        VStack {

            Spacer()

            Wallet(
                width: min(
                    geo.size.width - WalletConfig.previewHorizontalPadding,
                    WalletConfig.previewMaxWalletWidth
                ),
                screenCenter: CGPoint(
                    x: screenFrame.midX,
                    y: screenFrame.midY
                )
            )

            Spacer()
        }
    }
}
