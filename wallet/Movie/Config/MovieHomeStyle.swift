import SwiftUI

struct MovieHomeStyle {
    enum Palette {
        static let background = Color(red: 0x01 / 255, green: 0x01 / 255, blue: 0x01 / 255)
        static let cardTop = Color.black
        static let cardBottom = Color(red: 0x23 / 255, green: 0x23 / 255, blue: 0x27 / 255)
        static let cardBorder = Color(red: 0x1E / 255, green: 0x1D / 255, blue: 0x20 / 255)
        static let textSecondary = Color(red: 0x87 / 255, green: 0x87 / 255, blue: 0x87 / 255)
        static let seatNumber = Color(red: 0x91 / 255, green: 0x91 / 255, blue: 0x91 / 255)
        static let availableSeat = Color.white.opacity(0.8)
        static let soldSeat = Color.white.opacity(0.46)
        static let accent = Color(red: 0.96, green: 0.09, blue: 0.08)
    }

    enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let headerTop: CGFloat = 12
        static let showtimeTop: CGFloat = 22
        static let seatGridTop: CGFloat = 24
        static let screenBottom: CGFloat = 18
        static let legendBottom: CGFloat = 16

        static let posterSize: CGFloat = 36
        static let posterCornerRadius: CGFloat = 7
        static let backButtonSize: CGFloat = 40
        static let headerGap: CGFloat = 12
        static let titleSubtitleGap: CGFloat = 6

        static let showtimeWidth: CGFloat = 94
        static let showtimeHeight: CGFloat = 45
        static let showtimeSpacing: CGFloat = 6
        static let showtimeTextGap: CGFloat = 2
        static let showtimeCornerRadius: CGFloat = 12
        static let selectedShowtimeBorder: CGFloat = 1.4
        static let showtimeBorder: CGFloat = 1

        static let seatBox: CGFloat = 33
        static let seatImageWidth: CGFloat = 32
        static let seatImageHeight: CGFloat = 40
        static let seatHeight: CGFloat = 46
        static let seatStride: CGFloat = 37
        static let rowLabelWidth: CGFloat = 30
        static let rowLabelGap: CGFloat = 9
        static let sectionGap: CGFloat = 38
        static let seatNumberTopPadding: CGFloat = 10

        static let screenTextGap: CGFloat = 10
        static let screenTextTracking: CGFloat = 2.4
        static let screenArcHeight: CGFloat = 20
        static let screenArcHorizontalPadding: CGFloat = 32
        static let screenArcLineWidth: CGFloat = 1.6
        static let screenArcControlDepth: CGFloat = 0.6

        static let legendSpacing: CGFloat = 16
        static let legendItemGap: CGFloat = 6
        static let legendHeight: CGFloat = 48
        static let legendSwatch: CGFloat = 20
        static let legendCornerRadius: CGFloat = 4
        static let legendStrokeWidth: CGFloat = 1.2
        static let theatreButton: CGFloat = 48
        static let theatreButtonCornerRadius: CGFloat = 12
    }

    enum Typography {
        static let title: CGFloat = 16
        static let subtitle: CGFloat = 14
        static let showtime: CGFloat = 12
        static let showtimeScreen: CGFloat = 10
        static let rowLabel: CGFloat = 14
        static let screenLabel: CGFloat = 11
        static let legend: CGFloat = 12
        static let seatNumber: CGFloat = 10
    }

    enum Asset {
        static let back = "Back"
        static let poster = "Header image"
        static let theatre = "Theatre view"
        static let availableChair = "Chair"
        static let selectedChair = "Filled chair"
    }
}
