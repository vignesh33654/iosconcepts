import SwiftUI

struct MovieMainPage: View {
    @State private var selectedSeatIDs: Set<String> = []
    @State private var showThreeDPreview = false
    private let config = MovieConfig()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Text("Book your ticket")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.white)
                    .padding(.top, 49)
                    .padding(.bottom, 92)

                SeatMapView(selectedSeatIDs: $selectedSeatIDs, config: config)

                Spacer(minLength: 0)
            }
            .ignoresSafeArea(edges: .horizontal)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showThreeDPreview = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(config.previewButtonFillColor)
                        .frame(width: 60, height: 60)

                    Text("3D")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .padding(.trailing, 42)
            .padding(.bottom, 38)
            .accessibilityLabel("Open 3D preview")

            if showThreeDPreview {
                previewOverlay
            }
        }
        .preferredColorScheme(.dark)
    }

    private var previewOverlay: some View {
        ZStack {
            Color.black.opacity(0.88)
                .ignoresSafeArea()
                .onTapGesture { showThreeDPreview = false }

            VStack(spacing: 18) {
                HStack(spacing: 18) {
                    ForEach(Array(selectedSeatIDs.prefix(2)), id: \.self) { _ in
                        MovieHeroSeat(config: config)
                    }
                }
                .frame(height: 120)

                Button("Done") {
                    showThreeDPreview = false
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .padding(.vertical, 10)
                .padding(.horizontal, 28)
                .background(Color.white.opacity(0.14), in: Capsule())
                .buttonStyle(.plain)
            }
        }
        .transition(.opacity)
    }
}

private struct MovieHeroSeat: View {
    let config: MovieConfig

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(config.selectedSeatFillColor)
            .frame(width: 72, height: 92)
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.white.opacity(0.35), lineWidth: 1)
            }
            .shadow(color: config.selectedSeatFillColor.opacity(0.55), radius: 28)
    }
}

#Preview {
    MovieMainPage()
}
