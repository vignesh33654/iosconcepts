//
//  AnimationResetButton.swift
//  iosconcepts
//
//  Created by vignesh on 18/05/26.
//

import SwiftUI

struct AnimationResetButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 36, height: 36)
                .background(.white.opacity(0.7), in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset animation")
    }
}

#Preview {
    AnimationResetButton(action: {})
}
