import SwiftUI
import SceneKit

enum SeatState {
    case available
    case selected
    case sold

    var accessibilityValue: String {
        switch self {
        case .available: return "available"
        case .selected: return "selected"
        case .sold: return "sold"
        }
    }
}

struct Chair: View {
    let number: Int
    let state: SeatState
    let showsSeatNumber: Bool

    init(number: Int, state: SeatState, showsSeatNumber: Bool = true) {
        self.number = number
        self.state = state
        self.showsSeatNumber = showsSeatNumber
    }

    @State private var showsNumber = true
    @State private var numberRevealTask: Task<Void, Never>?
    @State private var shimmerPhase: Float = -0.3

    private typealias Style = MovieHomeStyle

    private enum ShimmerConfig {
        static let startPhase: Float = -0.3
        static let endPhase: Float   =  1.3
        static let duration: Double  =  0.65
    }

    var body: some View {
        ZStack {
            chairVisual
                .frame(width: Style.Layout.Seat.width, height: Style.Layout.Seat.height)
                #if !targetEnvironment(simulator)
                .visualEffect { content, geometry in
                    content.colorEffect(
                        ShaderLibrary.chairShimmer(
                            .float2(geometry.size),
                            .float(shimmerPhase)
                        )
                    )
                }
                #else
                .overlay(simulatorShimmer)
                #endif

            Text("\(number)")
                .font(.geist(Style.Typography.seatNumber, weight: .light))
                .foregroundStyle(Style.Palette.seatNumber)
                .opacity(showsSeatNumber && showsNumber ? 1 : 0)
        }
        .frame(width: Style.Layout.Seat.box, height: Style.Layout.Seat.slotHeight, alignment: .center)
        .onAppear {
            updateNumberVisibility(for: state)
        }
        .onChange(of: state) { _, newState in
            if newState == .selected { triggerShimmer() }
            updateNumberVisibility(for: newState)
        }
        .onDisappear {
            numberRevealTask?.cancel()
        }
    }

    private func triggerShimmer() {
        shimmerPhase = ShimmerConfig.startPhase
        withAnimation(.easeInOut(duration: ShimmerConfig.duration)) {
            shimmerPhase = ShimmerConfig.endPhase
        }
    }

    // Simulator fallback — plain gradient sweep (no Metal needed)
    @ViewBuilder private var simulatorShimmer: some View {
        let p = CGFloat(shimmerPhase)
        LinearGradient(
            stops: [
                .init(color: .clear,              location: max(0, p - 0.35)),
                .init(color: .white.opacity(0.55), location: p),
                .init(color: .clear,              location: min(1, p + 0.35)),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .blendMode(.screen)
        .blur(radius: 2)
        .allowsHitTesting(false)
    }
        .blendMode(.screen)
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var chairVisual: some View {
        switch state {
        case .selected:
            SelectedChair3D()
        case .available:
            movieAssetImage(Style.Asset.availableChair)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
        case .sold:
            movieAssetImage(Style.Asset.availableChair)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(Style.Palette.soldSeat)
        }
    }

    private func updateNumberVisibility(for state: SeatState) {
        numberRevealTask?.cancel()

        guard state == .selected else {
            showsNumber = true
            return
        }

        showsNumber = false
        numberRevealTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(SelectedChair3D.numberRevealDelay * 1_000_000_000))

            guard !Task.isCancelled else { return }
            await MainActor.run {
                showsNumber = true
            }
        }
    }

}


private enum SelectedChairConfig {
    enum Asset {
        static let name = "cinema+seat+3d+model"
        static let fileExtension = "usdz"
    }

    enum Layout {
        static let width = MovieHomeStyle.Layout.Seat.width
        static let height = MovieHomeStyle.Layout.Seat.height
        static let offsetX: CGFloat = 0
        static let offsetY: CGFloat = 0
    }

    enum Animation {
        static let hidden: CGFloat = 0
        static let visible: CGFloat = 1
        static let fadeIn: TimeInterval = 0.08
        static let startSize: Float = 0.42
        static let endSize: Float = Model.scale
        static let popSize: Float = 1.2
        static let spin: CGFloat = -400
        static let spinTime: TimeInterval = 0.4
        static let settleTime: TimeInterval = 0.16
    }

    enum Model {
        static let scale: Float = 1
        static let pitchDegrees: Float = -90
        static let yawDegrees: Float = -90
        static let rollDegrees: Float = 0
    }

    enum Camera {
        static let fill: Double = 1.22
        static let zPadding: Float = 3
        static let yOffset: Float = 0
        static let zNear: Double = 0.01
        static let zFar: Double = 100
    }

    enum Lighting {
        static let ambientIntensity: CGFloat = 950
        static let keyIntensity: CGFloat = 720
        static let keyPitch: Float = -0.55
        static let keyYaw: Float = 0.3
        static let keyRoll: Float = 0
    }
}

private struct SelectedChair3D: View {
    static let numberRevealDelay = SelectedChairConfig.Animation.spinTime + SelectedChairConfig.Animation.settleTime

    @State private var opacity = SelectedChairConfig.Animation.hidden

    var body: some View {
        Seat3DSceneView()
            .frame(width: SelectedChairConfig.Layout.width, height: SelectedChairConfig.Layout.height)
            .opacity(opacity)
            .offset(x: SelectedChairConfig.Layout.offsetX, y: SelectedChairConfig.Layout.offsetY)
            .allowsHitTesting(false)
            .onAppear(perform: animateIn)
    }

    private func animateIn() {
        opacity = SelectedChairConfig.Animation.hidden

        withAnimation(.easeOut(duration: SelectedChairConfig.Animation.fadeIn)) {
            opacity = SelectedChairConfig.Animation.visible
        }
    }
}

private struct Seat3DSceneView: UIViewRepresentable {
    private static let sourceScene: SCNScene? = {
        guard let url = Bundle.main.url(
            forResource: SelectedChairConfig.Asset.name,
            withExtension: SelectedChairConfig.Asset.fileExtension
        ) else {
            return nil
        }
        return try? SCNScene(url: url)
    }()

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.autoenablesDefaultLighting = false
        view.antialiasingMode = .multisampling4X
        view.contentScaleFactor = view.traitCollection.displayScale
        view.rendersContinuously = false

        let scene = makeScene()
        view.scene = scene
        view.pointOfView = scene.rootNode.childNode(withName: "seat-camera", recursively: false)
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}

    private func makeScene() -> SCNScene {
        let scene = SCNScene()
        let modelRoot = SCNNode()
        modelRoot.name = "selected-seat-model"

        if let sourceScene = Self.sourceScene {
            for child in sourceScene.rootNode.childNodes {
                modelRoot.addChildNode(child.clone())
            }
        }

        recenter(modelRoot)
        setFinalTransform(on: modelRoot)
        prepareEntranceAnimation(on: modelRoot)

        scene.rootNode.addChildNode(modelRoot)
        addCamera(to: scene, for: modelRoot)
        addLights(to: scene)
        animateModel(modelRoot)
        return scene
    }

    private func setFinalTransform(on node: SCNNode) {
        node.scale = uniformScale(SelectedChairConfig.Model.scale)
        node.eulerAngles = SCNVector3(
            radians(SelectedChairConfig.Model.pitchDegrees),
            radians(SelectedChairConfig.Model.yawDegrees),
            radians(SelectedChairConfig.Model.rollDegrees)
        )
    }

    private func prepareEntranceAnimation(on node: SCNNode) {
        node.opacity = 0
        node.scale = uniformScale(SelectedChairConfig.Animation.startSize)
        node.eulerAngles.y += radians(Float(SelectedChairConfig.Animation.spin))
    }

    private func animateModel(_ node: SCNNode) {
        let fade = SCNAction.fadeOpacity(to: 1, duration: SelectedChairConfig.Animation.fadeIn)

        let spin = SCNAction.rotateBy(
            x: 0,
            y: CGFloat(radians(Float(-SelectedChairConfig.Animation.spin))),
            z: 0,
            duration: SelectedChairConfig.Animation.spinTime
        )
        spin.timingMode = .easeOut

        let grow = SCNAction.scale(to: CGFloat(SelectedChairConfig.Animation.popSize), duration: SelectedChairConfig.Animation.spinTime)
        grow.timingMode = .easeOut

        let settle = SCNAction.scale(to: CGFloat(SelectedChairConfig.Animation.endSize), duration: SelectedChairConfig.Animation.settleTime)
        settle.timingMode = .easeInEaseOut

        node.runAction(.group([
            fade,
            .sequence([
                .group([spin, grow]),
                settle
            ])
        ]))
    }

    private func recenter(_ node: SCNNode) {
        let (minB, maxB) = hierarchyBounds(of: node)
        guard minB.x <= maxB.x else { return }

        let center = SCNVector3(
            (minB.x + maxB.x) / 2,
            (minB.y + maxB.y) / 2,
            (minB.z + maxB.z) / 2
        )

        for child in node.childNodes {
            child.position.x -= center.x
            child.position.y -= center.y
            child.position.z -= center.z
        }
    }

    private func addCamera(to scene: SCNScene, for modelRoot: SCNNode) {
        let (minB, maxB) = hierarchyBounds(of: modelRoot)
        let modelWidth = Double(maxB.x - minB.x)
        let modelHeight = Double(maxB.y - minB.y)
        let modelDepth = maxB.z - minB.z
        let viewAspect = Double(SelectedChairConfig.Layout.width / SelectedChairConfig.Layout.height)

        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = max(modelHeight, modelWidth / viewAspect) / SelectedChairConfig.Camera.fill
        camera.zNear = SelectedChairConfig.Camera.zNear
        camera.zFar = SelectedChairConfig.Camera.zFar

        let cameraNode = SCNNode()
        cameraNode.name = "seat-camera"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(
            0,
            SelectedChairConfig.Camera.yOffset,
            max(abs(modelDepth), 1) + SelectedChairConfig.Camera.zPadding
        )
        scene.rootNode.addChildNode(cameraNode)
    }

    private func hierarchyBounds(of node: SCNNode) -> (SCNVector3, SCNVector3) {
        var minV = SCNVector3(
            Float.greatestFiniteMagnitude,
            Float.greatestFiniteMagnitude,
            Float.greatestFiniteMagnitude
        )
        var maxV = SCNVector3(
            -Float.greatestFiniteMagnitude,
            -Float.greatestFiniteMagnitude,
            -Float.greatestFiniteMagnitude
        )

        node.enumerateHierarchy { child, _ in
            guard child.geometry != nil else { return }
            let (childMin, childMax) = child.boundingBox
            let corners = [
                SCNVector3(childMin.x, childMin.y, childMin.z),
                SCNVector3(childMax.x, childMin.y, childMin.z),
                SCNVector3(childMin.x, childMax.y, childMin.z),
                SCNVector3(childMin.x, childMin.y, childMax.z),
                SCNVector3(childMax.x, childMax.y, childMin.z),
                SCNVector3(childMax.x, childMin.y, childMax.z),
                SCNVector3(childMin.x, childMax.y, childMax.z),
                SCNVector3(childMax.x, childMax.y, childMax.z)
            ]

            for corner in corners {
                let point = node.convertPosition(corner, from: child)
                minV.x = min(minV.x, point.x)
                minV.y = min(minV.y, point.y)
                minV.z = min(minV.z, point.z)
                maxV.x = max(maxV.x, point.x)
                maxV.y = max(maxV.y, point.y)
                maxV.z = max(maxV.z, point.z)
            }
        }

        return (minV, maxV)
    }

    private func addLights(to scene: SCNScene) {
        let ambient = SCNLight()
        ambient.type = .ambient
        ambient.intensity = SelectedChairConfig.Lighting.ambientIntensity
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        let key = SCNLight()
        key.type = .directional
        key.intensity = SelectedChairConfig.Lighting.keyIntensity
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.eulerAngles = SCNVector3(
            SelectedChairConfig.Lighting.keyPitch,
            SelectedChairConfig.Lighting.keyYaw,
            SelectedChairConfig.Lighting.keyRoll
        )
        scene.rootNode.addChildNode(keyNode)
    }

    private func uniformScale(_ value: Float) -> SCNVector3 {
        SCNVector3(value, value, value)
    }

    private func radians(_ degrees: Float) -> Float {
        degrees * .pi / 180
    }
}

#Preview {
    @Previewable @State var state: SeatState = .available
    VStack(spacing: 24) {
        Chair(number: 4, state: state)
        Button(state == .selected ? "Deselect" : "Select") {
            state = state == .selected ? .available : .selected
        }
        .foregroundStyle(.white)
    }
    .padding(40)
    .background(.black)
}
