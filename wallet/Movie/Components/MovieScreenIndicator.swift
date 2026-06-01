import SwiftUI

struct MovieScreenIndicator: View {
    private typealias Style = MovieHomeStyle

    @Binding var height: CGFloat
    let expandedHeight: CGFloat

    @State private var dragAnchor: CGFloat? = nil

    var body: some View {
        let collapsedHeight = Style.Layout.Screen.collapsedHeight
        let clampedHeight = min(expandedHeight, max(collapsedHeight, height))
        let progress = (clampedHeight - collapsedHeight) / max(1, expandedHeight - collapsedHeight)
        let visibleLabelHeight = Style.Layout.Screen.labelHeight * (1 - progress)
        let visibleGap = Style.Layout.Screen.gap * (1 - progress)

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
                .fill(Color.blue)
                .frame(maxWidth: .infinity)
                .frame(height: clampedHeight)
                .overlay {
                    Color.clear
                        .frame(height: max(clampedHeight, Style.Layout.Screen.touchTargetHeight))
                        .contentShape(Rectangle())
                        .gesture(dragGesture)
                        .onTapGesture { toggle() }
                }
        }
        .zIndex(100)
        .animation(
            .spring(response: Style.Layout.Screen.springResponse, dampingFraction: Style.Layout.Screen.springDamping),
            value: height
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
            height = target
        }
    }
}

#Preview {
    MovieScreenIndicator(
        height: .constant(MovieHomeStyle.Layout.Screen.collapsedHeight),
        expandedHeight: 400
    )
        .padding()
        .background(MovieHomeStyle.Palette.background)
}
