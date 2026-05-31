import SwiftUI

struct BookingSummarySheet: View {
    let seats: Set<String>
    let showtimeLabel: String
    let onConfirm: () -> Void

    private typealias Style = MovieHomeStyle

    private enum Config {
        static let pricePerSeat = 299
        static let cornerRadius: CGFloat = 24
        static let handleWidth: CGFloat = 36
        static let handleHeight: CGFloat = 4
        static let handleRadius: CGFloat = 2
        static let outerPadding: CGFloat = 16
        static let innerPadding: CGFloat = 20
        static let sectionGap: CGFloat = 16
        static let chipRadius: CGFloat = 8
        static let chipPadH: CGFloat = 10
        static let chipPadV: CGFloat = 6
        static let chipGap: CGFloat = 6
        static let buttonHeight: CGFloat = 52
        static let buttonRadius: CGFloat = 14
        static let borderOpacity: Double = 0.12
    }

    private var sortedSeats: [String] {
        seats.sorted {
            let rA = $0.prefix(1), rB = $1.prefix(1)
            if rA != rB { return rA < rB }
            return (Int($0.dropFirst(2)) ?? 0) < (Int($1.dropFirst(2)) ?? 0)
        }
    }

    private var totalPrice: Int { seats.count * Config.pricePerSeat }

    var body: some View {
        VStack(spacing: Config.sectionGap) {
            handle
            seatsSection
            divider
            priceRow
            confirmButton
        }
        .padding(Config.innerPadding)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Config.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Config.cornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(Config.borderOpacity), lineWidth: 1)
        )
        .padding(.horizontal, Style.Layout.Page.padding)
        .padding(.bottom, Config.outerPadding)
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: Config.handleRadius, style: .continuous)
            .fill(.white.opacity(0.28))
            .frame(width: Config.handleWidth, height: Config.handleHeight)
    }

    private var seatsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Selected Seats")
                    .font(.geist(14, weight: .medium))
                    .foregroundStyle(.white)
                Spacer()
                Text(showtimeLabel)
                    .font(.geist(12))
                    .foregroundStyle(.white.opacity(0.46))
            }

            let columns = [GridItem(.adaptive(minimum: 54), spacing: Config.chipGap)]
            LazyVGrid(columns: columns, alignment: .leading, spacing: Config.chipGap) {
                ForEach(sortedSeats, id: \.self) { seat in
                    Text(seat)
                        .font(.geist(12, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, Config.chipPadH)
                        .padding(.vertical, Config.chipPadV)
                        .background(
                            Style.Palette.accent.opacity(0.15),
                            in: RoundedRectangle(cornerRadius: Config.chipRadius, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: Config.chipRadius, style: .continuous)
                                .strokeBorder(Style.Palette.accent.opacity(0.55), lineWidth: 1)
                        )
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(height: 1)
    }

    private var priceRow: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("\(seats.count) seat\(seats.count == 1 ? "" : "s") · IMAX")
                .font(.geist(13))
                .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text("₹\(totalPrice)")
                .font(.geist(20, weight: .semibold))
                .foregroundStyle(.white)
        }
    }

    private var confirmButton: some View {
        Button(action: onConfirm) {
            Text("Confirm Booking")
                .font(.geist(15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Config.buttonHeight)
                .background(
                    Style.Palette.accent,
                    in: RoundedRectangle(cornerRadius: Config.buttonRadius, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.black.ignoresSafeArea()
        BookingSummarySheet(
            seats: ["A-3", "A-4", "B-5"],
            showtimeLabel: "11:25 AM · SCR - 1",
            onConfirm: {}
        )
    }
}
