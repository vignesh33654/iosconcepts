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
        static let horizontalPadding = Page.padding
        static let headerTop = Page.headerTop
        static let showtimeTop = Page.timesTop
        static let seatGridTop = Page.seatsTop
        static let screenBottom = Page.screenBottom
        static let legendBottom = Page.legendBottom

        static let posterSize = Header.poster
        static let posterCornerRadius = Header.posterRadius
        static let backButtonSize = Header.backButton
        static let headerGap = Header.gap
        static let titleSubtitleGap = Header.titleGap

        static let showtimeWidth = Time.width
        static let showtimeHeight = Time.height
        static let showtimeSpacing = Time.gap
        static let showtimeTextGap = Time.textGap
        static let showtimeCornerRadius = Time.radius
        static let selectedShowtimeBorder = Time.selectedBorder
        static let showtimeBorder = Time.border

        static let seatBox = Seat.box
        static let seatImageWidth = Seat.width
        static let seatImageHeight = Seat.height
        static let seatHeight = Seat.slotHeight
        static let seatStride = Seat.step
        static let rowLabelWidth = Seat.rowWidth
        static let rowLabelGap = Seat.rowGap
        static let sectionGap = Seat.aisleGap
        static let seatNumberTopPadding = Seat.numberTop

        static let screenTextGap = Screen.gap
        static let screenTextTracking = Screen.tracking
        static let screenArcHeight = Screen.arcHeight
        static let screenArcHorizontalPadding = Screen.arcPadding
        static let screenArcLineWidth = Screen.lineWidth
        static let screenArcControlDepth = Screen.curve

        static let legendSpacing = Legend.gap
        static let legendItemGap = Legend.itemGap
        static let legendHeight = Legend.height
        static let legendSwatch = Legend.swatch
        static let legendCornerRadius = Legend.radius
        static let legendStrokeWidth = Legend.lineWidth
        static let theatreButton = Theatre.button
        static let theatreButtonCornerRadius = Theatre.radius

        enum Page {
            static let padding: CGFloat = 24
            static let headerTop: CGFloat = 12
            static let timesTop: CGFloat = 22
            static let seatsTop: CGFloat = 24
            static let screenBottom: CGFloat = 18
            static let legendBottom: CGFloat = 16
        }

        enum Header {
            static let poster: CGFloat = 36
            static let posterRadius: CGFloat = 7
            static let backButton: CGFloat = 24
            static let gap: CGFloat = 12
            static let titleGap: CGFloat = 6
        }

        enum Time {
            static let width: CGFloat = 94
            static let height: CGFloat = 45
            static let gap: CGFloat = 6
            static let textGap: CGFloat = 2
            static let radius: CGFloat = 12
            static let selectedBorder: CGFloat = 1.4
            static let border: CGFloat = 1
        }

        enum Seat {
            static let box: CGFloat = 38
            static let width: CGFloat = 38
            static let height: CGFloat = 48
            static let slotHeight: CGFloat = 52
            static let step: CGFloat = 38
            static let rowWidth: CGFloat = 30
            static let rowGap: CGFloat = 0
            static let aisleGap: CGFloat = 32
            static let numberTop: CGFloat = 10
            static let numberOffsetY: CGFloat = -4
        }

        enum Screen {
            static let gap: CGFloat = 10
            static let tracking: CGFloat = 2.4
            static let arcHeight: CGFloat = 20
            static let arcPadding: CGFloat = 32
            static let lineWidth: CGFloat = 1.6
            static let curve: CGFloat = 0.6
        }

        enum Legend {
            static let gap: CGFloat = 16
            static let itemGap: CGFloat = 6
            static let height: CGFloat = 48
            static let swatch: CGFloat = 20
            static let radius: CGFloat = 4
            static let lineWidth: CGFloat = 1.2
        }

        enum Theatre {
            static let button: CGFloat = 48
            static let radius: CGFloat = 12
            static let border: CGFloat = 1
            static let closeButton: CGFloat = 48
            static let closeIcon: CGFloat = 14
            static let closeTop: CGFloat = 42
            static let closeTrailing: CGFloat = 22
            static let closeBackgroundOpacity: Double = 0.42
        }
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
        static let theatre = "Movie Theatre view"
        static let availableChair = "Chair"
    }
}
