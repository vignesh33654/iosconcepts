//
//  WalletPreviewConfig.swift
//  iosconcepts
//
//  Created by vignesh on 19/05/26.
//

import SwiftUI

/// Preview-only configuration for testing wallet values
struct WalletPreviewConfig: View {
    @State private var width: CGFloat = 320
    @State private var padding: CGFloat = 38
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                let screenFrame = geo.frame(in: .global)
                
                Wallet(
                    width: width,
                    screenCenter: CGPoint(x: screenFrame.midX, y: screenFrame.midY)
                )
            }
            
            VStack(spacing: 16) {
                VStack {
                    Text("Width: \(Int(width))")
                        .font(.caption)
                    Slider(value: $width, in: 200...400)
                }
                
                VStack {
                    Text("Padding: \(Int(padding))")
                        .font(.caption)
                    Slider(value: $padding, in: 0...100)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview("Adjustable Wallet") {
    WalletPreviewConfig()
}
