import SwiftUI
import SceneKit

// MARK: - World Globe View

struct WorldGlobeView: View {
    @Binding var isSpinning: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            // Glow effect background (non-interactive)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.routaPrimary.opacity(0.4),
                            Color.purple.opacity(0.3),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 120,
                        endRadius: 200
                    )
                )
                .frame(width: 200, height: 200)
                .blur(radius: 25)
                .allowsHitTesting(false) // Glow doesn't receive taps

            // 3D Globe (only this is tappable)
            GlobeSceneView(isSpinning: $isSpinning)
                .frame(width: 380, height: 380)
                .contentShape(Circle()) // Limit tap area to circular globe shape
                .onTapGesture {
                    if !isSpinning {
                        onTap()
                    }
                }
        }
        .frame(height: 380) // Set fixed height to limit vertical space
        .offset(y: -20)
    }
}

// MARK: - SceneKit Globe View

struct GlobeSceneView: UIViewRepresentable {
    @Binding var isSpinning: Bool

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.backgroundColor = .clear
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X

        // Create scene
        let scene = SCNScene()
        sceneView.scene = scene

        // Create camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3.5)
        scene.rootNode.addChildNode(cameraNode)

        // Create Earth sphere
        let earthNode = createEarthNode()
        earthNode.name = "earth"

        // Set initial rotation to show Turkey (approximately 35°E, 39°N)
        // Longitude: 35°E → rotate Y axis
        // Latitude: 39°N → rotate X axis to tilt down
        let turkeyLongitude: Float = 35.0 // degrees
        let turkeyLatitude: Float = 39.0 // degrees

        let initialRotationY = -turkeyLongitude * .pi / 180.0 // Convert to radians and negate
        let initialRotationX = -(turkeyLatitude - 70) * .pi / 180.0 // Tilt to show Turkey lower on screen

        earthNode.eulerAngles = SCNVector3(x: initialRotationX, y: initialRotationY, z: 0)

        scene.rootNode.addChildNode(earthNode)

        // Create atmosphere
        let atmosphereNode = createAtmosphereNode()
        scene.rootNode.addChildNode(atmosphereNode)

        // Add lighting
        setupLighting(scene: scene)

        // Start idle rotation
        startIdleRotation(node: earthNode)

        context.coordinator.sceneView = sceneView
        context.coordinator.earthNode = earthNode

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if isSpinning && !context.coordinator.isCurrentlySpinning {
            context.coordinator.isCurrentlySpinning = true
            performSpinAnimation(node: context.coordinator.earthNode) {
                DispatchQueue.main.async {
                    self.isSpinning = false
                    context.coordinator.isCurrentlySpinning = false
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var sceneView: SCNView?
        var earthNode: SCNNode?
        var isCurrentlySpinning = false
    }

    // MARK: - Earth Node Creation

    private func createEarthNode() -> SCNNode {
        let sphere = SCNSphere(radius: 1.0)

        // Create materials with realistic textures
        let material = SCNMaterial()

        // Load realistic Earth texture
        material.diffuse.contents = loadEarthTexture()

        // Specular map for shiny oceans
        material.specular.contents = UIColor(white: 0.3, alpha: 1.0)
        material.shininess = 0.15

        // Normal map for depth and detail
        material.normal.intensity = 0.8

        // Emission for subtle atmosphere glow
        material.emission.contents = UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 0.05)

        // Better lighting response
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0.0
        material.roughness.contents = 0.8

        sphere.materials = [material]

        let node = SCNNode(geometry: sphere)
        return node
    }

    // MARK: - Load Earth Texture

    private func loadEarthTexture() -> UIImage? {
        // Try to load from bundle first (if user added it)
        if let bundleImage = UIImage(named: "earth_texture") {
            return bundleImage
        }

        // Use a high-quality procedural texture with better realism
        return createRealisticEarthTexture()
    }

    // MARK: - Create Realistic Earth Texture

    private func createRealisticEarthTexture() -> UIImage {
        let size = CGSize(width: 2048, height: 2048)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let ctx = context.cgContext

            // Ocean with realistic depth gradient
            let oceanGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.02, green: 0.15, blue: 0.28, alpha: 1.0).cgColor,
                    UIColor(red: 0.05, green: 0.25, blue: 0.45, alpha: 1.0).cgColor,
                    UIColor(red: 0.08, green: 0.35, blue: 0.58, alpha: 1.0).cgColor
                ] as CFArray,
                locations: [0.0, 0.5, 1.0]
            )!

            ctx.drawRadialGradient(
                oceanGradient,
                startCenter: CGPoint(x: size.width/2, y: size.height/2),
                startRadius: 0,
                endCenter: CGPoint(x: size.width/2, y: size.height/2),
                endRadius: size.width/2,
                options: []
            )

            // More detailed continents with realistic positioning
            let continentPaths = createContinentPaths(size: size)

            for (path, color) in continentPaths {
                ctx.saveGState()
                color.setFill()
                ctx.addPath(path)
                ctx.fillPath()
                ctx.restoreGState()
            }

            // Add terrain variation
            addTerrainDetails(ctx: ctx, size: size)

            // Add atmospheric clouds
            addClouds(ctx: ctx, size: size)

            // Add ice caps
            addIceCaps(ctx: ctx, size: size)
        }
    }

    private func createContinentPaths(size: CGSize) -> [(CGPath, UIColor)] {
        var paths: [(CGPath, UIColor)] = []

        // Africa (center-right)
        let africa = createIrregularShape(
            center: CGPoint(x: size.width * 0.55, y: size.height * 0.5),
            radius: size.width * 0.15,
            points: 12,
            irregularity: 0.6
        )
        paths.append((africa, UIColor(red: 0.35, green: 0.50, blue: 0.20, alpha: 1.0)))

        // Europe (center-top)
        let europe = createIrregularShape(
            center: CGPoint(x: size.width * 0.52, y: size.height * 0.25),
            radius: size.width * 0.10,
            points: 10,
            irregularity: 0.7
        )
        paths.append((europe, UIColor(red: 0.28, green: 0.55, blue: 0.25, alpha: 1.0)))

        // Asia (right)
        let asia = createIrregularShape(
            center: CGPoint(x: size.width * 0.75, y: size.height * 0.30),
            radius: size.width * 0.20,
            points: 14,
            irregularity: 0.5
        )
        paths.append((asia, UIColor(red: 0.30, green: 0.52, blue: 0.22, alpha: 1.0)))

        // North America (left)
        let northAmerica = createIrregularShape(
            center: CGPoint(x: size.width * 0.20, y: size.height * 0.30),
            radius: size.width * 0.14,
            points: 12,
            irregularity: 0.65
        )
        paths.append((northAmerica, UIColor(red: 0.25, green: 0.53, blue: 0.24, alpha: 1.0)))

        // South America (left-bottom)
        let southAmerica = createIrregularShape(
            center: CGPoint(x: size.width * 0.25, y: size.height * 0.60),
            radius: size.width * 0.11,
            points: 10,
            irregularity: 0.6
        )
        paths.append((southAmerica, UIColor(red: 0.30, green: 0.58, blue: 0.28, alpha: 1.0)))

        // Australia (far right-bottom)
        let australia = createIrregularShape(
            center: CGPoint(x: size.width * 0.82, y: size.height * 0.68),
            radius: size.width * 0.08,
            points: 8,
            irregularity: 0.5
        )
        paths.append((australia, UIColor(red: 0.40, green: 0.45, blue: 0.20, alpha: 1.0)))

        return paths
    }

    private func createIrregularShape(center: CGPoint, radius: CGFloat, points: Int, irregularity: CGFloat) -> CGPath {
        let path = CGMutablePath()

        for i in 0..<points {
            let angle = CGFloat(i) * (2 * .pi / CGFloat(points))
            let randomRadius = radius * CGFloat.random(in: (1-irregularity)...(1+irregularity/2))
            let x = center.x + cos(angle) * randomRadius
            let y = center.y + sin(angle) * randomRadius

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()

        return path
    }

    private func addTerrainDetails(ctx: CGContext, size: CGSize) {
        // Add subtle mountain ranges and terrain variation
        for _ in 0..<30 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let radius = CGFloat.random(in: 10...30)

            ctx.saveGState()
            ctx.setFillColor(UIColor(red: 0.2, green: 0.4, blue: 0.15, alpha: 0.3).cgColor)
            ctx.fillEllipse(in: CGRect(x: x - radius/2, y: y - radius/2, width: radius, height: radius))
            ctx.restoreGState()
        }
    }

    private func addClouds(ctx: CGContext, size: CGSize) {
        for _ in 0..<60 {
            let x = CGFloat.random(in: 0...size.width)
            let y = CGFloat.random(in: 0...size.height)
            let width = CGFloat.random(in: 40...120)
            let height = CGFloat.random(in: 25...70)
            let alpha = CGFloat.random(in: 0.15...0.45)

            ctx.saveGState()
            ctx.setFillColor(UIColor(white: 1.0, alpha: alpha).cgColor)
            ctx.fillEllipse(in: CGRect(x: x, y: y, width: width, height: height))
            ctx.restoreGState()
        }
    }

    private func addIceCaps(ctx: CGContext, size: CGSize) {
        // North pole
        ctx.saveGState()
        ctx.setFillColor(UIColor(white: 0.95, alpha: 0.9).cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.3, y: 0, width: size.width * 0.4, height: size.height * 0.12))
        ctx.restoreGState()

        // South pole
        ctx.saveGState()
        ctx.setFillColor(UIColor(white: 0.95, alpha: 0.95).cgColor)
        ctx.fillEllipse(in: CGRect(x: size.width * 0.25, y: size.height * 0.88, width: size.width * 0.5, height: size.height * 0.12))
        ctx.restoreGState()
    }

    // MARK: - Atmosphere Node Creation

    private func createAtmosphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 1.05)

        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 0.15)
        material.transparency = 0.15
        material.isDoubleSided = true

        sphere.materials = [material]

        let node = SCNNode(geometry: sphere)
        return node
    }

    // MARK: - Lighting Setup

    private func setupLighting(scene: SCNScene) {
        // Directional light (sun)
        let sunLight = SCNLight()
        sunLight.type = .directional
        sunLight.color = UIColor.white
        sunLight.intensity = 1000

        let sunNode = SCNNode()
        sunNode.light = sunLight
        sunNode.position = SCNVector3(x: 5, y: 5, z: 5)
        sunNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(sunNode)

        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor(white: 0.3, alpha: 1.0)
        ambientLight.intensity = 200

        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
    }

    // MARK: - Animations

    private func startIdleRotation(node: SCNNode) {
        // Very slow rotation: 360 degrees in 60 seconds (1 minute for full rotation)
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: 60)
        let forever = SCNAction.repeatForever(rotation)
        node.runAction(forever, forKey: "idleRotation")
    }

    private func performSpinAnimation(node: SCNNode?, completion: @escaping () -> Void) {
        guard let node = node else { return }

        // Remove idle rotation temporarily
        node.removeAction(forKey: "idleRotation")

        // Fast spin animation (720 degrees in 1.5 seconds)
        let spin = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 4, z: 0, duration: 1.5)
        spin.timingMode = .easeInEaseOut

        node.runAction(spin) {
            // Restart idle rotation
            self.startIdleRotation(node: node)
            completion()
        }
    }

}

// MARK: - Preview

#Preview {
    ZStack {
        Color.routaBackground.ignoresSafeArea()

        WorldGlobeView(isSpinning: .constant(false)) {
            print("Globe tapped!")
        }
    }
}
