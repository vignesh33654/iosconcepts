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
    @State private var showsSeatMapControls = false
    @State private var seatMapPerspective = ChairMapPerspectiveConfig.standard
    @State private var screenSheetHeight: CGFloat = Style.Layout.Screen.collapsedHeight
    @State private var isScreenFullView = false
    private let soldSeats: Set<String> = MovieHomePage.initialSold

    var body: some View {
        GeometryReader { geometry in
            let screenSheetExpandedHeight = geometry.size.height * Style.Layout.Screen.expandedHeightRatio
            let rawScreenProgress = (screenSheetHeight - Style.Layout.Screen.collapsedHeight) / max(
                Style.Layout.Screen.collapsedHeight,
                screenSheetExpandedHeight - Style.Layout.Screen.collapsedHeight
            )
            let screenProgress = min(1, max(0, rawScreenProgress))
            let visibleLegendHeight = (Style.Layout.Legend.height + Style.Layout.Page.legendBottom) * (1 - screenProgress)
            let visibleScreenBottom = Style.Layout.Page.screenBottom * (1 - screenProgress)
            let hiddenLegendOffset = (Style.Layout.Legend.height + Style.Layout.Page.legendBottom) * screenProgress
            let fixedTopContentHeight = Style.Layout.Page.headerTop + Style.Layout.Header.poster + Style.Layout.Page.timesTop + Style.Layout.Time.height
            let visibleScreenLabelHeight = (Style.Layout.Screen.labelHeight + Style.Layout.Screen.gap) * (1 - screenProgress)
            let screenIndicatorHeight = visibleScreenLabelHeight + screenSheetHeight
            let scrollableHeight = max(
                Style.Layout.Page.minimumScrollableHeight,
                geometry.size.height - fixedTopContentHeight - screenIndicatorHeight - visibleScreenBottom - visibleLegendHeight
            )
            let backgroundScale = isScreenFullView ? Style.Layout.Page.fullViewBackgroundScale : 1

            ZStack(alignment: .bottomTrailing) {
                Style.Palette.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                        .padding(.top, Style.Layout.Page.headerTop)

                    showtimeSelector
                        .padding(.top, Style.Layout.Page.timesTop)

                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            seatGrid
                                .padding(.top, Style.Layout.Page.seatsTop)
                        }
                    }
                    .frame(height: scrollableHeight)
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .scaleEffect(backgroundScale)
                .clipped()
                .animation(
                    .spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping),
                    value: isScreenFullView
                )

                VStack(spacing: 0) {
                    MovieScreenIndicator(
                        height: $screenSheetHeight,
                        expandedHeight: screenSheetExpandedHeight,
                        fullHeight: geometry.size.height,
                        isFullView: $isScreenFullView
                    )
                    .padding(.bottom, visibleScreenBottom)

                    legendBar
                        .padding(.bottom, Style.Layout.Page.legendBottom)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                .offset(y: hiddenLegendOffset)
                .clipped()

                if !isScreenFullView {
                    seatMapControlOverlay
                }

                if showsTheatreView {
                    theatreOverlay
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
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
        ChairMapView(
            selectedSeats: $selectedSeats,
            soldSeats: soldSeats,
            perspectiveConfig: seatMapPerspective
        )
    }


    private var seatMapControlOverlay: some View {
        GeometryReader { geometry in
            VStack {
                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: Style.Layout.SeatMapControls.gap) {
                    Spacer(minLength: 0)

                    if showsSeatMapControls {
                        ChairMapPerspectiveControls(
                            config: $seatMapPerspective,
                            maxHeight: geometry.size.height * Style.Layout.SeatMapControls.maxHeightRatio
                        )
                        .frame(width: Style.Layout.SeatMapControls.width)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }

                    Button {
                        withAnimation(.easeInOut(duration: Style.Layout.SeatMapControls.animationDuration)) {
                            showsSeatMapControls.toggle()
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: Style.Layout.SeatMapControls.icon, weight: .medium))
                            .foregroundStyle(showsSeatMapControls ? Style.Palette.accent : .white)
                            .frame(width: Style.Layout.SeatMapControls.button, height: Style.Layout.SeatMapControls.button)
                            .background(.black.opacity(Style.Layout.SeatMapControls.backgroundOpacity), in: Circle())
                            .overlay {
                                Circle()
                                    .strokeBorder(
                                        .white.opacity(Style.Layout.SeatMapControls.borderOpacity),
                                        lineWidth: Style.Layout.SeatMapControls.border
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Seat map perspective controls")
                }
                .padding(.trailing, Style.Layout.Page.padding)
                .padding(.bottom, Style.Layout.Legend.height + Style.Layout.Page.legendBottom + Style.Layout.SeatMapControls.bottomGap)
            }
        }
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
                .overlay {
                    RoundedRectangle(cornerRadius: Style.Layout.Theatre.radius, style: .continuous)
                        .strokeBorder(.white.opacity(0.3), lineWidth: Style.Layout.Theatre.border)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Open theatre view")
    }

    private var theatreOverlay: some View {
        TheatrePanoramaView(imageName: Style.Asset.theatre) {
            withAnimation(.easeInOut) {
                showsTheatreView = false
            }
        }
    }
}

#Preview {
    MovieHomePage()
}
