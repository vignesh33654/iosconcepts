//
//  HolographicScannerView.swift
//  iosconcepts
//

import SwiftUI

// MARK: - Main View

struct HolographicScannerView: View {

    @State private var scanProgress: CGFloat = 0
    @State private var glowPulse: Double = 0.5

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 32) {
                header
                scannerFrame
                statusRow
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) {
                scanProgress = 1
            }
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                glowPulse = 1.0
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 6) {
            Text("Holographic Scan")
                .font(.system(size: 22, weight: .light, design: .serif))
                .foregroundStyle(.white)

            Text("Align your ID card within the frame")
                .font(.system(size: 13))
                .foregroundStyle(.white.opacity(0.45))
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - Scanner Frame

    private var scannerFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.03))

            DotGrid()
                .padding(22)
                .opacity(0.14)

            SweepLine(progress: scanProgress)
                .padding(20)
                .clipped()

            QRCornerFinders(glowPulse: glowPulse)
        }
        .frame(width: 290, height: 290)
    }

    // MARK: - Status Row

    private var statusRow: some View {
        HStack(spacing: 9) {
            Circle()
                .fill(LinearGradient(
                    colors: ScannerConfig.holoColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 7, height: 7)
                .opacity(glowPulse)

            Text("Scanning for holographic data")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
        }
    }
}

// MARK: - Config

private enum ScannerConfig {
    static let holoColors: [Color] = [
        Color(red: 0.6,  green: 0.0,  blue: 1.0),
        Color(red: 0.0,  green: 0.5,  blue: 1.0),
        Color(red: 0.0,  green: 0.9,  blue: 0.85),
        Color(red: 0.2,  green: 0.85, blue: 0.3),
        Color(red: 1.0,  green: 0.9,  blue: 0.0),
    ]

    static let cornerSize: CGFloat         = 46
    static let cornerThickness: CGFloat    = 4
    static let cornerRadius: CGFloat       = 10
    static let cornerInnerSize: CGFloat    = 20
    static let cornerInnerRadius: CGFloat  = 5
    static let cornerPadding: CGFloat      = 16

    static let sweepLineHeight: CGFloat    = 2
    static let sweepTailHeight: CGFloat    = 52
    static let sweepGlowRadius: CGFloat    = 5
    static let sweepTailOpacity: Double    = 0.22

    static let dotColumns   = 13
    static let dotRows      = 13
    static let dotRadius: CGFloat = 1.5
}

// MARK: - QR Corner Finders

private struct QRCornerFinders: View {
    let glowPulse: Double

    var body: some View {
        ZStack {
            finder(.topLeading)
            finder(.topTrailing)
            finder(.bottomLeading)
            finder(.bottomTrailing)
        }
    }

    @ViewBuilder
    private func finder(_ corner: Alignment) -> some View {
        let isLeading = corner == .topLeading || corner == .bottomLeading
        let gradient = LinearGradient(
            colors: ScannerConfig.holoColors,
            startPoint: isLeading ? .topLeading : .topTrailing,
            endPoint: isLeading ? .bottomTrailing : .bottomLeading
        )

        ZStack {
            // Outer ring
            RoundedRectangle(cornerRadius: ScannerConfig.cornerRadius, style: .continuous)
                .strokeBorder(gradient, lineWidth: ScannerConfig.cornerThickness)
                .frame(width: ScannerConfig.cornerSize, height: ScannerConfig.cornerSize)
                .shadow(
                    color: Color(red: 0.3, green: 0.5, blue: 1.0).opacity(glowPulse * 0.5),
                    radius: 8
                )

            // Inner filled square
            RoundedRectangle(cornerRadius: ScannerConfig.cornerInnerRadius, style: .continuous)
                .fill(gradient)
                .frame(width: ScannerConfig.cornerInnerSize, height: ScannerConfig.cornerInnerSize)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: corner)
        .padding(ScannerConfig.cornerPadding)
    }
}

// MARK: - Sweep Line

private struct SweepLine: View {
    let progress: CGFloat

    var body: some View {
        GeometryReader { geo in
            let y = progress * geo.size.height

            ZStack(alignment: .top) {
                // Gradient tail below the line
                LinearGradient(
                    colors: [
                        Color(red: 0.2, green: 0.6, blue: 1.0).opacity(ScannerConfig.sweepTailOpacity),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: ScannerConfig.sweepTailHeight)
                .offset(y: y)

                // Main line
                Capsule()
                    .fill(LinearGradient(
                        colors: [.clear] + ScannerConfig.holoColors + [.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: geo.size.width, height: ScannerConfig.sweepLineHeight)
                    .shadow(
                        color: Color(red: 0.4, green: 0.6, blue: 1.0),
                        radius: ScannerConfig.sweepGlowRadius
                    )
                    .offset(y: y)
            }
        }
    }
}

// MARK: - Dot Grid

private struct DotGrid: View {
    var body: some View {
        Canvas { ctx, size in
            let cols = ScannerConfig.dotColumns
            let rows = ScannerConfig.dotRows
            let r    = ScannerConfig.dotRadius
            let dx   = size.width  / CGFloat(cols)
            let dy   = size.height / CGFloat(rows)

            for row in 0..<rows {
                for col in 0..<cols {
                    let cx = (CGFloat(col) + 0.5) * dx
                    let cy = (CGFloat(row) + 0.5) * dy
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: cx - r, y: cy - r, width: r * 2, height: r * 2)),
                        with: .color(.white)
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview {
    HolographicScannerView()
}
