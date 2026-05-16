//
//  Main.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI

struct Main: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: geometry.size.height * 0.20)

                    header

                    Spacer()

                    WalletPocketView(width: min(geometry.size.width - 40, 450))
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            Text("Welcome to digilocker")
                .font(.system(size: 24, weight: .regular, design: .serif))
                .foregroundStyle(.black)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text("All your IDs in one place")
                .font(.system(size: 16, weight: .regular, design: .serif))
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.75)
                .lineLimit(1)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }
}

#Preview {
    Main()
}
