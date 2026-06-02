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

    var body: some View {
        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        let maximumHeight = fullHeight
        let clampedHeight = min(maximumHeight, max(collapsedHeight, height))
        let labelVisibility: CGFloat = clampedHeight >= fullHeight - 1 ? 0 : 1
        let visibleLabelHeight = Style.Layout.Screen.labelHeight * labelVisibility
        let visibleGap = Style.Layout.Screen.gap * labelVisibility

        VStack(spacing: visibleGap) {
            animatedLabel
                .opacity(labelVisibility)
                .frame(height: visibleLabelHeight)
                .clipped()
                .allowsHitTesting(false)
                .animation(.easeInOut(duration: Style.Layout.Screen.labelTransitionDuration), value: isFullView)

            screenContent(height: clampedHeight)
                .overlay(alignment: .topTrailing) {
                    if isFullView {
                        closeButton
                            .padding(.top, Style.Layout.Screen.fullViewTop)
                            .padding(.trailing, Style.Layout.Screen.fullViewTrailing)
                            .transition(.opacity)
                    }
                }
                .overlay {
                    if !isFullView {
                        Color.clear
                            .frame(height: max(clampedHeight, Style.Layout.Screen.touchTargetHeight))
                            .contentShape(Rectangle())
                            .gesture(dragGesture)
                            .onTapGesture { toggle() }
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    }
                }
        }
        .zIndex(100)
        .onChange(of: shouldRevealPreview, initial: true) { _, shouldReveal in
            guard shouldReveal else { return }
            Task {
                await revealPreviewIfNeeded()
            }
        }
    }

    private var closeButton: some View {
        Button {
            collapse()
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: Style.Layout.Screen.fullViewIcon, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: Style.Layout.Screen.fullViewButton, height: Style.Layout.Screen.fullViewButton)
                .background(.black.opacity(Style.Layout.Screen.fullViewBackgroundOpacity), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(.white.opacity(0.18), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Close theatre view")
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
        labelText
            .foregroundStyle(.white.opacity(0.58))
    }

    private var labelText: some View {
        Text("SWIPE UP FOR SEAT VIEW")
            .font(.geist(Style.Typography.screenLabel))
            .tracking(Style.Layout.Screen.tracking)
    }

    @MainActor
    private func revealPreviewIfNeeded() async {
        guard !didRevealPreview else { return }
        didRevealPreview = true

        try? await Task.sleep(nanoseconds: UInt64(Style.Layout.Screen.previewDelay * 1_000_000_000))
        guard !Task.isCancelled, !isFullView else { return }

        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        guard height <= collapsedHeight else { return }

        withAnimation(.easeInOut(duration: Style.Layout.Screen.previewAnimationDuration)) {
            height = min(expandedHeight, Style.Layout.Screen.previewHeight)
        }
    }

    private func screenContent(height: CGFloat) -> some View {
        GeometryReader { geometry in
            let visibleHeight = max(height, Style.Layout.Screen.collapsedHeight)
            let previewProgress = min(1, max(0, visibleHeight / max(1, Style.Layout.Screen.previewHeight)))
            let lineVisibility = max(0, 1 - previewProgress * 3)
            let scale = Style.Layout.Screen.previewCollapsedScale
                + (Style.Layout.Screen.previewExpandedScale - Style.Layout.Screen.previewCollapsedScale) * previewProgress
            let imageHeight = max(fullHeight, geometry.size.width * 0.7) * scale
            let focalY = imageHeight * Style.Layout.Screen.previewFocalY
            let cropCenterY = visibleHeight * 0.5
            let verticalOffset = cropCenterY - focalY

            ZStack(alignment: .top) {
                PanoramaView(imageName: Style.Asset.theatre)
                    .allowsHitTesting(false)
                    .frame(width: geometry.size.width, height: imageHeight)
                    .offset(y: verticalOffset)

                Rectangle()
                    .fill(Style.Palette.screenCenter)
                    .opacity(lineVisibility)
                    .frame(height: Style.Layout.Screen.collapsedHeight)
            }
            .frame(width: geometry.size.width, height: visibleHeight, alignment: .top)
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
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
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    height = min(fullHeight, max(collapsedHeight, anchor - value.translation.height))
                }
            }
            .onEnded { value in
                dragAnchor = nil

                if value.translation.height > 0 {
                    collapse()
                } else {
                    openFullView()
                }
            }
    }

    private func toggle() {
        openFullView()
    }

    private func openFullView() {
        withAnimation(.spring(response: Style.Layout.Screen.closeResponse, dampingFraction: Style.Layout.Screen.closeDamping)) {
            isFullView = true
            height = fullHeight
        }
    }

    private func collapse() {
        withAnimation(.spring(response: Style.Layout.Screen.closeResponse, dampingFraction: Style.Layout.Screen.closeDamping)) {
            isFullView = false
            height = Style.Layout.Screen.collapsedHeight
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
