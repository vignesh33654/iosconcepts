import SwiftUI
import SceneKit
import UIKit

struct PanoramaView: UIViewRepresentable {
    let imageName: String

    private enum Config {
        static let preferredFramesPerSecond = 60
        static let maximumVerticalAngle: Float = 80
        static let minimumVerticalAngle: Float = -80
        static let sphereRadius: CGFloat = 10
        static let sphereSegmentCount = 192
        static let materialMaxAnisotropy: CGFloat = 16
        static let sphereScale = SCNVector3(1, 1, -1)
        static let cameraPosition = SCNVector3(0, 0, 0)
        static let cameraFieldOfView: CGFloat = 95
        static let entranceFieldOfView: CGFloat = 130
        static let entranceCameraPosition = SCNVector3(0, 0, 2.4)
        static let entranceDuration: CFTimeInterval = 0.8
        static let placeholderSize = CGSize(width: 2048, height: 1024)
        static let placeholderGradientLocations: [CGFloat] = [0, 1]
        static let placeholderGridAlpha: CGFloat = 0.18
        static let placeholderGridLineWidth: CGFloat = 2
        static let placeholderGridColumnGap: CGFloat = 256
        static let placeholderGridRowGap: CGFloat = 128
        static let placeholderTitleFontSize: CGFloat = 72
        static let placeholderSubtitleFontSize: CGFloat = 44
        static let placeholderSubtitleAlpha: CGFloat = 0.68
        static let placeholderTitlePosition = CGPoint(x: 120, y: 388)
        static let placeholderSubtitlePosition = CGPoint(x: 124, y: 480)
        static let placeholderStartColor = UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 1)
        static let placeholderEndColor = UIColor(red: 0.16, green: 0.10, blue: 0.07, alpha: 1)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        configure(view)

        let sceneSetup = makeScene(imageName: imageName)
        view.scene = sceneSetup.scene
        view.pointOfView = sceneSetup.cameraNode
        context.coordinator.cameraNode = sceneSetup.cameraNode

        let cameraNode = sceneSetup.cameraNode
        cameraNode.camera?.fieldOfView = Config.entranceFieldOfView
        cameraNode.position = Config.entranceCameraPosition

        return view
    }

    func updateUIView(_ view: SCNView, context: Context) {
        guard !context.coordinator.didAnimateEntrance else { return }
        context.coordinator.didAnimateEntrance = true
        context.coordinator.playEntrance()
    }

    final class Coordinator {
        weak var cameraNode: SCNNode?
        var didAnimateEntrance = false

        func playEntrance() {
            guard let cameraNode, let camera = cameraNode.camera else { return }
            SCNTransaction.begin()
            SCNTransaction.animationDuration = Config.entranceDuration
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeOut)
            camera.fieldOfView = Config.cameraFieldOfView
            cameraNode.position = Config.cameraPosition
            SCNTransaction.commit()
        }
    }

    private func configure(_ view: SCNView) {
        view.allowsCameraControl = true
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        view.contentScaleFactor = view.traitCollection.displayScale
        view.antialiasingMode = .multisampling4X
        view.preferredFramesPerSecond = Config.preferredFramesPerSecond
        view.defaultCameraController.maximumVerticalAngle = Config.maximumVerticalAngle
        view.defaultCameraController.minimumVerticalAngle = Config.minimumVerticalAngle
        view.defaultCameraController.inertiaEnabled = true
    }

    private func makeScene(imageName: String) -> (scene: SCNScene, cameraNode: SCNNode) {
        let scene = SCNScene()

        let sphere = SCNSphere(radius: Config.sphereRadius)
        sphere.segmentCount = Config.sphereSegmentCount

        let material = SCNMaterial()
        material.diffuse.contents = image(named: imageName)
        material.diffuse.magnificationFilter = .linear
        material.diffuse.minificationFilter = .linear
        material.diffuse.mipFilter = .none
        material.diffuse.maxAnisotropy = Config.materialMaxAnisotropy
        material.isDoubleSided = true
        material.cullMode = .front
        material.lightingModel = .constant
        sphere.firstMaterial = material

        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.scale = Config.sphereScale
        scene.rootNode.addChildNode(sphereNode)

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = Config.cameraPosition
        cameraNode.camera?.fieldOfView = Config.cameraFieldOfView
        scene.rootNode.addChildNode(cameraNode)

        return (scene, cameraNode)
    }

    private func image(named imageName: String) -> UIImage {
        if let url = Bundle.main.url(forResource: imageName, withExtension: "png"),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }

        return UIImage(named: imageName) ?? placeholderImage(named: imageName)
    }

    private func placeholderImage(named imageName: String) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: Config.placeholderSize)

        return renderer.image { context in
            let cgContext = context.cgContext
            let colors = [
                Config.placeholderStartColor.cgColor,
                Config.placeholderEndColor.cgColor
            ] as CFArray

            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors,
                locations: Config.placeholderGradientLocations
            ) else {
                return
            }

            cgContext.drawLinearGradient(
                gradient,
                start: .zero,
                end: CGPoint(x: Config.placeholderSize.width, y: Config.placeholderSize.height),
                options: []
            )

            UIColor.white.withAlphaComponent(Config.placeholderGridAlpha).setStroke()
            cgContext.setLineWidth(Config.placeholderGridLineWidth)
            for x in stride(from: CGFloat.zero, through: Config.placeholderSize.width, by: Config.placeholderGridColumnGap) {
                cgContext.move(to: CGPoint(x: x, y: .zero))
                cgContext.addLine(to: CGPoint(x: x, y: Config.placeholderSize.height))
            }
            for y in stride(from: CGFloat.zero, through: Config.placeholderSize.height, by: Config.placeholderGridRowGap) {
                cgContext.move(to: CGPoint(x: .zero, y: y))
                cgContext.addLine(to: CGPoint(x: Config.placeholderSize.width, y: y))
            }
            cgContext.strokePath()

            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Config.placeholderTitleFontSize, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Config.placeholderSubtitleFontSize, weight: .medium),
                .foregroundColor: UIColor.white.withAlphaComponent(Config.placeholderSubtitleAlpha)
            ]

            "Missing panorama".draw(at: Config.placeholderTitlePosition, withAttributes: titleAttributes)
            imageName.draw(at: Config.placeholderSubtitlePosition, withAttributes: subtitleAttributes)
        }
    }
}

#Preview {
    PanoramaView(imageName: "Movie Theatre view")
        .ignoresSafeArea()
}
