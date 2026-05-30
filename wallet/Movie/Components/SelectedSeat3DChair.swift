import SwiftUI
import SceneKit

private enum SelectedSeat3DConfig {
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
        static let popSize: Float = 1.12
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

struct SelectedSeat3DChair: View {
    static let numberRevealDelay = SelectedSeat3DConfig.Animation.spinTime + SelectedSeat3DConfig.Animation.settleTime

    @State private var opacity = SelectedSeat3DConfig.Animation.hidden

    var body: some View {
        Seat3DSceneView()
            .frame(width: SelectedSeat3DConfig.Layout.width, height: SelectedSeat3DConfig.Layout.height)
            .opacity(opacity)
            .offset(x: SelectedSeat3DConfig.Layout.offsetX, y: SelectedSeat3DConfig.Layout.offsetY)
            .allowsHitTesting(false)
            .onAppear(perform: animateIn)
    }

    private func animateIn() {
        opacity = SelectedSeat3DConfig.Animation.hidden

        withAnimation(.easeOut(duration: SelectedSeat3DConfig.Animation.fadeIn)) {
            opacity = SelectedSeat3DConfig.Animation.visible
        }
    }
}

private struct Seat3DSceneView: UIViewRepresentable {
    private static let sourceScene: SCNScene? = {
        guard let url = Bundle.main.url(
            forResource: SelectedSeat3DConfig.Asset.name,
            withExtension: SelectedSeat3DConfig.Asset.fileExtension
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
        node.scale = uniformScale(SelectedSeat3DConfig.Model.scale)
        node.eulerAngles = SCNVector3(
            radians(SelectedSeat3DConfig.Model.pitchDegrees),
            radians(SelectedSeat3DConfig.Model.yawDegrees),
            radians(SelectedSeat3DConfig.Model.rollDegrees)
        )
    }

    private func prepareEntranceAnimation(on node: SCNNode) {
        node.opacity = 0
        node.scale = uniformScale(SelectedSeat3DConfig.Animation.startSize)
        node.eulerAngles.y += radians(Float(SelectedSeat3DConfig.Animation.spin))
    }

    private func animateModel(_ node: SCNNode) {
        let fade = SCNAction.fadeOpacity(to: 1, duration: SelectedSeat3DConfig.Animation.fadeIn)

        let spin = SCNAction.rotateBy(
            x: 0,
            y: CGFloat(radians(Float(-SelectedSeat3DConfig.Animation.spin))),
            z: 0,
            duration: SelectedSeat3DConfig.Animation.spinTime
        )
        spin.timingMode = .easeOut

        let grow = SCNAction.scale(to: CGFloat(SelectedSeat3DConfig.Animation.popSize), duration: SelectedSeat3DConfig.Animation.spinTime)
        grow.timingMode = .easeOut

        let settle = SCNAction.scale(to: CGFloat(SelectedSeat3DConfig.Animation.endSize), duration: SelectedSeat3DConfig.Animation.settleTime)
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
        let viewAspect = Double(SelectedSeat3DConfig.Layout.width / SelectedSeat3DConfig.Layout.height)

        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = max(modelHeight, modelWidth / viewAspect) / SelectedSeat3DConfig.Camera.fill
        camera.zNear = SelectedSeat3DConfig.Camera.zNear
        camera.zFar = SelectedSeat3DConfig.Camera.zFar

        let cameraNode = SCNNode()
        cameraNode.name = "seat-camera"
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(
            0,
            SelectedSeat3DConfig.Camera.yOffset,
            max(abs(modelDepth), 1) + SelectedSeat3DConfig.Camera.zPadding
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
        ambient.intensity = SelectedSeat3DConfig.Lighting.ambientIntensity
        let ambientNode = SCNNode()
        ambientNode.light = ambient
        scene.rootNode.addChildNode(ambientNode)

        let key = SCNLight()
        key.type = .directional
        key.intensity = SelectedSeat3DConfig.Lighting.keyIntensity
        let keyNode = SCNNode()
        keyNode.light = key
        keyNode.eulerAngles = SCNVector3(
            SelectedSeat3DConfig.Lighting.keyPitch,
            SelectedSeat3DConfig.Lighting.keyYaw,
            SelectedSeat3DConfig.Lighting.keyRoll
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
    ZStack {
        Color.black
        SelectedSeat3DChair()
    }
    .frame(width: 100, height: 100)
}
