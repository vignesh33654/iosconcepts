import Foundation

struct Viewpoint: Identifiable, Equatable {
    let id: String
    let label: String
    let imageName: String
}

extension Viewpoint {
    static let theatre = Viewpoint(
        id: "theatre",
        label: "Theatre view",
        imageName: "Movie Theatre view"
    )
}
