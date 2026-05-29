import SwiftUI

struct MovieMainPage: View {
    // MARK: - Config

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

        enum Flash {
            static let color = Color(red: 1.0, green: 0.96, blue: 0.9)
            static let peak: Double = 0.9
        }

        // How the seat map is pulled into the screen. Drop `blur` to 0 if any lag.
        enum SeatMap {
            static let zoom: CGFloat = 1.6
            static let blur: CGFloat = 6
        }

        enum Timing {
            static let revealIn: Double = 0.2
            static let warpIn: Double = 0.8
            static let warpOut: Double = 0.6
            static let revealOut: Double = 0.4
            static let revealOutDelay: Double = 0.15
        }
    }

    // MARK: - State

    @State private var selectedSeatIDs: Set<String> = []
    @State private var showThreeDPreview = false
    @State private var warpProgress: CGFloat = 0
    private let config = MovieConfig()

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black
                .ignoresSafeArea()

            if showThreeDPreview {
                PanoramaView(imageName: config.theatreImageName)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            seatMap
                .scaleEffect(1 + warpProgress * Config.SeatMap.zoom)
                .blur(radius: warpProgress * Config.SeatMap.blur)
                .opacity(Double(1 - warpProgress))
                .allowsHitTesting(!showThreeDPreview)

            // Light burst that bridges the two scenes and hides the cut.
            Config.Flash.color
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)

            if !showThreeDPreview {
                previewButton
                    .transition(.opacity)
            }

            if showThreeDPreview {
                closeButton
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
    }

    // 0 at rest, peaks mid-transition, back to 0 — a tent driven by warpProgress.
    private var flashOpacity: Double {
        let p = max(0, min(1, Double(warpProgress)))
        return sin(p * .pi) * Config.Flash.peak
    }

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

    private func openPreview() {
        // Panorama snaps in behind; the seat map is sucked into the screen while a light burst masks the hand-off.
        withAnimation(.easeOut(duration: Config.Timing.revealIn)) {
            showThreeDPreview = true
        }
        withAnimation(.easeIn(duration: Config.Timing.warpIn)) {
            warpProgress = 1
        }
    }

    private func closePreview() {
        withAnimation(.easeOut(duration: Config.Timing.warpOut)) {
            warpProgress = 0
        }
        withAnimation(.easeInOut(duration: Config.Timing.revealOut).delay(Config.Timing.revealOutDelay)) {
            showThreeDPreview = false
        }
    }
}

#Preview {
    MovieMainPage()
}
