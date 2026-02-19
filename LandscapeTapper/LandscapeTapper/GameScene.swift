import SpriteKit

class GameScene: SKScene {

    private let model = GameModel()
    private let scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let pptLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
    private var minusButton: SKShapeNode!
    private var plusButton: SKShapeNode!
    private var landscape: SKSpriteNode!

    override func didMove(to view: SKView) {
        backgroundColor = .black
        setupLandscape()
        setupScoreLabel()
        setupPointsPerTapUI()
    }

    // MARK: - Setup

    private func setupLandscape() {
        landscape = SKSpriteNode(imageNamed: "landscape")
        landscape.position = CGPoint(x: size.width / 2, y: size.height / 2)

        // Scale to fill the screen while maintaining aspect ratio
        let scaleX = size.width / landscape.size.width
        let scaleY = size.height / landscape.size.height
        let scale = max(scaleX, scaleY)
        landscape.setScale(scale)

        landscape.zPosition = 0
        addChild(landscape)
    }

    private func setupScoreLabel() {
        scoreLabel.fontSize = 48
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height - 100)
        scoreLabel.zPosition = 10
        scoreLabel.text = "\(model.score)"

        // Add a subtle shadow for readability over the landscape
        let shadow = SKLabelNode(fontNamed: "AvenirNext-Bold")
        shadow.fontSize = 48
        shadow.fontColor = SKColor(white: 0, alpha: 0.5)
        shadow.position = CGPoint(x: 2, y: -2)
        shadow.zPosition = -1
        shadow.name = "shadow"
        scoreLabel.addChild(shadow)

        addChild(scoreLabel)
    }

    private func setupPointsPerTapUI() {
        let buttonSize: CGFloat = 50
        let centerX = size.width / 2
        let yPos: CGFloat = 60

        // Minus button
        minusButton = SKShapeNode(circleOfRadius: buttonSize / 2)
        minusButton.name = "minusButton"
        minusButton.fillColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 0.85)
        minusButton.strokeColor = .white
        minusButton.lineWidth = 2
        minusButton.position = CGPoint(x: centerX - 70, y: yPos)
        minusButton.zPosition = 10
        let minusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        minusLabel.text = "-"
        minusLabel.fontSize = 32
        minusLabel.fontColor = .white
        minusLabel.verticalAlignmentMode = .center
        minusButton.addChild(minusLabel)
        addChild(minusButton)

        // Points-per-tap label
        pptLabel.fontSize = 28
        pptLabel.fontColor = .white
        pptLabel.position = CGPoint(x: centerX, y: yPos)
        pptLabel.zPosition = 10
        pptLabel.verticalAlignmentMode = .center
        pptLabel.horizontalAlignmentMode = .center
        pptLabel.text = "+\(model.pointsPerTap)/tap"
        addChild(pptLabel)

        // Plus button
        plusButton = SKShapeNode(circleOfRadius: buttonSize / 2)
        plusButton.name = "plusButton"
        plusButton.fillColor = SKColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 0.85)
        plusButton.strokeColor = .white
        plusButton.lineWidth = 2
        plusButton.position = CGPoint(x: centerX + 70, y: yPos)
        plusButton.zPosition = 10
        let plusLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        plusLabel.text = "+"
        plusLabel.fontSize = 32
        plusLabel.fontColor = .white
        plusLabel.verticalAlignmentMode = .center
        plusButton.addChild(plusLabel)
        addChild(plusButton)
    }

    private func updatePptLabel() {
        pptLabel.text = "+\(model.pointsPerTap)/tap"
    }

    // MARK: - Touch Handling

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if minusButton.contains(location) {
            model.decreasePointsPerTap()
            updatePptLabel()
            return
        }
        if plusButton.contains(location) {
            model.increasePointsPerTap()
            updatePptLabel()
            return
        }

        handleTap(at: location)
    }

    // MARK: - Feedback

    private func updateScoreLabel(_ score: Int) {
        scoreLabel.text = "\(score)"
        if let shadow = scoreLabel.childNode(withName: "shadow") as? SKLabelNode {
            shadow.text = "\(score)"
        }
    }

    private func animateScoreBump() {
        scoreLabel.removeAction(forKey: "bump")
        scoreLabel.setScale(1.0)
        let bump = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.08),
            SKAction.scale(to: 1.0, duration: 0.12)
        ])
        scoreLabel.run(bump, withKey: "bump")
    }

    private func spawnSparkle(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 80
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 0.6
        emitter.particleLifetimeRange = 0.2
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 40
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.5
        emitter.particleScale = 0.15
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.2

        // Create a small star/sparkle texture
        emitter.particleTexture = createSparkleTexture()

        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SKColor(red: 1, green: 1, blue: 0.6, alpha: 1),   // warm yellow
                SKColor(red: 1, green: 0.8, blue: 0.3, alpha: 1), // gold
                SKColor(red: 1, green: 1, blue: 1, alpha: 0)      // fade to white
            ],
            times: [0, 0.3, 1.0]
        )

        emitter.position = position
        emitter.zPosition = 5

        addChild(emitter)

        // Remove emitter after particles finish
        let wait = SKAction.wait(forDuration: 1.0)
        let remove = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([wait, remove]))
    }

    private func createSparkleTexture() -> SKTexture {
        let size = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let center = CGPoint(x: 16, y: 16)
            let path = UIBezierPath()

            // 4-pointed star
            let outerRadius: CGFloat = 14
            let innerRadius: CGFloat = 5
            for i in 0..<8 {
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let angle = CGFloat(i) * .pi / 4 - .pi / 2
                let point = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.close()

            UIColor.white.setFill()
            path.fill()
        }
        return SKTexture(image: image)
    }

    // MARK: - Test Harness (programmatic tap, same code path as real touch)

    func handleTap(at location: CGPoint) {
        let newScore = model.tap()
        updateScoreLabel(newScore)
        spawnSparkle(at: location)
        animateScoreBump()
    }
}

// MARK: - TestableGame Conformance (DEBUG only)

#if DEBUG
extension GameScene: TestableGame {
    var gameName: String { "LandscapeTapper" }

    func queryState() -> [String: Any] {
        return [
            "score": model.score,
            "pointsPerTap": model.pointsPerTap,
            "scene": "GameScene",
            "sceneSize": ["width": size.width, "height": size.height]
        ]
    }

    func performTap(at point: CGPoint) -> Bool {
        handleTap(at: point)
        return true
    }

    func performAction(_ name: String, parameters: [String: Any]) -> [String: Any] {
        switch name {
        case "tap":
            let x = parameters["x"] as? Double ?? Double(size.width / 2)
            let y = parameters["y"] as? Double ?? Double(size.height / 2)
            handleTap(at: CGPoint(x: x, y: y))
            return ["success": true]
        case "increase_ppt":
            let newVal = model.increasePointsPerTap()
            updatePptLabel()
            return ["success": true, "pointsPerTap": newVal]
        case "decrease_ppt":
            let newVal = model.decreasePointsPerTap()
            updatePptLabel()
            return ["success": true, "pointsPerTap": newVal]
        case "reset":
            model.reset()
            updateScoreLabel(model.score)
            updatePptLabel()
            return ["success": true]
        default:
            return ["error": "unknown action: \(name)"]
        }
    }

    var availableActions: [[String: Any]] {
        return [
            [
                "name": "tap",
                "description": "Tap at a point to increment score by pointsPerTap and spawn sparkle",
                "parameters": [
                    ["name": "x", "type": "number", "optional": true, "description": "X coordinate (defaults to center)"],
                    ["name": "y", "type": "number", "optional": true, "description": "Y coordinate (defaults to center)"]
                ]
            ],
            [
                "name": "increase_ppt",
                "description": "Increase points per tap by 1",
                "parameters": [] as [[String: Any]]
            ],
            [
                "name": "decrease_ppt",
                "description": "Decrease points per tap by 1 (minimum 1)",
                "parameters": [] as [[String: Any]]
            ],
            [
                "name": "reset",
                "description": "Reset score and points per tap to defaults",
                "parameters": [] as [[String: Any]]
            ]
        ]
    }
}
#endif
