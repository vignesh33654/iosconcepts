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
    private let backCardImageName = "Arav back"

    @State private var unlockState: FaceIDUnlockState = .idle
    @State private var bypassFaceID = true  // Face ID disabled

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - Config.mainWalletHorizontalPadding, Config.mainMaxWalletWidth) * Config.mainWalletWidthScale
            let screenFrame = geometry.frame(in: .global)

            ZStack(alignment: .topLeading) {
                Wallet(
                    width: cardWidth,
                    cardImageName: frontCardImageName,
                    backCardImageName: backCardImageName,
                    screenCenter: CGPoint(x: screenFrame.midX, y: screenFrame.midY)
                )

                if !bypassFaceID {
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
        withAnimation(.smooth(duration: 0.2)) {
            unlockState = .unlocked
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
    Main()
}
