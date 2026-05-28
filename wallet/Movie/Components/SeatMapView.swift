import SwiftUI
import UIKit

struct SeatMapView: View {
    @Binding var selectedSeatIDs: Set<Seat.ID>
    let config: MovieConfig

    private let rows = Array("ABCDEFGHI").map(String.init)
    private let seatNumbers = Array(1...9)

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(rows, id: \.self) { row in
                    HStack(alignment: .center, spacing: 10) {
                        Text(row)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(.white)
                            .frame(width: 22, alignment: .leading)

                        seatRow(for: row)
                    }
                    .padding(.bottom, row == "G" ? config.sectionGap : config.rowGap)
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 14)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }

    private func seatRow(for row: String) -> some View {
        HStack(spacing: config.seatGap) {
            ForEach(seats(for: row)) { seat in
                Button {
                    toggle(seat)
                } label: {
                    MovieSeatIcon(
                        number: seat.number,
                        isSelected: selectedSeatIDs.contains(seat.id),
                        config: config
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Seat \(seat.row)\(seat.number)")
            }
        }
    }

    private func seats(for row: String) -> [Seat] {
        seatNumbers.map { number in
            Seat(row: row, number: number)
        }
    }

    private func toggle(_ seat: Seat) {
        if selectedSeatIDs.contains(seat.id) {
            selectedSeatIDs.remove(seat.id)
            return
        }

        guard selectedSeatIDs.count < config.maxSelectedSeats else {
            return
        }

        selectedSeatIDs.insert(seat.id)
    }
}

private struct MovieSeatIcon: View {
    let number: Int
    let isSelected: Bool
    let config: MovieConfig

    var body: some View {
        ZStack(alignment: .top) {
            Image(uiImage: chairImage)
                .renderingMode(isSelected ? .original : .template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(.white.opacity(0.36))

            Text("\(number)")
                .font(.system(size: 9, weight: .regular))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.top, 12)
        }
        .frame(width: config.seatIconWidth, height: config.seatIconHeight)
        .contentShape(Rectangle())
    }

    private var chairImage: UIImage {
        let resourceName = isSelected ? "Filled chair" : "Chair"

        if let url = Bundle.main.url(forResource: resourceName, withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }

        return UIImage(named: "\(resourceName).png") ?? UIImage()
    }
}

#Preview {
    SeatMapView(selectedSeatIDs: .constant([]), config: MovieConfig())
        .background(.black)
}
