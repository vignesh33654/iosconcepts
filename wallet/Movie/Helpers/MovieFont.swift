import SwiftUI

extension Font {
    static func geist(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .light, .ultraLight, .thin:
            name = "Geist-Light"
        case .medium:
            name = "Geist-Medium"
        case .semibold:
            name = "Geist-SemiBold"
        case .bold, .heavy, .black:
            name = "Geist-Bold"
        default:
            name = "Geist-Regular"
        }
        return .custom(name, size: size)
    }
}
