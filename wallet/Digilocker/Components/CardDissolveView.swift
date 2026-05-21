//
//  CardDissolveView.swift
//  iosconcepts
//

import SwiftUI
import UIKit

// MARK: - SwiftUI wrapper

struct CardDissolveView: UIViewRepresentable {
    let imageName: String
    let onComplete: () -> Void

    func makeUIView(context: Context) -> DissolveView {
        DissolveView(imageName: imageName, onComplete: onComplete)
    }

    func updateUIView(_ uiView: DissolveView, context: Context) {}
}

// MARK: - UIKit particle view

final class DissolveView: UIView {

    private let imageName: String
    private let onComplete: () -> Void
    private var started = false

    init(imageName: String, onComplete: @escaping () -> Void) {
        self.imageName = imageName
        self.onComplete = onComplete
        super.init(frame: .zero)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, !started else { return }
        started = true
        begin()
    }

    private func begin() {
        showFadingCard()
        let emitter = buildEmitter()
        layer.addSublayer(emitter)

        // Short burst then stop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            emitter.birthRate = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            self.onComplete()
        }
    }

    // Card image fades out quickly so particles appear to be what remains
    private func showFadingCard() {
        guard let img = UIImage(named: imageName) else { return }
        let iv = UIImageView(image: img)
        iv.frame = bounds
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 12
        addSubview(iv)
        UIView.animate(withDuration: 0.3, delay: 0.02, options: .curveEaseIn) {
            iv.alpha = 0
        }
    }

    // MARK: - Emitter

    private func buildEmitter() -> CAEmitterLayer {
        let e = CAEmitterLayer()
        e.frame = bounds
        e.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        e.emitterShape    = .rectangle       // emit from the full card area
        e.emitterSize     = bounds.size
        e.renderMode      = .unordered
        e.emitterCells    = [fineDust(), coarseDust()]
        return e
    }

    // Thousands of 1-2pt white specks
    private func fineDust() -> CAEmitterCell {
        let c = CAEmitterCell()
        c.contents = circle(pointSize: 2).cgImage

        c.birthRate      = 18_000
        c.lifetime       = 1.9
        c.lifetimeRange  = 0.7

        c.velocity       = 220
        c.velocityRange  = 160
        c.emissionRange  = .pi * 2            // all directions

        c.xAcceleration  = 28                 // slight rightward drift (matches reference)
        c.yAcceleration  = 14

        c.scale          = 1.0
        c.scaleRange     = 0.5
        c.scaleSpeed     = -0.05

        c.alphaSpeed     = -0.45
        c.alphaRange     = 0.25

        c.spin           = 2.0
        c.spinRange      = 4.0

        c.color          = UIColor.white.cgColor
        c.blueRange      = 0.15               // subtle blue tint variation

        return c
    }

    // Fewer 3-5pt particles for depth
    private func coarseDust() -> CAEmitterCell {
        let c = CAEmitterCell()
        c.contents = circle(pointSize: 4).cgImage

        c.birthRate      = 4_000
        c.lifetime       = 1.5
        c.lifetimeRange  = 0.5

        c.velocity       = 170
        c.velocityRange  = 120
        c.emissionRange  = .pi * 2

        c.xAcceleration  = 22
        c.yAcceleration  = 10

        c.scale          = 1.0
        c.scaleRange     = 0.5
        c.scaleSpeed     = -0.08

        c.alphaSpeed     = -0.55
        c.alphaRange     = 0.2

        c.spin           = 1.5
        c.spinRange      = 3.0

        c.color          = UIColor.white.cgColor
        c.blueRange      = 0.2

        return c
    }

    // Draw a white circle at the given point size.
    // UIGraphicsImageRenderer respects screen scale, so the resulting
    // CGImage pixel dimensions are pointSize × screenScale.
    // CAEmitterLayer renders in screen pixels, so the rendered particle
    // is pointSize logical points on device.
    private func circle(pointSize: CGFloat) -> UIImage {
        let s = CGSize(width: pointSize, height: pointSize)
        return UIGraphicsImageRenderer(size: s).image { ctx in
            UIColor.white.setFill()
            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: s))
        }
    }
}
