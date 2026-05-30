import SwiftUI

struct SeatChair: View {
    let number: Int
    let state: SeatState

    private typealias Style = MovieHomeStyle

    var body: some View {
        ZStack(alignment: .top) {
            movieAssetImage(imageName)
                .renderingMode(state == .selected ? .original : .template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(tint)
                .frame(width: Style.Layout.seatImageWidth, height: Style.Layout.seatImageHeight)

            Text("\(number)")
                .font(.geist(Style.Typography.seatNumber, weight: .light))
                .foregroundStyle(Style.Palette.seatNumber)
                .padding(.top, Style.Layout.seatNumberTopPadding)
        }
        .frame(width: Style.Layout.seatBox, height: Style.Layout.seatHeight, alignment: .top)
    }

    private var imageName: String {
        state == .selected ? Style.Asset.selectedChair : Style.Asset.availableChair
    }

    private var tint: Color {
        switch state {
        case .available: return Style.Palette.availableSeat
        case .selected: return Style.Palette.accent
        case .sold: return Style.Palette.soldSeat
        }
    }
}
