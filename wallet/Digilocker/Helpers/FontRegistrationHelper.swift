//
//  FontRegistrationHelper.swift
//  iosconcepts
//
//  Created by Codex on 21/05/26.
//

import CoreText
import Foundation

enum FontRegistrationHelper {
    private static var registeredFontNames = Set<String>()

    static func registerFont(fileName: String, fileExtension: String, postScriptName: String) {
        guard !registeredFontNames.contains(postScriptName) else { return }

        let fontURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
            ?? Bundle.main.url(
                forResource: fileName,
                withExtension: fileExtension,
                subdirectory: "Digilocker/Assets"
            )

        guard let fontURL else { return }

        var error: Unmanaged<CFError>?
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
        registeredFontNames.insert(postScriptName)
    }
}
