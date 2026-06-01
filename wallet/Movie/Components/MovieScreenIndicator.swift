import SwiftUI

struct MovieScreenIndicator: View {
    private typealias Style = MovieHomeStyle

    private let collapsedHeight: CGFloat = 1
    private let touchTargetHeight: CGFloat = 88
    private let expandThreshold: CGFloat = 0.2
    private let collapseThreshold: CGFloat = 0.5
    private let flickVelocity: CGFloat = 400

    @Binding var height: CGFloat
    let expandedHeight: CGFloat

    @State private var dragAnchor: CGFloat? = nil

    var body: some View {
        let clampedHeight = min(expandedHeight, max(collapsedHeight, height))
        let progress = (clampedHeight - collapsedHeight) / max(1, expandedHeight - collapsedHeight)

        VStack(spacing: Style.Layout.Screen.gap) {
            Text("SCREEN THIS WAY")
                .font(.geist(Style.Typography.screenLabel))
                .tracking(Style.Layout.Screen.tracking)
                .foregroundStyle(.white.opacity(0.78))
                .opacity(1 - progress)
                .allowsHitTesting(false)

            Rectangle()
                .fill(Color.blue)
                .frame(maxWidth: .infinity)
                .frame(height: clampedHeight)
                .overlay {
                    Color.clear
                        .frame(height: max(clampedHeight, touchTargetHeight))
                        .contentShape(Rectangle())
                        .gesture(dragGesture)
                        .onTapGesture { toggle() }
                }
        }
        .zIndex(100)
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: height)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
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
                let velocity = value.predictedEndTranslation.height - value.translation.height
                let progress = (height - collapsedHeight) / max(1, expandedHeight - collapsedHeight)
                let wasExpanded = (dragAnchor ?? collapsedHeight) > expandedHeight * 0.5

                let shouldExpand: Bool
                if wasExpanded {
                    shouldExpand = !(progress < collapseThreshold || velocity > flickVelocity)
                } else {
                    shouldExpand = progress > expandThreshold || velocity < -flickVelocity
                }

                dragAnchor = nil
                withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                    height = shouldExpand ? expandedHeight : collapsedHeight
                }
            }
    }

    private func toggle() {
        let target: CGFloat = height > expandedHeight * 0.5 ? collapsedHeight : expandedHeight
        withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
            height = target
        }
    }
}

#Preview {
    MovieScreenIndicator(height: .constant(1), expandedHeight: 800)
        .padding()
        .background(MovieHomeStyle.Palette.background)
}
