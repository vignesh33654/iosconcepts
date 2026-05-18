//
//  FaceIDUnlockButton.swift
//  iosconcepts
//
//  Created by vignesh on 18/05/26.
//

import SwiftUI

enum FaceIDUnlockState {
    case idle
    case scanning
    case unlocked
}

struct FaceIDUnlockButton: View {
    let state: FaceIDUnlockState
    let action: () -> Void

    private let iconSize = 56.0
    private let tapAreaSize = 92.0

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Image(systemName: "faceid")
                        .font(.system(size: iconSize, weight: .light))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color(red: 0.32, green: 0.3, blue: 0.29))
                        .scaleEffect(state == .scanning ? 0.92 : 1.0)
                        .opacity(state == .unlocked ? 0 : 1)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: iconSize, weight: .regular))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.blue)
                        .scaleEffect(state == .unlocked ? 1.0 : 0.72)
                        .opacity(state == .unlocked ? 1 : 0)
                }
                .frame(width: tapAreaSize, height: tapAreaSize)

                Text("Face ID")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.secondary)
                    .opacity(state == .unlocked ? 0 : 1)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(state != .idle)
        .accessibilityLabel("Unlock with Face ID")
    }
}

#Preview {
    VStack(spacing: 32) {
        FaceIDUnlockButton(state: .idle, action: {})
        FaceIDUnlockButton(state: .scanning, action: {})
        FaceIDUnlockButton(state: .unlocked, action: {})
    }
}
