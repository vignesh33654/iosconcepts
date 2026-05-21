//
//  CardDissolveView.swift
//  iosconcepts
//

import SwiftUI
import UIKit

struct CardDissolveView: View {

    private let cols = 10
    private let rows = 6

    private let pieces: [[UIImage]]
    private let targets: [Target]

    let onComplete: () -> Void

    @State private var launched = false

    private struct Target {
        let dx: CGFloat
        let dy: CGFloat
        let rotation: Double
        let delay: Double
        let duration: Double
    }

    init(imageName: String, onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
        let image = UIImage(named: imageName) ?? UIImage()
        self.pieces = Self.crop(image, cols: 10, rows: 6)
        self.targets = (0..<60).map { _ in
            let angle = Double.random(in: 0 ..< (2 * .pi))
            let dist  = CGFloat.random(in: 55...170)
            return Target(
                dx:       cos(angle) * dist,
                dy:       sin(angle) * dist,
                rotation: Double.random(in: -260...260),
                delay:    Double.random(in: 0...0.25),
                duration: Double.random(in: 0.38...0.60)
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            let pw = geo.size.width  / CGFloat(cols)
            let ph = geo.size.height / CGFloat(rows)

            ZStack(alignment: .topLeading) {
                ForEach(0..<(rows * cols), id: \.self) { i in
                    piece(i: i, pw: pw, ph: ph)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 32_000_000) // 2 frames — let pieces render first
                launched = true
                try? await Task.sleep(nanoseconds: 1_100_000_000)
                onComplete()
            }
        }
    }

    @ViewBuilder
    private func piece(i: Int, pw: CGFloat, ph: CGFloat) -> some View {
        let row = i / cols
        let col = i % cols
        if row < pieces.count, col < pieces[row].count {
            let t = targets[i]
            Image(uiImage: pieces[row][col])
                .resizable()
                .frame(width: pw + 0.5, height: ph + 0.5) // +0.5 hides seams between pieces
                .position(
                    x: CGFloat(col) * pw + pw / 2 + (launched ? t.dx : 0),
                    y: CGFloat(row) * ph + ph / 2 + (launched ? t.dy : 0)
                )
                .rotationEffect(.degrees(launched ? t.rotation : 0))
                .opacity(launched ? 0 : 1)
                .animation(
                    .easeOut(duration: t.duration).delay(t.delay),
                    value: launched
                )
        }
    }

    // Split the UIImage into a cols×rows grid of cropped UIImages.
    // CGImage coords are always in pixels so we divide evenly without scale fudging.
    private static func crop(_ image: UIImage, cols: Int, rows: Int) -> [[UIImage]] {
        guard let cg = image.cgImage else { return [] }
        let W  = CGFloat(cg.width)
        let H  = CGFloat(cg.height)
        let tw = W / CGFloat(cols)
        let th = H / CGFloat(rows)
        return (0..<rows).map { r in
            (0..<cols).compactMap { c in
                let rect = CGRect(x: CGFloat(c) * tw, y: CGFloat(r) * th, width: tw, height: th)
                return cg.cropping(to: rect).map {
                    UIImage(cgImage: $0, scale: image.scale, orientation: .up)
                }
            }
        }
    }
}
