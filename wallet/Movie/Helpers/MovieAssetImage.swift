import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

func movieAssetImage(_ name: String) -> Image {
    #if canImport(UIKit)
    if let url = Bundle.main.url(forResource: name, withExtension: "png"),
       let image = UIImage(contentsOfFile: url.path) {
        return Image(uiImage: image)
    }
    #endif
    return Image(name)
}
