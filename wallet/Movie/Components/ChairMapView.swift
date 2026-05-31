import SwiftUI

private struct ChairRow: Identifiable, Hashable {
    let name: String
    let numbers: [Int]
    let aisleAfter: Bool

    var id: String { name }
}

struct ChairMapView: View {
    @Binding var selectedSeats: Set<String>
    let soldSeats: Set<String>

    private typealias Style = MovieHomeStyle

    private static let fullRow = Array(1...9)
    private static let hiddenSeats: Set<String> = ["F-5", "G-5", "H-5"]
    private static let rows: [ChairRow] = [
        ChairRow(name: "A", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "B", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "C", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "D", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "E", numbers: fullRow, aisleAfter: true),
        ChairRow(name: "F", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "G", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "H", numbers: fullRow, aisleAfter: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Self.rows) { row in
                chairRow(row)

                if row.aisleAfter {
                    Color.clear.frame(height: Style.Layout.Seat.aisleGap)
                }
            }
        }
    }

    private func chairRow(_ row: ChairRow) -> some View {
        HStack(alignment: .center, spacing: Style.Layout.Seat.rowGap) {
            Text(row.name)
                .font(.geist(Style.Typography.rowLabel))
                .foregroundStyle(.white)
                .frame(width: Style.Layout.Seat.rowWidth, height: Style.Layout.Seat.slotHeight, alignment: .center)

            HStack(spacing: Style.Layout.Seat.step - Style.Layout.Seat.box) {
                ForEach(row.numbers, id: \.self) { number in
                    chairButton(row: row.name, number: number)
                }
            }
        }
        .frame(height: Style.Layout.Seat.slotHeight)
    }

    private func chairButton(row: String, number: Int) -> some View {
        let id = "\(row)-\(number)"
        let state = chairState(for: id)
        let showsSeat = !Self.hiddenSeats.contains(id)

        return Button {
            toggle(id, state: state)
        } label: {
            Chair(number: number, state: state)
                .opacity(showsSeat ? 1 : 0)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!showsSeat)
        .accessibilityHidden(!showsSeat)
        .accessibilityLabel("Seat \(row)\(number)")
        .accessibilityValue(state.accessibilityValue)
        .accessibilityAddTraits(state == .sold ? .isStaticText : [])
    }

    private func chairState(for id: String) -> SeatState {
        if soldSeats.contains(id) { return .sold }
        if selectedSeats.contains(id) { return .selected }
        return .available
    }

    private func toggle(_ id: String, state: SeatState) {
        switch state {
        case .sold:
            return
        case .selected:
            selectedSeats.remove(id)
        case .available:
            selectedSeats.insert(id)
        }
    }
}

#Preview {
    ChairMapView(selectedSeats: .constant([]), soldSeats: [])
        .padding()
        .background(.black)
}
