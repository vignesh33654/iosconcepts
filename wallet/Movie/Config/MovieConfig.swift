import SwiftUI

struct MovieConfig {
    let seatIconWidth: CGFloat = 38
    let seatIconHeight: CGFloat = 48
    let seatGap: CGFloat = 0
    let rowGap: CGFloat = 4
    let sectionGap: CGFloat = 40
    let maxSelectedSeats = 4
    let previewButtonFillColor = Color(red: 1, green: 0.35, blue: 0)
    let selectedSeatFillColor = Color(red: 0.96, green: 0.09, blue: 0.08)
    let theatreImageName = Viewpoint.theatre.imageName
}
