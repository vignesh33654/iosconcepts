import SwiftUI

struct MovieScreenIndicator: View {
    private typealias Style = MovieHomeStyle

    @Binding var height: CGFloat
    let expandedHeight: CGFloat
    let fullHeight: CGFloat
    let shouldRevealPreview: Bool
    @Binding var isFullView: Bool

    @State private var dragAnchor: CGFloat? = nil
    @State private var didRevealPreview = false
    @State private var textShaderProgress: CGFloat = 0

    var body: some View {
        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        let maximumHeight = fullHeight
        let clampedHeight = min(maximumHeight, max(collapsedHeight, height))
        let rawProgress = (clampedHeight - collapsedHeight) / max(1, expandedHeight - collapsedHeight)
        let progress = min(1, max(0, rawProgress))
        let visibleLabelHeight = Style.Layout.Screen.labelHeight * (1 - progress)
        let visibleGap = Style.Layout.Screen.gap * (1 - progress)
        let showsFullViewButton = isFullView

        VStack(spacing: visibleGap) {
            animatedLabel
                .opacity(1 - progress)
                .frame(height: visibleLabelHeight)
                .clipped()
                .allowsHitTesting(false)

            screenContent(height: clampedHeight, progress: progress, isInteractive: isFullView)
                .overlay {
                    ZStack(alignment: .topTrailing) {
                        if !isFullView {
                            Color.clear
                                .frame(height: max(clampedHeight, Style.Layout.Screen.touchTargetHeight))
                                .contentShape(Rectangle())
                                .gesture(dragGesture)
                                .onTapGesture { toggle() }
                        }

                        if showsFullViewButton {
                            Button(action: toggleFullView) {
                                Image(systemName: "xmark")
                                    .font(.system(size: Style.Layout.Screen.fullViewIcon, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(
                                        width: Style.Layout.Screen.fullViewButton,
                                        height: Style.Layout.Screen.fullViewButton
                                    )
                                    .background(.black.opacity(Style.Layout.Screen.fullViewBackgroundOpacity), in: Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.top, Style.Layout.Screen.fullViewTop)
                            .padding(.trailing, Style.Layout.Screen.fullViewTrailing)
                            .transition(.opacity)
                            .accessibilityLabel(isFullView ? "Close full screen" : "Open full screen")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
        }
        .zIndex(100)
        .animation(
            .spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping),
            value: height
        )
        .onChange(of: shouldRevealPreview, initial: true) { _, shouldReveal in
            guard shouldReveal else { return }
            Task {
                await revealPreviewIfNeeded()
            }
        }
    }

    private var animatedLabel: some View {
        ZStack {
            Text("SCREEN THIS WAY")
                .font(.geist(Style.Typography.screenLabel))
                .tracking(Style.Layout.Screen.tracking)
                .foregroundStyle(.white.opacity(0.78))
                .opacity(didRevealPreview ? 0 : 1)

            shaderLabel
                .opacity(didRevealPreview ? 1 : 0)
        }
        .animation(.easeInOut(duration: Style.Layout.Screen.labelTransitionDuration), value: didRevealPreview)
    }

    private var shaderLabel: some View {
        ZStack {
            labelText
                .foregroundStyle(.white.opacity(0.46))

            GeometryReader { geometry in
                LinearGradient(
                    colors: [
                        .white.opacity(0.18),
                        Style.Palette.screenCenter.opacity(0.9),
                        .white,
                        Style.Palette.screenCenter.opacity(0.85),
                        .white.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width * Style.Layout.Screen.textShaderWidthRatio)
                .offset(x: -geometry.size.width * (Style.Layout.Screen.textShaderWidthRatio - 1) * (1 - textShaderProgress))
                .mask {
                    labelText
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }

    private var labelText: some View {
        Text("EXPERIENCE YOUR SEAT VIEW")
            .font(.geist(Style.Typography.screenLabel))
            .tracking(Style.Layout.Screen.tracking)
    }

    @MainActor
    private func revealPreviewIfNeeded() async {
        guard !didRevealPreview else { return }
        didRevealPreview = true

        guard !Task.isCancelled, !isFullView else { return }

        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        guard height <= collapsedHeight else { return }

        withAnimation(.easeInOut(duration: Style.Layout.Screen.previewAnimationDuration)) {
            height = min(expandedHeight, Style.Layout.Screen.previewHeight)
        }

        try? await Task.sleep(nanoseconds: UInt64(Style.Layout.Screen.previewAnimationDuration * 1_000_000_000))
        guard !Task.isCancelled, !isFullView else { return }

        textShaderProgress = 0
        withAnimation(.easeInOut(duration: Style.Layout.Screen.textShaderDuration)) {
            textShaderProgress = 1
        }
    }

    @ViewBuilder
    private func screenContent(height: CGFloat, progress: CGFloat, isInteractive: Bool) -> some View {
        if progress == 0 {
            Rectangle()
                .fill(Style.Palette.screenCenter)
                .frame(maxWidth: .infinity)
                .frame(height: height)
        } else {
            PanoramaView(imageName: Style.Asset.theatre)
                .allowsHitTesting(isInteractive)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .clipped()
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                let collapsedHeight = Style.Layout.Screen.collapsedHeight
                let anchor: CGFloat
                if let existing = dragAnchor {
                    anchor = existing
                } else {
                    anchor = min(fullHeight, max(collapsedHeight, height))
                    dragAnchor = anchor
                }
                height = min(fullHeight, max(collapsedHeight, anchor - value.translation.height))
            }
            .onEnded { _ in
                dragAnchor = nil
                openFullView()
            }
    }

    private func toggle() {
        openFullView()
    }

    private func toggleFullView() {
        if isFullView {
            withAnimation(.spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping)) {
                isFullView = false
                height = Style.Layout.Screen.collapsedHeight
            }
            return
        }

        openFullView()
    }

    private func openFullView() {
        withAnimation(.spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping)) {
            isFullView = true
            height = fullHeight
        }
    }
}

#Preview {
    MovieScreenIndicator(
        height: .constant(MovieHomeStyle.Layout.Screen.collapsedHeight),
        expandedHeight: 400,
        fullHeight: 800,
        shouldRevealPreview: false,
        isFullView: .constant(false)
    )
        .padding()
        .background(MovieHomeStyle.Palette.background)
}
