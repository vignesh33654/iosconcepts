import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

private struct ChairRow: Identifiable, Hashable {
    let name: String
    let numbers: [Int]
    let aisleAfter: Bool

    var id: String { name }
}

struct ChairMapPerspectiveConfig: Equatable {
    var rotationX: Double = 0
    var rotationY: Double = 0
    var rotationZ: Double = 0
    var perspective: CGFloat = 0.35
    var scale: CGFloat = 1
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
    var anchorX: CGFloat = 0.5
    var anchorY: CGFloat = 0.5
    var showsAllSelectedPreview: Bool = false
    var chairRotation: Double = 0

    static let standard = ChairMapPerspectiveConfig()

    var anchor: UnitPoint {
        UnitPoint(x: anchorX, y: anchorY)
    }

    var swiftSnippet: String {
        """
        ChairMapPerspectiveConfig(
            rotationX: \(format(rotationX)),
            rotationY: \(format(rotationY)),
            rotationZ: \(format(rotationZ)),
            perspective: \(format(Double(perspective))),
            scale: \(format(Double(scale))),
            offsetX: \(format(Double(offsetX))),
            offsetY: \(format(Double(offsetY))),
            anchorX: \(format(Double(anchorX))),
            anchorY: \(format(Double(anchorY))),
            showsAllSelectedPreview: \(showsAllSelectedPreview),
            chairRotation: \(format(chairRotation))
        )
        """
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f", value)
    }
}

struct ChairMapView: View {
    @Binding var selectedSeats: Set<String>
    let soldSeats: Set<String>
    let perspectiveConfig: ChairMapPerspectiveConfig

    init(
        selectedSeats: Binding<Set<String>>,
        soldSeats: Set<String>,
        perspectiveConfig: ChairMapPerspectiveConfig = .standard
    ) {
        self._selectedSeats = selectedSeats
        self.soldSeats = soldSeats
        self.perspectiveConfig = perspectiveConfig
    }

    private typealias Style = MovieHomeStyle

    private static let fullRow = Array(1...9)
    private static let hiddenSeats: Set<String> = ["F-5", "G-5", "H-5"]
    private static let rows: [ChairRow] = [
        ChairRow(name: "A", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "B", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "C", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "D", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "E", numbers: fullRow, aisleAfter: true),
        ChairRow(name: "F", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "G", numbers: fullRow, aisleAfter: false),
        ChairRow(name: "H", numbers: fullRow, aisleAfter: false),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Self.rows) { row in
                chairRow(row)

                if row.aisleAfter {
                    Color.clear.frame(height: Style.Layout.Seat.aisleGap)
                }
            }
        }
        .rotation3DEffect(
            .degrees(perspectiveConfig.rotationX),
            axis: (x: 1, y: 0, z: 0),
            anchor: perspectiveConfig.anchor,
            perspective: perspectiveConfig.perspective
        )
        .rotation3DEffect(
            .degrees(perspectiveConfig.rotationY),
            axis: (x: 0, y: 1, z: 0),
            anchor: perspectiveConfig.anchor,
            perspective: perspectiveConfig.perspective
        )
        .rotationEffect(.degrees(perspectiveConfig.rotationZ), anchor: perspectiveConfig.anchor)
        .scaleEffect(perspectiveConfig.scale, anchor: perspectiveConfig.anchor)
        .offset(x: perspectiveConfig.offsetX, y: perspectiveConfig.offsetY)
    }

    private func chairRow(_ row: ChairRow) -> some View {
        HStack(alignment: .center, spacing: Style.Layout.Seat.rowGap) {
            Text(row.name)
                .font(.geist(Style.Typography.rowLabel))
                .foregroundStyle(.white)
                .frame(width: Style.Layout.Seat.rowWidth, height: Style.Layout.Seat.slotHeight, alignment: .center)

            HStack(spacing: Style.Layout.Seat.step - Style.Layout.Seat.box) {
                ForEach(row.numbers, id: \.self) { number in
                    chairButton(row: row.name, number: number)
                }
            }
        }
        .frame(height: Style.Layout.Seat.slotHeight)
    }

    private func chairButton(row: String, number: Int) -> some View {
        let id = "\(row)-\(number)"
        let state = chairState(for: id, showsSeat: !Self.hiddenSeats.contains(id))
        let showsSeat = !Self.hiddenSeats.contains(id)

        return Button {
            toggle(id, state: state)
        } label: {
            Chair(number: number, state: state)
                .rotationEffect(.degrees(perspectiveConfig.chairRotation))
                .opacity(showsSeat ? 1 : 0)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!showsSeat)
        .accessibilityHidden(!showsSeat)
        .accessibilityLabel("Seat \(row)\(number)")
        .accessibilityValue(state.accessibilityValue)
        .accessibilityAddTraits(state == .sold ? .isStaticText : [])
    }

    private func chairState(for id: String, showsSeat: Bool) -> SeatState {
        if perspectiveConfig.showsAllSelectedPreview && showsSeat { return .selected }
        if soldSeats.contains(id) { return .sold }
        if selectedSeats.contains(id) { return .selected }
        return .available
    }

    private func toggle(_ id: String, state: SeatState) {
        switch state {
        case .sold:
            return
        case .selected:
            selectedSeats.remove(id)
        case .available:
            selectedSeats.insert(id)
        }
    }
}

struct ChairMapPerspectiveControls: View {
    @Binding var config: ChairMapPerspectiveConfig
    let maxHeight: CGFloat

    init(config: Binding<ChairMapPerspectiveConfig>, maxHeight: CGFloat = 360) {
        self._config = config
        self.maxHeight = maxHeight
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Seat Map 3D")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)

                Spacer()

                Button {
                    copyConfig()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Copy seat map config")

                Button("Reset") {
                    config = .standard
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(MovieHomeStyle.Palette.accent)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    Toggle("All chairs selected", isOn: $config.showsAllSelectedPreview)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.75))
                        .tint(MovieHomeStyle.Palette.accent)

                    control("Chair angle", value: $config.chairRotation, range: -180...180, format: "%.0f°")
                    control("X", value: $config.rotationX, range: -80...80, format: "%.0f°")
                    control("Y", value: $config.rotationY, range: -80...80, format: "%.0f°")
                    control("Z", value: $config.rotationZ, range: -45...45, format: "%.0f°")
                    control("Depth", value: perspectiveBinding, range: 0...1, format: "%.2f")
                    control("Scale", value: scaleBinding, range: 0.5...1.5, format: "%.2f")
                    control("Move X", value: offsetXBinding, range: -160...160, format: "%.0f")
                    control("Move Y", value: offsetYBinding, range: -220...220, format: "%.0f")
                    control("Anchor X", value: anchorXBinding, range: 0...1, format: "%.2f")
                    control("Anchor Y", value: anchorYBinding, range: 0...1, format: "%.2f")
                }
            }
        }
        .padding(14)
        .frame(maxHeight: maxHeight)
        .background(.black.opacity(0.88), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        }
    }

    private func copyConfig() {
        #if canImport(UIKit)
        UIPasteboard.general.string = config.swiftSnippet
        #endif
    }

    private func control(
        _ title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        format: String
    ) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(String(format: format, value.wrappedValue))
                    .monospacedDigit()
            }
            .font(.system(size: 11))
            .foregroundStyle(.white.opacity(0.75))

            Slider(value: value, in: range)
                .tint(MovieHomeStyle.Palette.accent)
        }
    }

    private var perspectiveBinding: Binding<Double> {
        Binding(
            get: { Double(config.perspective) },
            set: { config.perspective = CGFloat($0) }
        )
    }

    private var scaleBinding: Binding<Double> {
        Binding(
            get: { Double(config.scale) },
            set: { config.scale = CGFloat($0) }
        )
    }

    private var offsetXBinding: Binding<Double> {
        Binding(
            get: { Double(config.offsetX) },
            set: { config.offsetX = CGFloat($0) }
        )
    }

    private var offsetYBinding: Binding<Double> {
        Binding(
            get: { Double(config.offsetY) },
            set: { config.offsetY = CGFloat($0) }
        )
    }

    private var anchorXBinding: Binding<Double> {
        Binding(
            get: { Double(config.anchorX) },
            set: { config.anchorX = CGFloat($0) }
        )
    }

    private var anchorYBinding: Binding<Double> {
        Binding(
            get: { Double(config.anchorY) },
            set: { config.anchorY = CGFloat($0) }
        )
    }
}

#Preview {
    ChairMapView(selectedSeats: .constant([]), soldSeats: [])
        .padding()
        .background(.black)
}
