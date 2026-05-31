import SwiftUI

private struct Showtime: Identifiable, Equatable {
    let id: String
    let time: String
    let screen: String
}

private enum LegendSwatch {
    case availableSwatch
    case selectedSwatch
    case soldSwatch
}

struct MovieHomePage: View {
    private typealias Style = MovieHomeStyle

    private static let initialSold: Set<String> = []

    private let showtimes: [Showtime] = [
        Showtime(id: "1125", time: "11:25 AM", screen: "SCR - 1"),
        Showtime(id: "1200", time: "12:00 PM", screen: "SCR - 2"),
        Showtime(id: "1625", time: "04:25 PM", screen: "SCR - 1"),
        Showtime(id: "1725", time: "05:25 PM", screen: "SCR - 3"),
    ]

    @State private var selectedShowtime: Showtime.ID = "1125"
    @State private var selectedSeats: Set<String> = []
    @State private var showsTheatreView = false
    private let soldSeats: Set<String> = MovieHomePage.initialSold

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Style.Palette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, Style.Layout.Page.headerTop)

                showtimeSelector
                    .padding(.top, Style.Layout.Page.timesTop)

                seatGrid
                    .padding(.top, Style.Layout.Page.seatsTop)

                Spacer(minLength: 0)

                screenIndicator
                    .padding(.bottom, Style.Layout.Page.screenBottom)

                legendBar
                    .padding(.bottom, Style.Layout.Page.legendBottom)
            }

            if showsTheatreView {
                theatreOverlay
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(spacing: Style.Layout.Header.gap) {
            Button {
                // Back action — wire to parent navigation.
            } label: {
                movieAssetImage(Style.Asset.back)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .frame(width: Style.Layout.Header.backButton, height: Style.Layout.Header.backButton)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            movieAssetImage(Style.Asset.poster)
                .resizable()
                .scaledToFill()
                .frame(width: Style.Layout.Header.poster, height: Style.Layout.Header.poster)
                .clipShape(RoundedRectangle(cornerRadius: Style.Layout.Header.posterRadius, style: .continuous))

            VStack(alignment: .leading, spacing: Style.Layout.Header.titleGap) {
                Text("Interstellar")
                    .font(.geist(Style.Typography.title, weight: .medium))
                    .foregroundStyle(.white)
                Text("IMAX cinemas, Bangalore")
                    .font(.geist(Style.Typography.subtitle))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, Style.Layout.Page.padding)
    }

    private var showtimeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Style.Layout.Time.gap) {
                ForEach(showtimes) { showtime in
                    showtimeCard(showtime)
                }
            }
            .padding(.horizontal, Style.Layout.Page.padding)
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
    }

    private func showtimeCard(_ showtime: Showtime) -> some View {
        let isSelected = selectedShowtime == showtime.id

        return Button {
            selectedShowtime = showtime.id
        } label: {
            VStack(spacing: Style.Layout.Time.textGap) {
                Text(showtime.time)
                    .font(.geist(Style.Typography.showtime))
                    .foregroundStyle(.white)
                Text(showtime.screen)
                    .font(.geist(Style.Typography.showtimeScreen))
                    .foregroundStyle(Style.Palette.textSecondary)
            }
            .frame(width: Style.Layout.Time.width, height: Style.Layout.Time.height)
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
        .clipShape(RoundedRectangle(cornerRadius: Style.Layout.Time.radius, style: .continuous))
    }

    private func showtimeBorder(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: Style.Layout.Time.radius, style: .continuous)
            .strokeBorder(
                isSelected ? Style.Palette.accent : Style.Palette.cardBorder,
                lineWidth: isSelected ? Style.Layout.Time.selectedBorder : Style.Layout.Time.border
            )
    }

    private var seatGrid: some View {
        ChairMapView(selectedSeats: $selectedSeats, soldSeats: soldSeats)
    }

    private var screenIndicator: some View {
        VStack(spacing: Style.Layout.Screen.gap) {
            Text("SCREEN THIS WAY")
                .font(.geist(Style.Typography.screenLabel))
                .tracking(Style.Layout.Screen.tracking)
                .foregroundStyle(.white.opacity(0.78))

            ScreenArc()
                .stroke(screenArcGradient, style: StrokeStyle(lineWidth: Style.Layout.Screen.lineWidth, lineCap: .round))
                .frame(height: Style.Layout.Screen.arcHeight)
                .padding(.horizontal, Style.Layout.Screen.arcPadding)
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
            HStack(spacing: Style.Layout.Legend.gap) {
                legendItem(label: "Available", swatch: .availableSwatch)
                legendItem(label: "Selected", swatch: .selectedSwatch)
                legendItem(label: "Sold", swatch: .soldSwatch)
            }

            Spacer(minLength: 0)
            theatreViewButton
        }
        .padding(.horizontal, Style.Layout.Page.padding)
        .frame(height: Style.Layout.Legend.height)
    }

    private func legendItem(label: String, swatch: LegendSwatch) -> some View {
        HStack(spacing: Style.Layout.Legend.itemGap) {
            swatchView(swatch)
                .frame(width: Style.Layout.Legend.swatch, height: Style.Layout.Legend.swatch)

            Text(label)
                .font(.geist(Style.Typography.legend))
                .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private func swatchView(_ swatch: LegendSwatch) -> some View {
        switch swatch {
        case .availableSwatch:
            RoundedRectangle(cornerRadius: Style.Layout.Legend.radius, style: .continuous)
                .strokeBorder(.white.opacity(0.75), lineWidth: Style.Layout.Legend.lineWidth)
        case .selectedSwatch:
            RoundedRectangle(cornerRadius: Style.Layout.Legend.radius, style: .continuous)
                .fill(Style.Palette.accent)
        case .soldSwatch:
            RoundedRectangle(cornerRadius: Style.Layout.Legend.radius, style: .continuous)
                .fill(Style.Palette.soldSeat)
        }
    }

    private var theatreViewButton: some View {
        Button {
            withAnimation(.easeOut) {
                showsTheatreView = true
            }
        } label: {
            movieAssetImage(Style.Asset.theatre)
                .resizable()
                .scaledToFill()
                .frame(width: Style.Layout.Theatre.button, height: Style.Layout.Theatre.button)
                .clipShape(RoundedRectangle(cornerRadius: Style.Layout.Theatre.radius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open theatre view")
    }

    private var theatreOverlay: some View {
        ZStack(alignment: .topTrailing) {
            PanoramaView(imageName: Style.Asset.theatre)
                .ignoresSafeArea()

            Button {
                withAnimation(.easeInOut) {
                    showsTheatreView = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: Style.Layout.Theatre.closeIcon, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: Style.Layout.Theatre.closeButton, height: Style.Layout.Theatre.closeButton)
                    .background(.black.opacity(Style.Layout.Theatre.closeBackgroundOpacity), in: Circle())
            }
            .buttonStyle(.plain)
            .padding(.top, Style.Layout.Theatre.closeTop)
            .padding(.trailing, Style.Layout.Theatre.closeTrailing)
            .accessibilityLabel("Close theatre view")
        }
    }
}

private struct ScreenArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX, y: rect.minY)
        let end = CGPoint(x: rect.maxX, y: rect.minY)
        let control = CGPoint(
            x: rect.midX,
            y: rect.maxY + rect.height * MovieHomeStyle.Layout.Screen.curve
        )

        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}

#Preview {
    MovieHomePage()
}
