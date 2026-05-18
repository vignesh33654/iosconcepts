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
    var cardImageName: String = "Arav front"
    var backCardImageName: String = "Arav back"
    var isCardVisible: Bool = true

    var body: some View {
        ZStack(alignment: .top) {
            bundledImage(named: "Background")
                .frame(width: width)
                .offset(y: -6)   
            

            cardStack

            bundledImage(named: "Pocket 2")
                .frame(width: width + 2)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: -8)
                .offset(y: 44)                   // ← pocket flush at wallet bottom
        }
        .shadow(color: .black.opacity(0), radius: 28, x: 0, y: 0)
        .padding(.bottom, 16)
    }

    private var cardStack: some View {
        ZStack(alignment: .top) {
            walletCard(width: width * 0.86)
                .offset(x: 0, y: 4 )          // ← back card peek

            walletCard(width: width * 0.88)
                .offset(x: 0, y: 9)          // ← middle card peek

            walletCard(width: width * 0.9)
                .offset(x: 0, y: 16)                 // ← front card peek
                .opacity(isCardVisible ? 1 : 0)
        }
    }

    private func walletCard(width cardWidth: CGFloat) -> some View {
        Card(
            width: cardWidth,
            centerX: 0,
            expandedY: 0,
            collapsedY: 0,
            isExpanded: true,
            frontImageName: cardImageName,
            backImageName: backCardImageName,
            onTap: {},
            isPositioned: false,
            isInteractive: false,
            shadowOpacity: 0.2,
            shadowRadius: 12,
            shadowX: -2,
            shadowY: 3
        )
    }

    @ViewBuilder
    private func bundledImage(named name: String) -> some View {
        if let image = UIImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    Wallet(width: 350)
        .padding()
}
