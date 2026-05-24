//
//  Header.swift
//  iosconcepts
//
//  Created by vignesh on 24/05/26.
//

import SwiftUI
import UIKit

struct TopHeader: View {
    var body: some View {
        HStack {
            profileButton
            Spacer()
            cameraButton
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var profileButton: some View {
        Group {
            if let uiImage = UIImage(named: "Profile") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(Color(red: 221/255, green: 221/255, blue: 221/255), lineWidth: 0.833)
        )
    }

    private var cameraButton: some View {
        CameraAddIcon()
            .stroke(style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .foregroundStyle(Color(red: 0.063, green: 0.063, blue: 0.063))
            .frame(width: 28, height: 28)
            .frame(width: 40, height: 40)
    }
}

private struct CameraAddIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scale = min(rect.width, rect.height) / 24

        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * scale, y: rect.minY + y * scale)
        }

        // Camera body
        path.move(to: p(22, 9))
        path.addLine(to: p(22, 15))
        path.addCurve(to: p(21.1215, 20.1213),
                      control1: p(22, 17.8284),
                      control2: p(22, 19.2426))
        path.addCurve(to: p(16, 21),
                      control1: p(20.2428, 21),
                      control2: p(18.8286, 21))
        path.addLine(to: p(8, 21))
        path.addCurve(to: p(2.87886, 20.1213),
                      control1: p(5.17176, 21),
                      control2: p(3.75754, 21))
        path.addCurve(to: p(2, 15),
                      control1: p(2, 19.2426),
                      control2: p(2, 17.8284))
        path.addLine(to: p(2, 11.0537))
        path.addCurve(to: p(2.1136, 9.18288),
                      control1: p(2, 10.0736),
                      control2: p(2, 9.58356))
        path.addCurve(to: p(4.18307, 7.11341),
                      control1: p(2.39734, 8.18054),
                      control2: p(3.18074, 7.39714))
        path.addCurve(to: p(6.05387, 7),
                      control1: p(4.58376, 7),
                      control2: p(5.07379, 7))
        path.addCurve(to: p(6.77329, 6.97027),
                      control1: p(6.41985, 7),
                      control2: p(6.60284, 7))
        path.addCurve(to: p(7.87867, 6.37869),
                      control1: p(7.19563, 6.89665),
                      control2: p(7.58313, 6.68926))
        path.addCurve(to: p(8.50018, 5.49998),
                      control1: p(7.99794, 6.25335),
                      control2: p(8.29718, 5.8045))
        path.addCurve(to: p(9.36568, 4.40365),
                      control1: p(8.89656, 4.90543),
                      control2: p(9.09474, 4.60815))
        path.addCurve(to: p(9.91067, 4.11198),
                      control1: p(9.53113, 4.27877),
                      control2: p(9.71499, 4.18038))
        path.addCurve(to: p(11.303, 4),
                      control1: p(10.2311, 4),
                      control2: p(10.5884, 4))
        path.addLine(to: p(13, 4))

        // Lens
        let lensCenter = p(12, 13.5)
        let lensRadius = 4 * scale
        path.move(to: CGPoint(x: lensCenter.x + lensRadius, y: lensCenter.y))
        path.addArc(center: lensCenter,
                    radius: lensRadius,
                    startAngle: .zero,
                    endAngle: .degrees(360),
                    clockwise: false)

        // Plus
        path.move(to: p(16, 5.5))
        path.addLine(to: p(21, 5.5))
        path.move(to: p(18.5, 8))
        path.addLine(to: p(18.5, 3))

        return path
    }
}

#Preview {
    VStack {
        TopHeader()
        Spacer()
    }
    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
}
