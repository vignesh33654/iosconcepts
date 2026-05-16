//
//  DigilockerHeaderView.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI

struct DigilockerHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DigilockerHeaderView(
        title: "DigiLocker",
        subtitle: "Secure document access for iosconcepts testing."
    )
    .padding()
}
