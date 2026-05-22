//
//  Main.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI

struct Main: View {
    private typealias Config = WalletConfig

    private let frontCardImageName = Config.firstCardFrontImageName
    private let backCardImageName = Config.firstCardBackImageName
    private let requiresFaceID: Bool

    @State private var unlockState: FaceIDUnlockState = .idle

    init(requiresFaceID: Bool = true) {
        self.requiresFaceID = requiresFaceID
        _unlockState = State(initialValue: requiresFaceID ? .idle : .unlocked)
    }

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - Config.mainWalletHorizontalPadding, Config.mainMaxWalletWidth) * Config.mainWalletWidthScale
            let screenFrame = geometry.frame(in: .global)

            ZStack(alignment: .topLeading) {
                Wallet(
                    width: cardWidth,
                    cardImageName: frontCardImageName,
                    backCardImageName: backCardImageName,
                    isUnlocked: unlockState == .unlocked,
                    screenCenter: CGPoint(x: screenFrame.midX, y: screenFrame.midY)
                )

                if requiresFaceID && unlockState != .unlocked {
                    FaceIDUnlockButton(
                        state: unlockState,
                        onAuthenticationStart: startFaceIDScan,
                        onAuthenticationFailure: resetFaceIDScan
                    ) {
                        unlockAfterFaceID()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private func startFaceIDScan() {
        guard unlockState == .idle else { return }

        withAnimation(.smooth(duration: 0.2)) {
            unlockState = .scanning
        }
    }

    private func unlockAfterFaceID() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(Config.faceIDSuccessAnimationDelay))

            guard unlockState == .scanning else { return }

            withAnimation(.smooth(duration: 0.2)) {
                unlockState = .unlocked
            }
        }
    }

    private func resetFaceIDScan() {
        guard unlockState != .unlocked else { return }

        withAnimation(.smooth(duration: 0.2)) {
            unlockState = .idle
        }
    }
}

#Preview {
    Main(requiresFaceID: false)
}
