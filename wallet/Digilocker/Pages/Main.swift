//
//  Main.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI

struct Main: View {
    private let frontCardImageName = "Arav front"
    private let backCardImageName = "Arav back"
    private let dimAmount = 0.0

    @State private var unlockState: FaceIDUnlockState = .idle
    @State private var isUnlockControlVisible = true
    @State private var isExpanded = false

    var body: some View {
        GeometryReader { geometry in
            let cardWidth = min(geometry.size.width - 40, 450) * 0.9

            ZStack {
                content(width: cardWidth, height: geometry.size.height)

                Color.black.opacity(isExpanded ? dimAmount : 0)
                    .ignoresSafeArea()
                    .allowsHitTesting(isExpanded)
                    .onTapGesture { collapseCard() }

                resetControl
            }
        }
    }

    private func content(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer().frame(height: height * 0.18)
            DigilockerHeader()
            Spacer()

            FaceIDUnlockButton(state: unlockState) {
                unlockForPreview()
            }
            .opacity(isUnlockControlVisible ? 1 : 0)
            .animation(.smooth(duration: 0.28), value: isUnlockControlVisible)
            .animation(.smooth(duration: 0.2), value: unlockState)

            Spacer()

            Wallet(
                width: width,
                cardImageName: frontCardImageName,
                backCardImageName: backCardImageName,
                isExpanded: isExpanded
            )
            .contentShape(Rectangle())
            .allowsHitTesting(unlockState == .unlocked)
            .onTapGesture { toggleWallet() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resetControl: some View {
        VStack {
            HStack {
                Spacer()
                AnimationResetButton {
                    resetAnimation()
                }
            }
            Spacer()
        }
        .padding(.top, 18)
        .padding(.trailing, 18)
    }

    private func unlockForPreview() {
        guard unlockState == .idle else { return }

        withAnimation(.smooth(duration: 0.2)) {
            unlockState = .scanning
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.smooth(duration: 0.2)) {
                unlockState = .unlocked
            }

            withAnimation(.spring(response: 0.62, dampingFraction: 0.74, blendDuration: 0.08)) {
                isExpanded = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            withAnimation(.smooth(duration: 0.28)) {
                isUnlockControlVisible = false
            }
        }
    }

    private func toggleWallet() {
        guard unlockState == .unlocked else { return }

        withAnimation(.spring(response: 0.62, dampingFraction: 0.74, blendDuration: 0.08)) {
            isExpanded.toggle()
        }
    }

    private func collapseCard() {
        withAnimation(.spring(response: 0.62, dampingFraction: 0.74, blendDuration: 0.08)) {
            isExpanded = false
        }
    }

    private func resetAnimation() {
        withAnimation(.smooth(duration: 0.2)) {
            unlockState = .idle
            isUnlockControlVisible = true
            isExpanded = false
        }
    }
}

#Preview {
    Main()
}
