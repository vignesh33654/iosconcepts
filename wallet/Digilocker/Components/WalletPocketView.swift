//
//  WalletPocketView.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI
import UIKit

struct WalletPocketView: View {
    let width: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            bundledImage(named: "Background")
                .frame(width: width)

            bundledImage(named: "Pocket")
                .frame(width: width * 0.98)
                .offset(y: -1) // ← pocket overlap on background
        }
        .shadow(color: .black.opacity(0.18), radius: 28, x: 0, y: 18) // ← shadow style
        .padding(.bottom, 16) // ← distance from bottom of screen
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
    WalletPocketView(width: 350)
        .padding()
}
