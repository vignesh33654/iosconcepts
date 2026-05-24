//
//  SplashScreen.swift
//  iosconcepts
//
//  Created by Codex on 24/05/26.
//

import SwiftUI
import UIKit

struct SplashScreen: View {
    private let shimmerDuration = 2.0
    private let fadeDuration = 0.25

    @State private var isMainVisible = false
    @State private var splashOpacity = 1.0
    @State private var shimmerOffset: CGFloat = -0.7

    var body: some View {
        ZStack {
            if isMainVisible {
                Main()
                    .transition(.opacity)
            }

            splashContent
                .opacity(splashOpacity)
                .allowsHitTesting(splashOpacity > 0.01)
        }
        .task {
            withAnimation(.smooth(duration: shimmerDuration)) {
                shimmerOffset = 1.35
            }

            try? await Task.sleep(for: .seconds(shimmerDuration))

            withAnimation(.smooth(duration: fadeDuration)) {
                isMainVisible = true
                splashOpacity = 0
            }
        }
    }

    private var splashContent: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack(spacing: 6) {
                documentLogo
                    .frame(width: 58, height: 58)

                animatedTitle
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var documentLogo: some View {
        if let image = loadDocumentLogo() {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Image("Document")
                .resizable()
                .scaledToFit()
        }
    }

    private func loadDocumentLogo() -> UIImage? {
        let logoURL = Bundle.main.url(forResource: "Document", withExtension: "png")
            ?? Bundle.main.url(
                forResource: "Document",
                withExtension: "png",
                subdirectory: "Digilocker/Assets"
            )

        guard let logoURL else { return nil }
        return UIImage(contentsOfFile: logoURL.path)
    }

    private var animatedTitle: some View {
        Text("Digilocker")
            .font(.custom("Geist", size: 28).weight(.medium))
            .foregroundStyle(Color(red: 0.35, green: 0.16, blue: 0.95))
            .overlay {
                GeometryReader { geometry in
                    Capsule()
                        .fill(.white)
                        .frame(width: 48, height: geometry.size.height + 24)
                        .blur(radius: 12)
                        .opacity(0.82)
                        .offset(x: geometry.size.width * shimmerOffset)
                }
                .mask(
                    Text("Digilocker")
                        .font(.custom("Geist", size: 28).weight(.medium))
                )
                .clipped()
            }
    }
}

#Preview {
    SplashScreen()
}
