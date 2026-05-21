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
    @State private var isShowingConfig = false

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

                settingsButton

                if isShowingConfig {
                    WalletConfigPopover {
                        withAnimation(.smooth(duration: 0.2)) {
                            isShowingConfig = false
                        }
                    }
                    .frame(
                        width: geometry.size.width * Config.settingsPanelWidthRatio,
                        height: geometry.size.height * Config.settingsPanelHeightRatio
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                    .zIndex(1000)
                }
            }
            .animation(.smooth(duration: 0.2), value: isShowingConfig)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var settingsButton: some View {
        Button {
            withAnimation(.smooth(duration: 0.2)) {
                isShowingConfig.toggle()
            }
        } label: {
            Image(systemName: Config.settingsIconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: Config.settingsButtonSize, height: Config.settingsButtonSize)
                .background(.regularMaterial)
                .clipShape(Circle())
        }
        .padding(Config.settingsButtonPadding)
        .accessibilityLabel(Config.settingsButtonAccessibilityLabel)
        .zIndex(1001)
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
