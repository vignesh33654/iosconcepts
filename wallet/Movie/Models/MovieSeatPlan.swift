import Foundation

struct MovieSeatRow: Identifiable, Hashable {
    let name: String
    let numbers: [Int]
    let aisleAfter: Bool

    var id: String { name }
}

enum MovieSeatPlan {
    static let rows: [MovieSeatRow] = [
        MovieSeatRow(name: "A", numbers: fullRow, aisleAfter: false),
        MovieSeatRow(name: "B", numbers: fullRow, aisleAfter: false),
        MovieSeatRow(name: "C", numbers: fullRow, aisleAfter: false),
        MovieSeatRow(name: "D", numbers: fullRow, aisleAfter: false),
        MovieSeatRow(name: "E", numbers: fullRow, aisleAfter: true),
        MovieSeatRow(name: "F", numbers: fullRow, aisleAfter: false),
        MovieSeatRow(name: "G", numbers: fullRow, aisleAfter: false),
        MovieSeatRow(name: "H", numbers: fullRow, aisleAfter: false),
    ]

    static func showsSeat(row: String, number: Int) -> Bool {
        !hiddenSeats.contains("\(row)-\(number)")
    }

    private static let fullRow = Array(1...9)
    private static let hiddenSeats: Set<String> = ["F-5", "G-5", "H-5"]
}
