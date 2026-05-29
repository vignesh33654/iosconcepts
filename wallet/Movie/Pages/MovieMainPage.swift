import SwiftUI

struct MovieMainPage: View {
    private enum Config {
        enum Title {
            static let fontSize: CGFloat = 17
            static let topPadding: CGFloat = 49
            static let bottomPadding: CGFloat = 92
        }
        enum OpenButton {
            static let diameter: CGFloat = 60
            static let fontSize: CGFloat = 16
            static let trailing: CGFloat = 42
            static let bottom: CGFloat = 38
        }
        enum CloseButton {
            static let diameter: CGFloat = 38
            static let iconSize: CGFloat = 13
            static let backgroundOpacity: Double = 0.42
            static let top: CGFloat = 42
            static let trailing: CGFloat = 22
        }
        enum Portal {
            // Large enough to cover any device diagonal from the button corner.
            static let maxRadius: CGFloat = 1400
            static let openSpringResponse: Double = 0.72
            static let openSpringDamping: Double = 0.9
            static let closeDuration: Double = 0.55
            // Short pause so the 3 ripple rings fire before the iris expands.
            static let rippleDelay: Double = 0.07
            // Approximate spring settle time before showing the close button.
            static let openSettleDuration: Double = 1.1
        }
    }

    @State private var selectedSeatIDs: Set<Seat.ID> = []
    @State private var showThreeDPreview = false
    @State private var isCloseButtonVisible = false
    @State private var portalRadius: CGFloat = 0
    @State private var portalOrigin: CGPoint = .zero
    @State private var rippleTrigger = 0

    private let config = MovieConfig()

    // 0 = seat map fully visible  →  1 = portal fully open
    private var portalProgress: Double {
        Double(min(1, portalRadius / Config.Portal.maxRadius))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomTrailing) {
                Color.black.ignoresSafeArea()

                // PanoramaView lives behind everything, clipped to the growing portal circle.
                if showThreeDPreview {
                    PanoramaView(imageName: config.theatreImageName)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipShape(PortalShape(origin: portalOrigin, radius: portalRadius))
                }

                // Seat map fades out quickly as the portal opens.
                seatMap
                    .opacity(max(0, 1 - portalProgress * 2.2))
                    .allowsHitTesting(!showThreeDPreview)

                // Ripple rings burst outward from the tap point.
                RippleRingsView(origin: portalOrigin, trigger: rippleTrigger)

                // Aurora ring rides the leading edge of the portal circle.
                AuroraRingView(
                    origin: portalOrigin,
                    radius: portalRadius,
                    // sin curve: zero at start, peaks mid-open, zero when fully open.
                    opacity: min(1, sin(portalProgress * .pi) * 1.6)
                )

                if !showThreeDPreview {
                    previewButton
                        .transition(.opacity)
                }

                if isCloseButtonVisible {
                    closeButton
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .transition(.opacity.combined(with: .scale(scale: 0.7)))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .coordinateSpace(.named("portalRoot"))
        .preferredColorScheme(.dark)
    }

    // MARK: - Seat Map

    private var seatMap: some View {
        VStack(spacing: 0) {
            Text("Book your ticket")
                .font(.system(size: Config.Title.fontSize, weight: .regular))
                .foregroundStyle(.white)
                .padding(.top, Config.Title.topPadding)
                .padding(.bottom, Config.Title.bottomPadding)

            SeatMapView(selectedSeatIDs: $selectedSeatIDs, config: config)

            Spacer(minLength: 0)
        }
        .ignoresSafeArea(edges: .horizontal)
    }

    // MARK: - Buttons

    private var previewButton: some View {
        Button(action: openPreview) {
            ZStack {
                Circle()
                    .fill(config.previewButtonFillColor)
                    .frame(width: Config.OpenButton.diameter, height: Config.OpenButton.diameter)

                Text("3D")
                    .font(.system(size: Config.OpenButton.fontSize, weight: .regular))
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(.plain)
        .padding(.trailing, Config.OpenButton.trailing)
        .padding(.bottom, Config.OpenButton.bottom)
        .accessibilityLabel("Open 3D preview")
        // Capture this button's center in the full-screen "portalRoot" coordinate space.
        .background(
            GeometryReader { g in
                Color.clear.onAppear {
                    let frame = g.frame(in: .named("portalRoot"))
                    portalOrigin = CGPoint(x: frame.midX, y: frame.midY)
                }
            }
        )
    }

    private var closeButton: some View {
        Button(action: closePreview) {
            Image(systemName: "xmark")
                .font(.system(size: Config.CloseButton.iconSize, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: Config.CloseButton.diameter, height: Config.CloseButton.diameter)
                .background(.black.opacity(Config.CloseButton.backgroundOpacity), in: Circle())
        }
        .buttonStyle(.plain)
        .padding(.top, Config.CloseButton.top)
        .padding(.trailing, Config.CloseButton.trailing)
        .accessibilityLabel("Close theatre view")
    }

    // MARK: - Actions

    private func openPreview() {
        rippleTrigger += 1
        showThreeDPreview = true
        portalRadius = 0

        Task { @MainActor in
            // Let ripple rings start first, then expand the iris.
            try? await Task.sleep(nanoseconds: UInt64(Config.Portal.rippleDelay * 1_000_000_000))

            withAnimation(.spring(
                response: Config.Portal.openSpringResponse,
                dampingFraction: Config.Portal.openSpringDamping
            )) {
                portalRadius = Config.Portal.maxRadius
            }

            // Show close button once the spring has settled.
            try? await Task.sleep(nanoseconds: UInt64(Config.Portal.openSettleDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }

            withAnimation(.easeOut(duration: 0.2)) {
                isCloseButtonVisible = true
            }
        }
    }

    private func closePreview() {
        withAnimation(.easeIn(duration: 0.15)) {
            isCloseButtonVisible = false
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 80_000_000) // 0.08s — let button fade first

            withAnimation(.easeInOut(duration: Config.Portal.closeDuration)) {
                portalRadius = 0
            }

            try? await Task.sleep(nanoseconds: UInt64(Config.Portal.closeDuration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            showThreeDPreview = false
        }
    }
}

#Preview {
    MovieMainPage()
}
