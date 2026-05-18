//
//  Wallet.swift
//  iosconcepts
//
//  Created by vignesh on 16/05/26.
//

import SwiftUI
import UIKit

struct WalletMotion {
    var springResponse: Double = 0.45
    var springDamping: Double = 0.69
    var expandDelayStep: Double = 0.08
    var collapseDelayStep: Double = 0.07
    var lift: [CGFloat] = [-59, -28, 11]
    var rest: [CGFloat] = [9, 10, 23]
    var rotation: [Double] = [-1.4, 0.8, -0.4]
    var scale: [CGFloat] = [1.025, 1.022, 1.012]
    var widths: [CGFloat] = [0.86, 0.88, 0.9]
    var punchScale: CGFloat = 0.86
}

struct Wallet: View {
    let width: CGFloat
    var cardImageName: String = "Arav front"
    var backCardImageName: String = "Arav back"
    var isExpanded: Bool = false
    var motion: WalletMotion = .init()


    @State private var displayScales: [CGFloat] = [1, 1, 1]

    var body: some View {
        ZStack(alignment: .top) {
            bundledImage(named: "Background")
                .frame(width: width)
                .offset(y: -6)

            cardStack

            bundledImage(named: "Pocket 2")
                .frame(width: width + 2)
                .shadow(color: .black.opacity(0.4), radius: 4, x: 0, y: -8)
                .offset(y: 44)
                .zIndex(10)
        }
        .shadow(color: .black.opacity(0), radius: 28, x: 0, y: 0)
        .padding(.bottom, 16)
        .task(id: isExpanded) {
            if isExpanded {
                withAnimation(.none) {
                    displayScales = Array(repeating: motion.punchScale, count: 3)
                }
                try? await Task.sleep(nanoseconds: 80_000_000)
                guard !Task.isCancelled else { return }
                withAnimation(.spring(response: motion.springResponse, dampingFraction: motion.springDamping)) {
                    displayScales = motion.scale.map { $0 }
                }
            } else {
                withAnimation(.spring(response: motion.springResponse, dampingFraction: motion.springDamping)) {
                    displayScales = [1, 1, 1]
                }
            }
        }
    }

    private var cardStack: some View {
        ZStack(alignment: .top) {
            walletCard(index: 0, imageName: cardImageName)
            walletCard(index: 1, imageName: "Nandhi front")
            walletCard(index: 2, imageName: cardImageName)
        }
    }

    private func walletCard(index: Int, imageName: String) -> some View {
        Card(
            width: width * motion.widths[index],
            centerX: 0,
            expandedY: 0,
            collapsedY: 0,
            isExpanded: true,
            frontImageName: imageName,
            backImageName: backCardImageName,
            onTap: {},
            isPositioned: false,
            isInteractive: false,
            shadowOpacity: 0.2,
            shadowRadius: 12,
            shadowX: -2,
            shadowY: 3
        )
        .offset(y: isExpanded ? motion.lift[index] : motion.rest[index])
        .scaleEffect(displayScales[index])
        .rotationEffect(.degrees(isExpanded ? motion.rotation[index] : 0))
        .zIndex(Double(index + 1))
        .animation(cardAnimation(index: index), value: isExpanded)
    }

    private func cardAnimation(index: Int) -> Animation {
        let delay = isExpanded
            ? Double(index) * motion.expandDelayStep
            : Double(2 - index) * motion.collapseDelayStep

        return .spring(
            response: motion.springResponse,
            dampingFraction: motion.springDamping,
            blendDuration: 0.08
        )
        .delay(delay)
    }

    @ViewBuilder
    private func bundledImage(named name: String) -> some View {
        if let image = UIImage(named: name) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    @Previewable @State var m = WalletMotion()
    @Previewable @State var expanded = false
    GeometryReader { geo in
        VStack(spacing: 0) {
            // ── top 50 %: wallet live preview ──────────────────────────
            ZStack {
                Wallet(width: min(geo.size.width - 48, 340), isExpanded: expanded, motion: m)
                    .contentShape(Rectangle())
                    .onTapGesture { expanded.toggle() }
            }
            .frame(height: geo.size.height * 0.5)
            .frame(maxWidth: .infinity)

            Text("Tap wallet to open / close")
                .font(.caption2).foregroundStyle(.tertiary)
                .padding(.bottom, 4)

            Divider()

            // ── print bar ──────────────────────────────────────────────
            Button {
                print(motionSummary(m))
            } label: {
                Label("Print values to Xcode console", systemImage: "terminal")
                    .font(.subheadline.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.08))
                    .foregroundStyle(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)

            Divider()

            // ── bottom 50 %: scrollable controls ───────────────────────
            ScrollView(showsIndicators: true) {
            VStack(alignment: .leading, spacing: 16) {

                ctrlHeader("Animation feel")
                ctrlRow("How fast it opens & closes", val: String(format: "%.2f", m.springResponse)) { Slider(value: $m.springResponse, in: 0.1...2.0) }
                ctrlRow("How much it bounces", val: String(format: "%.2f", m.springDamping)) { Slider(value: $m.springDamping, in: 0.1...1.0) }
                ctrlRow("Delay between cards opening", val: String(format: "%.2f", m.expandDelayStep)) { Slider(value: $m.expandDelayStep, in: 0...0.3) }
                ctrlRow("Delay between cards closing", val: String(format: "%.2f", m.collapseDelayStep)) { Slider(value: $m.collapseDelayStep, in: 0...0.3) }
                ctrlRow("Squeeze before pop (1.0 = off)", val: String(format: "%.2f", m.punchScale)) { Slider(value: $m.punchScale, in: 0.7...1.0) }

                Divider()
                ctrlHeader("How high each card floats when open  (− = higher)")
                ctrlRow("Card 0", val: "\(Int(m.lift[0]))") { Slider(value: $m.lift[0], in: -200...100) }
                ctrlRow("Card 1", val: "\(Int(m.lift[1]))") { Slider(value: $m.lift[1], in: -200...100) }
                ctrlRow("Card 2", val: "\(Int(m.lift[2]))") { Slider(value: $m.lift[2], in: -200...100) }

                Divider()
                ctrlHeader("How far apart cards are when closed")
                ctrlRow("Card 0", val: "\(Int(m.rest[0]))") { Slider(value: $m.rest[0], in: -50...50) }
                ctrlRow("Card 1", val: "\(Int(m.rest[1]))") { Slider(value: $m.rest[1], in: -50...50) }
                ctrlRow("Card 2", val: "\(Int(m.rest[2]))") { Slider(value: $m.rest[2], in: -50...50) }

                Divider()
                ctrlHeader("How much each card tilts when open")
                ctrlRow("Card 0", val: String(format: "%.1f°", m.rotation[0])) { Slider(value: $m.rotation[0], in: -15...15) }
                ctrlRow("Card 1", val: String(format: "%.1f°", m.rotation[1])) { Slider(value: $m.rotation[1], in: -15...15) }
                ctrlRow("Card 2", val: String(format: "%.1f°", m.rotation[2])) { Slider(value: $m.rotation[2], in: -15...15) }

                Divider()
                ctrlHeader("How big each card grows when open")
                ctrlRow("Card 0", val: String(format: "%.3f", m.scale[0])) { Slider(value: $m.scale[0], in: 0.9...1.2) }
                ctrlRow("Card 1", val: String(format: "%.3f", m.scale[1])) { Slider(value: $m.scale[1], in: 0.9...1.2) }
                ctrlRow("Card 2", val: String(format: "%.3f", m.scale[2])) { Slider(value: $m.scale[2], in: 0.9...1.2) }

                Divider()
                ctrlHeader("Width of each card (% of wallet)")
                ctrlRow("Card 0", val: "\(Int(m.widths[0] * 100))%") { Slider(value: $m.widths[0], in: 0.6...1.0) }
                ctrlRow("Card 1", val: "\(Int(m.widths[1] * 100))%") { Slider(value: $m.widths[1], in: 0.6...1.0) }
                ctrlRow("Card 2", val: "\(Int(m.widths[2] * 100))%") { Slider(value: $m.widths[2], in: 0.6...1.0) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .frame(height: geo.size.height * 0.5)
        }
    }
}

private func ctrlHeader(_ title: String) -> some View {
    Text(title)
        .font(.headline)
        .foregroundStyle(.primary)
        .padding(.top, 10)
}

private func ctrlRow<S: View>(_ label: String, val: String, @ViewBuilder slider: () -> S) -> some View {
    HStack(alignment: .center, spacing: 12) {
        Text(label)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(width: 110, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
        slider()
        Text(val)
            .font(.subheadline.monospacedDigit())
            .foregroundStyle(.secondary)
            .frame(width: 42, alignment: .trailing)
    }
}

private func motionSummary(_ m: WalletMotion) -> String {
    func f2(_ v: Double) -> String { String(format: "%.2f", v) }
    func f3(_ v: Double) -> String { String(format: "%.3f", v) }
    func ints(_ a: [CGFloat]) -> String { a.map { String(Int($0)) }.joined(separator: ", ") }
    func f2s(_ a: [Double]) -> String { a.map { f2($0) }.joined(separator: ", ") }
    func f3s(_ a: [CGFloat]) -> String { a.map { f3(Double($0)) }.joined(separator: ", ") }
    return """
    springResponse: \(f2(m.springResponse))
    springDamping: \(f2(m.springDamping))
    expandDelayStep: \(f2(m.expandDelayStep))
    collapseDelayStep: \(f2(m.collapseDelayStep))
    punchScale: \(f2(Double(m.punchScale)))
    lift: [\(ints(m.lift))]
    rest: [\(ints(m.rest))]
    rotation: [\(f2s(m.rotation))]
    scale: [\(f3s(m.scale))]
    widths: [\(f3s(m.widths))]
    """
}
