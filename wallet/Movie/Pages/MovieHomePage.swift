import SwiftUI

struct MovieHomePage: View {
    private typealias Style = MovieHomeStyle

    private static let upperRows = ["A", "B", "C", "D", "E"]
    private static let lowerRows = ["F", "G", "H", "I"]
    private static let seatNumbers = Array(1...9)
    private static let initialSold: Set<String> = []

    private let showtimes: [Showtime] = [
        Showtime(id: "1125", time: "11:25 AM", screen: "SCR - 1"),
        Showtime(id: "1200", time: "12:00 PM", screen: "SCR - 2"),
        Showtime(id: "1625", time: "04:25 PM", screen: "SCR - 1"),
        Showtime(id: "1725", time: "05:25 PM", screen: "SCR - 3"),
    ]

    @State private var selectedShowtime: Showtime.ID = "1125"
    @State private var selectedSeats: Set<String> = []
    private let soldSeats: Set<String> = MovieHomePage.initialSold

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Style.Palette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, Style.Layout.headerTop)

                showtimeSelector
                    .padding(.top, Style.Layout.showtimeTop)

                seatGrid
                    .padding(.top, Style.Layout.seatGridTop)

                Spacer(minLength: 0)

                screenIndicator
                    .padding(.bottom, Style.Layout.screenBottom)

                legendBar
                    .padding(.bottom, Style.Layout.legendBottom)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: Style.Layout.headerGap) {
            Button {
                // Back action — wire to parent navigation.
            } label: {
                movieAssetImage(Style.Asset.back)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: Style.Layout.backButtonSize, height: Style.Layout.backButtonSize)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            movieAssetImage(Style.Asset.poster)
                .resizable()
                .scaledToFill()
                .frame(width: Style.Layout.posterSize, height: Style.Layout.posterSize)
                .clipShape(RoundedRectangle(cornerRadius: Style.Layout.posterCornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: Style.Layout.titleSubtitleGap) {
                Text("Interstellar")
                    .font(.geist(Style.Typography.title, weight: .medium))
                    .foregroundStyle(.white)
                Text("IMAX cinemas, Bangalore")
                    .font(.geist(Style.Typography.subtitle))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Style.Layout.horizontalPadding)
    }

    private var showtimeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Style.Layout.showtimeSpacing) {
                ForEach(showtimes) { showtime in
                    showtimeCard(showtime)
                }
            }
            .padding(.horizontal, Style.Layout.horizontalPadding)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }

    private func showtimeCard(_ showtime: Showtime) -> some View {
        let isSelected = selectedShowtime == showtime.id

        return Button {
            selectedShowtime = showtime.id
        } label: {
            VStack(spacing: Style.Layout.showtimeTextGap) {
                Text(showtime.time)
                    .font(.geist(Style.Typography.showtime))
                    .foregroundStyle(.white)
                Text(showtime.screen)
                    .font(.geist(Style.Typography.showtimeScreen))
                    .foregroundStyle(Style.Palette.textSecondary)
            }
            .frame(width: Style.Layout.showtimeWidth, height: Style.Layout.showtimeHeight)
            .background(showtimeBackground)
            .overlay(showtimeBorder(isSelected: isSelected))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(showtime.time) \(showtime.screen)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var showtimeBackground: some View {
        LinearGradient(
            colors: [Style.Palette.cardTop, Style.Palette.cardBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .clipShape(RoundedRectangle(cornerRadius: Style.Layout.showtimeCornerRadius, style: .continuous))
    }

    private func showtimeBorder(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: Style.Layout.showtimeCornerRadius, style: .continuous)
            .strokeBorder(
                isSelected ? Style.Palette.accent : Style.Palette.cardBorder,
                lineWidth: isSelected ? Style.Layout.selectedShowtimeBorder : Style.Layout.showtimeBorder
            )
    }

    private var seatGrid: some View {
        HStack(alignment: .top, spacing: Style.Layout.rowLabelGap) {
            rowLabelColumn
            seatColumn
        }
    }

    private var rowLabelColumn: some View {
        VStack(spacing: 0) {
            ForEach(Self.upperRows, id: \.self) { row in
                rowLabel(row)
            }

            Color.clear.frame(height: Style.Layout.sectionGap)

            ForEach(Self.lowerRows, id: \.self) { row in
                rowLabel(row)
            }
        }
        .frame(width: Style.Layout.rowLabelWidth)
    }

    private func rowLabel(_ row: String) -> some View {
        Text(row)
            .font(.geist(Style.Typography.rowLabel))
            .foregroundStyle(.white)
            .frame(width: Style.Layout.rowLabelWidth, height: Style.Layout.seatHeight, alignment: .center)
    }

    private var seatColumn: some View {
        VStack(spacing: 0) {
            ForEach(Self.upperRows, id: \.self) { row in
                seatRow(for: row)
            }

            Color.clear.frame(height: Style.Layout.sectionGap)

            ForEach(Self.lowerRows, id: \.self) { row in
                seatRow(for: row)
            }
        }
    }

    private func seatRow(for row: String) -> some View {
        HStack(spacing: Style.Layout.seatStride - Style.Layout.seatBox) {
            ForEach(Self.seatNumbers, id: \.self) { number in
                seatCell(row: row, number: number)
            }
        }
        .frame(height: Style.Layout.seatHeight)
    }

    private func seatCell(row: String, number: Int) -> some View {
        let id = "\(row)-\(number)"
        let state = seatState(for: id)

        return Button {
            toggle(id, state: state)
        } label: {
            SeatChair(number: number, state: state)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Seat \(row)\(number)")
        .accessibilityValue(state.accessibilityValue)
        .accessibilityAddTraits(state == .sold ? .isStaticText : [])
    }

    private func seatState(for id: String) -> SeatState {
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

    private var screenIndicator: some View {
        VStack(spacing: Style.Layout.screenTextGap) {
            Text("SCREEN THIS WAY")
                .font(.geist(Style.Typography.screenLabel))
                .tracking(Style.Layout.screenTextTracking)
                .foregroundStyle(.white.opacity(0.78))

            ScreenArc()
                .stroke(screenArcGradient, style: StrokeStyle(lineWidth: Style.Layout.screenArcLineWidth, lineCap: .round))
                .frame(height: Style.Layout.screenArcHeight)
                .padding(.horizontal, Style.Layout.screenArcHorizontalPadding)
        }
    }

    private var screenArcGradient: LinearGradient {
        LinearGradient(
            colors: [
                Style.Palette.accent.opacity(0),
                Style.Palette.accent.opacity(0.95),
                Style.Palette.accent.opacity(0),
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var legendBar: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: Style.Layout.legendSpacing) {
                legendItem(label: "Available", swatch: .availableSwatch)
                legendItem(label: "Selected", swatch: .selectedSwatch)
                legendItem(label: "Sold", swatch: .soldSwatch)
            }

            Spacer(minLength: 0)
            theatreViewButton
        }
        .padding(.horizontal, Style.Layout.horizontalPadding)
        .frame(height: Style.Layout.legendHeight)
    }

    private func legendItem(label: String, swatch: LegendSwatch) -> some View {
        HStack(spacing: Style.Layout.legendItemGap) {
            swatchView(swatch)
                .frame(width: Style.Layout.legendSwatch, height: Style.Layout.legendSwatch)

            Text(label)
                .font(.geist(Style.Typography.legend))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private func swatchView(_ swatch: LegendSwatch) -> some View {
        switch swatch {
        case .availableSwatch:
            RoundedRectangle(cornerRadius: Style.Layout.legendCornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.75), lineWidth: Style.Layout.legendStrokeWidth)
        case .selectedSwatch:
            RoundedRectangle(cornerRadius: Style.Layout.legendCornerRadius, style: .continuous)
                .fill(Style.Palette.accent)
        case .soldSwatch:
            RoundedRectangle(cornerRadius: Style.Layout.legendCornerRadius, style: .continuous)
                .fill(Style.Palette.soldSeat)
        }
    }

    private var theatreViewButton: some View {
        Button {
            // Open theatre view — wire to parent navigation.
        } label: {
            movieAssetImage(Style.Asset.theatre)
                .resizable()
                .scaledToFill()
                .frame(width: Style.Layout.theatreButton, height: Style.Layout.theatreButton)
                .clipShape(RoundedRectangle(cornerRadius: Style.Layout.theatreButtonCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open theatre view")
    }
}

#Preview {
    MovieHomePage()
}
