//
//  RalewayDotsStyle.swift
//  iosconcepts
//
//  Created by Codex on 24/05/26.
//

import SwiftUI

extension View {
    func ralewayDotsStyle() -> some View {
        FontRegistrationHelper.registerFont(
            fileName: "RalewayDots-Regular",
            fileExtension: "ttf",
            postScriptName: "RalewayDots-Regular"
        )

        return self
            .font(.custom("RalewayDots-Regular", size: 60))
            .tracking(-0.41)
            .lineSpacing(0)
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 1.0, green: 0.596, blue: 0.188), location: 0),
                        Gradient.Stop(color: Color(red: 0.224, green: 0.573, blue: 0.408), location: 0.43),
                        Gradient.Stop(color: Color(red: 0.173, green: 0.647, blue: 0.98), location: 1)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}
