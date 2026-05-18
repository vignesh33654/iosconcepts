//
//  DigilockerHeader.swift
//  iosconcepts
//
//  Created by vignesh on 18/05/26.
//

import SwiftUI

struct DigilockerHeader: View {
    var body: some View {
        VStack(spacing: 4) {
            Text("Welcome to digilocker")
                .font(.system(size: 24, weight: .regular, design: .serif))
                .foregroundStyle(.black)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text("Use your Face ID to check out all your IDs")
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
    DigilockerHeader()
}
