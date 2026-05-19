//
//  Main.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI

struct Main: View {
    private let maxWalletWidth = 450.0
    private let walletHorizontalPadding = 40.0
    private let walletWidthScale = 0.9
    private let frontCardImageName = "Arav front"
    private let backCardImageName = "Arav back"

    @State private var unlockState: FaceIDUnlockState = .unlocked  // Start unlocked for testing
    @State private var bypassFaceID = true  // Toggle this to enable/disable Face ID

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - walletHorizontalPadding, maxWalletWidth) * walletWidthScale
            let screenFrame = geometry.frame(in: .global)

            ZStack {
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
