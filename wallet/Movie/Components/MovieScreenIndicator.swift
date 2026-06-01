import SwiftUI

struct MovieScreenIndicator: View {
    private typealias Style = MovieHomeStyle

    @Binding var height: CGFloat
    let expandedHeight: CGFloat
    let fullHeight: CGFloat
    @Binding var isFullView: Bool

    @State private var dragAnchor: CGFloat? = nil

    var body: some View {
        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        let maximumHeight = isFullView ? fullHeight : expandedHeight
        let clampedHeight = min(maximumHeight, max(collapsedHeight, height))
        let rawProgress = (clampedHeight - collapsedHeight) / max(1, expandedHeight - collapsedHeight)
        let progress = min(1, max(0, rawProgress))
        let visibleLabelHeight = Style.Layout.Screen.labelHeight * (1 - progress)
        let visibleGap = Style.Layout.Screen.gap * (1 - progress)
        let showsFullViewButton = isFullView || progress > Style.Layout.Screen.fullViewButtonVisibilityThreshold

        VStack(spacing: visibleGap) {
            Text("SCREEN THIS WAY")
                .font(.geist(Style.Typography.screenLabel))
                .tracking(Style.Layout.Screen.tracking)
                .foregroundStyle(.white.opacity(0.78))
                .opacity(1 - progress)
                .frame(height: visibleLabelHeight)
                .clipped()
                .allowsHitTesting(false)

            Rectangle()
                .fill(screenFill)
                .frame(maxWidth: .infinity)
                .frame(height: clampedHeight)
                .overlay {
                    ZStack(alignment: .topTrailing) {
                        Color.clear
                            .frame(height: max(clampedHeight, Style.Layout.Screen.touchTargetHeight))
                            .contentShape(Rectangle())
                            .gesture(dragGesture)
                            .onTapGesture { toggle() }

                        if showsFullViewButton {
                            Button(action: toggleFullView) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
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
                }
        }
        .zIndex(100)
        .animation(
            .spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping),
            value: height
        )
    }

    private var screenFill: some ShapeStyle {
        RadialGradient(
            colors: [
                Style.Palette.screenCenter,
                Style.Palette.screenCenter.opacity(0.82),
                Style.Palette.screenEdge
            ],
            center: .center,
            startRadius: Style.Layout.Screen.gradientStartRadius,
            endRadius: Style.Layout.Screen.gradientEndRadius
        )
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                let collapsedHeight = Style.Layout.Screen.collapsedHeight
                let anchor: CGFloat
                if let existing = dragAnchor {
                    anchor = existing
                } else {
                    anchor = min(expandedHeight, max(collapsedHeight, height))
                    dragAnchor = anchor
                }
                height = min(expandedHeight, max(collapsedHeight, anchor - value.translation.height))
            }
            .onEnded { value in
                let collapsedHeight = Style.Layout.Screen.collapsedHeight
                let velocity = value.predictedEndTranslation.height - value.translation.height
                let progress = (height - collapsedHeight) / max(1, expandedHeight - collapsedHeight)
                let wasExpanded = (dragAnchor ?? collapsedHeight) > expandedHeight * Style.Layout.Screen.collapseThreshold

                let shouldExpand: Bool
                if wasExpanded {
                    shouldExpand = !(progress < Style.Layout.Screen.collapseThreshold || velocity > Style.Layout.Screen.flickVelocity)
                } else {
                    shouldExpand = progress > Style.Layout.Screen.expandThreshold || velocity < -Style.Layout.Screen.flickVelocity
                }

                dragAnchor = nil
                withAnimation(.spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping)) {
                    height = shouldExpand ? expandedHeight : collapsedHeight
                }
            }
    }

    private func toggle() {
        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        let target: CGFloat = height > expandedHeight * Style.Layout.Screen.collapseThreshold ? collapsedHeight : expandedHeight
        withAnimation(.spring(response: Style.Layout.Screen.toggleSpringResponse, dampingFraction: Style.Layout.Screen.springDamping)) {
            isFullView = false
            height = target
        }
    }

    private func toggleFullView() {
        if isFullView {
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                isFullView = false
                height = Style.Layout.Screen.collapsedHeight
            }
            return
        }

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
        isFullView: .constant(false)
    )
        .padding()
        .background(MovieHomeStyle.Palette.background)
}
