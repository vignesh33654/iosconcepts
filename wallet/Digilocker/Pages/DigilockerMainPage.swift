//
//  DigilockerMainPage.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI

struct DigilockerMainPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DigilockerHeaderView(
                title: "DigiLocker",
                subtitle: "Hello DigiLocker concept is connected and ready to scale."
            )

            Label("New concept test word: verified", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.green)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DigilockerMainPage()
}
