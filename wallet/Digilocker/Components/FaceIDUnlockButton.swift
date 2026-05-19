//
//  FaceIDUnlockButton.swift
//  iosconcepts
//
//  Created by vignesh on 18/05/26.
//

import LocalAuthentication
import SwiftUI

enum FaceIDUnlockState {
    case idle
    case scanning
    case unlocked
}

struct FaceIDUnlockButton: View {
    let state: FaceIDUnlockState
    let onAuthenticationStart: () -> Void
    let onAuthenticationFailure: () -> Void
    let action: () -> Void

    @State private var isAuthenticating = false

    init(
        state: FaceIDUnlockState,
        onAuthenticationStart: @escaping () -> Void = {},
        onAuthenticationFailure: @escaping () -> Void = {},
        action: @escaping () -> Void
    ) {
        self.state = state
        self.onAuthenticationStart = onAuthenticationStart
        self.onAuthenticationFailure = onAuthenticationFailure
        self.action = action
    }

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .onAppear(perform: authenticateWithFaceID)
    }

    private func authenticateWithFaceID() {
        guard state == .idle, !isAuthenticating else { return }

        isAuthenticating = true
        onAuthenticationStart()

        let context = LAContext()
        context.localizedCancelTitle = "Cancel"

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error), context.biometryType == .faceID else {
            finishAuthentication(success: false)
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock your wallet") { success, _ in
            Task { @MainActor in
                finishAuthentication(success: success)
            }
        }
    }

    @MainActor
    private func finishAuthentication(success: Bool) {
        isAuthenticating = false

        if success {
            action()
        } else {
            onAuthenticationFailure()
        }
    }
}

#Preview {
    FaceIDUnlockButton(state: .idle, action: {})
}
