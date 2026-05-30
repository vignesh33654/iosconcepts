import SwiftUI

struct ScreenArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.minX, y: rect.minY)
        let end = CGPoint(x: rect.maxX, y: rect.minY)
        let control = CGPoint(
            x: rect.midX,
            y: rect.maxY + rect.height * MovieHomeStyle.Layout.screenArcControlDepth
        )

        path.move(to: start)
        path.addQuadCurve(to: end, control: control)
        return path
    }
}
