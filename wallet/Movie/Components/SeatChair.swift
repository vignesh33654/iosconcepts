import SwiftUI

struct SeatChair: View {
    let number: Int
    let state: SeatState

    @State private var showsNumber = true
    @State private var numberRevealTask: Task<Void, Never>?

    private typealias Style = MovieHomeStyle

    var body: some View {
        ZStack(alignment: .top) {
            chairVisual
                .frame(width: Style.Layout.Seat.width, height: Style.Layout.Seat.height)

            Text("\(number)")
                .font(.geist(Style.Typography.seatNumber, weight: .light))
                .foregroundStyle(Style.Palette.seatNumber)
                .padding(.top, Style.Layout.Seat.numberTop)
                .opacity(showsNumber ? 1 : 0)
        }
        .frame(width: Style.Layout.Seat.box, height: Style.Layout.Seat.slotHeight, alignment: .top)
        .onAppear {
            updateNumberVisibility(for: state)
        }
        .onChange(of: state) { _, newState in
            updateNumberVisibility(for: newState)
        }
        .onDisappear {
            numberRevealTask?.cancel()
        }
    }

    @ViewBuilder
    private var chairVisual: some View {
        switch state {
        case .selected:
            SelectedSeat3DChair()
        case .available:
            movieAssetImage(Style.Asset.availableChair)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
        case .sold:
            movieAssetImage(Style.Asset.availableChair)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Style.Palette.soldSeat)
        }
    }

    private func updateNumberVisibility(for state: SeatState) {
        numberRevealTask?.cancel()

        guard state == .selected else {
            showsNumber = true
            return
        }

        showsNumber = false
        numberRevealTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(SelectedSeat3DChair.numberRevealDelay * 1_000_000_000))

            guard !Task.isCancelled else { return }
            await MainActor.run {
                showsNumber = true
            }
        }
    }

}
