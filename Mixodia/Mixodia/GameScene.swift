import SpriteKit

class GameScene: SKScene {

    let model = GameModel()

    // UI Layers
    private var background: SKSpriteNode!
    private var pedestalNode: SKNode!
    private var headSlot: SKNode!
    private var bodySlot: SKNode!
    private var mixButton: SKNode!
    private var creatureShelf: SKNode!
    private var essenceLabel: SKLabelNode!
    private var mixodexButton: SKNode!
    private var progressLabel: SKLabelNode!

    // Selection highlights
    private var headHighlight: SKShapeNode!
    private var bodyHighlight: SKShapeNode!

    // Creature shelf
    private var shelfCreatureNodes: [SKNode] = []
    private let shelfItemSize: CGFloat = 70
    private let shelfSpacing: CGFloat = 10
    private var shelfScrollOffset: CGFloat = 0
    private var shelfTouchStart: CGPoint?
    private var shelfScrollStart: CGFloat = 0
    private var isDraggingShelf = false

    // Mixodex overlay
    private var mixodexOverlay: SKNode?

    // Detail card overlay
    private var detailOverlay: SKNode?

    // Animation state
    private var isMixing = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.12, green: 0.08, blue: 0.22, alpha: 1.0)
        model.load()
        setupBackground()
        setupEssenceUI()
        setupMixodexButton()
        setupPedestal()
        setupCreatureShelf()
        updateUI()
    }

    // MARK: - Setup

    private func setupBackground() {
        background = SKSpriteNode(imageNamed: "lab_background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        let scaleX = size.width / max(background.size.width, 1)
        let scaleY = size.height / max(background.size.height, 1)
        background.setScale(max(scaleX, scaleY))
        background.zPosition = -10
        addChild(background)
    }

    private func setupEssenceUI() {
        // Essence icon + label at top left
        let essenceIcon = SKSpriteNode(imageNamed: "essence_icon")
        essenceIcon.size = CGSize(width: 28, height: 28)
        essenceIcon.position = CGPoint(x: 30, y: size.height - 55)
        essenceIcon.zPosition = 10
        addChild(essenceIcon)

        essenceLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        essenceLabel.fontSize = 22
        essenceLabel.fontColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        essenceLabel.horizontalAlignmentMode = .left
        essenceLabel.verticalAlignmentMode = .center
        essenceLabel.position = CGPoint(x: 50, y: size.height - 55)
        essenceLabel.zPosition = 10
        addChild(essenceLabel)

        // Progress label
        progressLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        progressLabel.fontSize = 14
        progressLabel.fontColor = SKColor(white: 1, alpha: 0.7)
        progressLabel.horizontalAlignmentMode = .left
        progressLabel.verticalAlignmentMode = .center
        progressLabel.position = CGPoint(x: 50, y: size.height - 78)
        progressLabel.zPosition = 10
        addChild(progressLabel)
    }

    private func setupMixodexButton() {
        let container = SKNode()
        container.name = "mixodexButton"
        container.position = CGPoint(x: size.width - 50, y: size.height - 60)
        container.zPosition = 10

        let bg = SKShapeNode(rectOf: CGSize(width: 70, height: 36), cornerRadius: 18)
        bg.fillColor = SKColor(red: 0.5, green: 0.2, blue: 0.7, alpha: 0.9)
        bg.strokeColor = SKColor(red: 0.8, green: 0.6, blue: 1, alpha: 1)
        bg.lineWidth = 2
        container.addChild(bg)

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Mixodex"
        label.fontSize = 12
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        container.addChild(label)

        addChild(container)
        mixodexButton = container
    }

    private func setupPedestal() {
        pedestalNode = SKNode()
        pedestalNode.position = CGPoint(x: size.width / 2, y: size.height * 0.52)
        pedestalNode.zPosition = 5
        addChild(pedestalNode)

        // Pedestal base image
        let pedestalBg = SKSpriteNode(imageNamed: "pedestal")
        pedestalBg.size = CGSize(width: 280, height: 280)
        pedestalBg.position = .zero
        pedestalBg.zPosition = 0
        pedestalNode.addChild(pedestalBg)

        // Head slot (left)
        headSlot = createSlot(name: "headSlot", label: "HEAD", color: SKColor(red: 1, green: 0.4, blue: 0.3, alpha: 0.3))
        headSlot.position = CGPoint(x: -75, y: 30)
        pedestalNode.addChild(headSlot)

        // Body slot (right)
        bodySlot = createSlot(name: "bodySlot", label: "BODY", color: SKColor(red: 0.3, green: 0.5, blue: 1, alpha: 0.3))
        bodySlot.position = CGPoint(x: 75, y: 30)
        pedestalNode.addChild(bodySlot)

        // Mix button
        let mixBtn = SKNode()
        mixBtn.name = "mixButton"
        mixBtn.position = CGPoint(x: 0, y: -80)

        let mixBg = SKShapeNode(rectOf: CGSize(width: 120, height: 44), cornerRadius: 22)
        mixBg.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1)
        mixBg.strokeColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
        mixBg.lineWidth = 3
        mixBg.name = "mixButtonBg"
        mixBtn.addChild(mixBg)

        let mixLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        mixLabel.text = "MIX!"
        mixLabel.fontSize = 20
        mixLabel.fontColor = SKColor(red: 0.3, green: 0.15, blue: 0, alpha: 1)
        mixLabel.verticalAlignmentMode = .center
        mixLabel.name = "mixButtonLabel"
        mixBtn.addChild(mixLabel)

        pedestalNode.addChild(mixBtn)
        mixButton = mixBtn
    }

    private func createSlot(name: String, label: String, color: SKColor) -> SKNode {
        let slot = SKNode()
        slot.name = name

        let circle = SKShapeNode(circleOfRadius: 45)
        circle.fillColor = color
        circle.strokeColor = SKColor(white: 1, alpha: 0.5)
        circle.lineWidth = 2
        circle.name = "\(name)Circle"
        slot.addChild(circle)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        lbl.text = label
        lbl.fontSize = 11
        lbl.fontColor = SKColor(white: 1, alpha: 0.6)
        lbl.verticalAlignmentMode = .center
        lbl.position = CGPoint(x: 0, y: -55)
        lbl.name = "\(name)Label"
        slot.addChild(lbl)

        return slot
    }

    private func setupCreatureShelf() {
        creatureShelf = SKNode()
        creatureShelf.position = CGPoint(x: 0, y: 100)
        creatureShelf.zPosition = 8

        // Shelf background
        let shelfBg = SKShapeNode(rectOf: CGSize(width: size.width, height: 100), cornerRadius: 0)
        shelfBg.fillColor = SKColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 0.85)
        shelfBg.strokeColor = SKColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 0.5)
        shelfBg.lineWidth = 1
        shelfBg.position = CGPoint(x: size.width / 2, y: 0)
        shelfBg.name = "shelfBg"
        creatureShelf.addChild(shelfBg)

        // Label above shelf
        let shelfLabel = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        shelfLabel.text = "YOUR CREATURES"
        shelfLabel.fontSize = 10
        shelfLabel.fontColor = SKColor(white: 1, alpha: 0.5)
        shelfLabel.position = CGPoint(x: size.width / 2, y: 42)
        shelfLabel.name = "shelfTitle"
        creatureShelf.addChild(shelfLabel)

        addChild(creatureShelf)
        rebuildShelf()
    }

    private func rebuildShelf() {
        // Remove old creature nodes
        for node in shelfCreatureNodes {
            node.removeFromParent()
        }
        shelfCreatureNodes.removeAll()

        let creatures = model.ownedCreatures()
        let totalWidth = CGFloat(creatures.count) * (shelfItemSize + shelfSpacing)
        let startX = max(size.width / 2 - totalWidth / 2 + shelfItemSize / 2,
                         shelfItemSize / 2 + shelfSpacing)

        for (index, creature) in creatures.enumerated() {
            let node = createCreatureShelfNode(creature, index: index)
            let x = startX + CGFloat(index) * (shelfItemSize + shelfSpacing) + shelfScrollOffset
            node.position = CGPoint(x: x, y: 0)
            creatureShelf.addChild(node)
            shelfCreatureNodes.append(node)
        }
    }

    private func createCreatureShelfNode(_ creature: Creature, index: Int) -> SKNode {
        let container = SKNode()
        container.name = "shelfCreature_\(creature.id)"
        container.zPosition = 1

        // Background circle
        let bg = SKShapeNode(circleOfRadius: shelfItemSize / 2 - 2)
        bg.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.25, alpha: 0.9)
        bg.strokeColor = elementColor(creature.headElement).withAlphaComponent(0.7)
        bg.lineWidth = 2
        container.addChild(bg)

        // Creature sprite
        let sprite = SKSpriteNode(imageNamed: creature.spriteName)
        sprite.size = CGSize(width: shelfItemSize - 16, height: shelfItemSize - 16)
        sprite.zPosition = 1
        container.addChild(sprite)

        // Element indicator dots
        let headDot = SKShapeNode(circleOfRadius: 5)
        headDot.fillColor = elementColor(creature.headElement)
        headDot.strokeColor = .clear
        headDot.position = CGPoint(x: -10, y: -(shelfItemSize / 2) + 2)
        headDot.zPosition = 2
        container.addChild(headDot)

        let bodyDot = SKShapeNode(circleOfRadius: 5)
        bodyDot.fillColor = elementColor(creature.bodyElement)
        bodyDot.strokeColor = .clear
        bodyDot.position = CGPoint(x: 10, y: -(shelfItemSize / 2) + 2)
        bodyDot.zPosition = 2
        container.addChild(bodyDot)

        return container
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Check if touch is in shelf area
        let shelfLocalY = location.y - creatureShelf.position.y
        if abs(shelfLocalY) < 50 {
            shelfTouchStart = location
            shelfScrollStart = shelfScrollOffset
            isDraggingShelf = false
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, shelfTouchStart != nil else { return }
        let location = touch.location(in: self)
        let dx = location.x - shelfTouchStart!.x
        if abs(dx) > 5 {
            isDraggingShelf = true
            shelfScrollOffset = shelfScrollStart + dx
            updateShelfPositions()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if isDraggingShelf {
            isDraggingShelf = false
            shelfTouchStart = nil
            return
        }
        shelfTouchStart = nil

        handleTap(at: location)
    }

    func handleTap(at location: CGPoint) {
        guard !isMixing else { return }

        // Dismiss detail overlay if visible
        if detailOverlay != nil {
            dismissDetailCard()
            return
        }

        // Dismiss mixodex if visible
        if let overlay = mixodexOverlay {
            // Check if tap is on a mixodex creature cell
            let overlayLoc = convert(location, to: overlay)
            let tappedNode = overlay.atPoint(overlayLoc)
            if let name = tappedNode.name ?? tappedNode.parent?.name ?? tappedNode.parent?.parent?.name,
               name.hasPrefix("mixodexCell_") {
                let parts = name.replacingOccurrences(of: "mixodexCell_", with: "").components(separatedBy: "_")
                if parts.count == 2, let creature = model.creatureFor(head: elementFromString(parts[0]), body: elementFromString(parts[1])) {
                    showDetailCard(for: creature)
                }
                return
            }
            dismissMixodex()
            return
        }

        // Check Mixodex button
        if let btn = mixodexButton, nodeContains(btn, point: location, radius: 40) {
            showMixodex()
            return
        }

        // Check Mix button
        if let btn = mixButton {
            let btnWorld = pedestalNode.convert(btn.position, to: self)
            if location.distance(to: btnWorld) < 60 && model.canMix() {
                performMixAnimation()
                return
            }
        }

        // Check head slot tap (to clear)
        if model.headSelection != nil {
            let headWorld = pedestalNode.convert(headSlot.position, to: self)
            if location.distance(to: headWorld) < 50 {
                model.selectHead(model.headSelection!) // re-tap doesn't change, but we could clear
                clearSlotVisual(headSlot)
                model.clearSelection()
                updateSlotVisuals()
                return
            }
        }

        // Check body slot tap (to clear)
        if model.bodySelection != nil {
            let bodyWorld = pedestalNode.convert(bodySlot.position, to: self)
            if location.distance(to: bodyWorld) < 50 {
                clearSlotVisual(bodySlot)
                model.clearSelection()
                updateSlotVisuals()
                return
            }
        }

        // Check creature shelf taps
        let shelfLocal = convert(location, to: creatureShelf)
        for node in shelfCreatureNodes {
            if shelfLocal.distance(to: node.position) < shelfItemSize / 2 {
                if let name = node.name, name.hasPrefix("shelfCreature_") {
                    let creatureID = String(name.dropFirst("shelfCreature_".count))
                    if let creature = CreatureDatabase.all[creatureID] {
                        selectCreatureForMixing(creature)
                    }
                }
                return
            }
        }
    }

    // MARK: - Creature Selection

    private func selectCreatureForMixing(_ creature: Creature) {
        if model.headSelection == nil {
            model.selectHead(creature)
            placeCreatureInSlot(creature, slot: headSlot)
            animateSlotFill(headSlot)
        } else if model.bodySelection == nil {
            model.selectBody(creature)
            placeCreatureInSlot(creature, slot: bodySlot)
            animateSlotFill(bodySlot)
        } else {
            // Both filled — replace head, shift body, add new as body
            model.clearSelection()
            clearSlotVisual(headSlot)
            clearSlotVisual(bodySlot)
            model.selectHead(creature)
            placeCreatureInSlot(creature, slot: headSlot)
            animateSlotFill(headSlot)
        }
        updateMixButton()
    }

    private func placeCreatureInSlot(_ creature: Creature, slot: SKNode) {
        // Remove old sprite in slot
        slot.childNode(withName: "slotCreature")?.removeFromParent()

        let sprite = SKSpriteNode(imageNamed: creature.spriteName)
        sprite.size = CGSize(width: 60, height: 60)
        sprite.name = "slotCreature"
        sprite.zPosition = 2
        slot.addChild(sprite)
    }

    private func clearSlotVisual(_ slot: SKNode) {
        slot.childNode(withName: "slotCreature")?.removeFromParent()
    }

    private func updateSlotVisuals() {
        if model.headSelection == nil { clearSlotVisual(headSlot) }
        if model.bodySelection == nil { clearSlotVisual(bodySlot) }
        updateMixButton()
    }

    private func animateSlotFill(_ slot: SKNode) {
        if let sprite = slot.childNode(withName: "slotCreature") {
            sprite.setScale(0.3)
            sprite.alpha = 0
            sprite.run(SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.25),
                SKAction.fadeIn(withDuration: 0.2)
            ]))
        }

        // Pulse the circle
        if let circle = slot.children.first(where: { $0.name?.contains("Circle") ?? false }) as? SKShapeNode {
            circle.run(SKAction.sequence([
                SKAction.customAction(withDuration: 0.15) { node, t in
                    (node as? SKShapeNode)?.strokeColor = SKColor(white: 1, alpha: 1)
                },
                SKAction.customAction(withDuration: 0.2) { node, t in
                    (node as? SKShapeNode)?.strokeColor = SKColor(white: 1, alpha: 0.5)
                }
            ]))
        }
    }

    private func updateMixButton() {
        if let bg = mixButton.childNode(withName: "mixButtonBg") as? SKShapeNode {
            if model.canMix() {
                bg.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.1, alpha: 1)
                bg.alpha = 1.0
            } else {
                bg.fillColor = SKColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1)
                bg.alpha = 0.5
            }
        }
    }

    // MARK: - Mix Animation

    private func performMixAnimation() {
        guard model.canMix() else { return }
        isMixing = true

        // Move both slot creatures toward center
        let headSprite = headSlot.childNode(withName: "slotCreature")
        let bodySprite = bodySlot.childNode(withName: "slotCreature")

        // Swirl particles
        spawnMixParticles(at: pedestalNode.position)

        let moveToCenter = SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.group([
                SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.4),
                SKAction.scale(to: 0.4, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ])
        ])

        // Body sprite moves to head's local center
        let bodyMoveToCenter = SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.group([
                SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.4),
                SKAction.scale(to: 0.4, duration: 0.4),
                SKAction.fadeOut(withDuration: 0.4)
            ])
        ])

        headSprite?.run(moveToCenter)
        bodySprite?.run(bodyMoveToCenter)

        // After merge, perform the mix and reveal result
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.8),
            SKAction.run { [weak self] in
                self?.flashEffect()
            },
            SKAction.wait(forDuration: 0.3),
            SKAction.run { [weak self] in
                self?.revealMixResult()
            }
        ]))
    }

    private func spawnMixParticles(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 60
        emitter.numParticlesToEmit = 40
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.3
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 50
        emitter.particleSpeedRange = 30
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.2
        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.15
        emitter.particleTexture = createSparkleTexture()
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SKColor(red: 1, green: 0.9, blue: 0.4, alpha: 1),
                SKColor(red: 0.8, green: 0.5, blue: 1, alpha: 1),
                SKColor(red: 1, green: 1, blue: 1, alpha: 0)
            ],
            times: [0, 0.5, 1.0]
        )
        emitter.position = position
        emitter.zPosition = 15
        addChild(emitter)
        emitter.run(SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.removeFromParent()]))
    }

    private func flashEffect() {
        let flash = SKShapeNode(rectOf: size)
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.alpha = 0
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        addChild(flash)

        flash.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.8, duration: 0.1),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    private func revealMixResult() {
        let result = model.performMix()

        clearSlotVisual(headSlot)
        clearSlotVisual(bodySlot)

        switch result {
        case .newDiscovery(let creature):
            showResultCreature(creature, isNew: true)
        case .duplicate(let creature):
            showResultCreature(creature, isNew: false)
        case .notEnoughEssence:
            showNotEnoughEssence()
        }

        model.save()
        rebuildShelf()
        updateUI()
        isMixing = false
    }

    private func showResultCreature(_ creature: Creature, isNew: Bool) {
        // Large creature reveal at pedestal center
        let revealNode = SKNode()
        revealNode.position = pedestalNode.position
        revealNode.zPosition = 20
        revealNode.name = "revealNode"

        // Glow behind creature
        let glow = SKShapeNode(circleOfRadius: 60)
        glow.fillColor = isNew ? SKColor(red: 1, green: 0.9, blue: 0.3, alpha: 0.3) : SKColor(white: 1, alpha: 0.15)
        glow.strokeColor = .clear
        glow.setScale(0.1)
        revealNode.addChild(glow)

        // Creature sprite
        let sprite = SKSpriteNode(imageNamed: creature.spriteName)
        sprite.size = CGSize(width: 100, height: 100)
        sprite.setScale(0.1)
        sprite.zPosition = 1
        revealNode.addChild(sprite)

        // Name label
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = creature.name
        nameLabel.fontSize = 20
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: 0, y: -70)
        nameLabel.alpha = 0
        nameLabel.zPosition = 1
        revealNode.addChild(nameLabel)

        // "NEW!" badge
        if isNew {
            let newBadge = SKLabelNode(fontNamed: "AvenirNext-Bold")
            newBadge.text = "NEW DISCOVERY!"
            newBadge.fontSize = 16
            newBadge.fontColor = SKColor(red: 1, green: 0.85, blue: 0.2, alpha: 1)
            newBadge.position = CGPoint(x: 0, y: 68)
            newBadge.alpha = 0
            newBadge.zPosition = 1
            newBadge.name = "newBadge"
            revealNode.addChild(newBadge)
        }

        addChild(revealNode)

        // Animate reveal
        let reveal = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.4),
            ]),
        ])
        sprite.run(reveal)
        glow.run(SKAction.scale(to: 1.0, duration: 0.5))
        nameLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        revealNode.childNode(withName: "newBadge")?.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.repeatForever(SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ]))
        ]))

        // Discovery particles for new creatures
        if isNew {
            spawnDiscoveryParticles(at: pedestalNode.position)
        }

        // Dismiss after a moment
        revealNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.fadeOut(withDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }

    private func spawnDiscoveryParticles(at position: CGPoint) {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 60
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.4
        emitter.emissionAngleRange = .pi * 2
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 60
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.0
        emitter.particleScale = 0.15
        emitter.particleScaleRange = 0.08
        emitter.particleTexture = createSparkleTexture()
        emitter.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [
                SKColor(red: 1, green: 1, blue: 0.5, alpha: 1),
                SKColor(red: 1, green: 0.6, blue: 0.2, alpha: 1),
                SKColor(red: 1, green: 1, blue: 1, alpha: 0)
            ],
            times: [0, 0.4, 1.0]
        )
        emitter.position = position
        emitter.zPosition = 25
        addChild(emitter)
        emitter.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.removeFromParent()]))
    }

    private func showNotEnoughEssence() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = "Not enough Essence!"
        label.fontSize = 18
        label.fontColor = SKColor(red: 1, green: 0.3, blue: 0.3, alpha: 1)
        label.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        label.zPosition = 30
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.2),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Mixodex

    private func showMixodex() {
        guard mixodexOverlay == nil else { return }

        let overlay = SKNode()
        overlay.name = "mixodexOverlay"
        overlay.zPosition = 40

        // Dim background
        let dim = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: size.height * 2))
        dim.fillColor = SKColor(white: 0, alpha: 0.7)
        dim.strokeColor = .clear
        dim.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.addChild(dim)

        // Panel
        let panelW: CGFloat = size.width - 40
        let panelH: CGFloat = 420
        let panelCenter = CGPoint(x: size.width / 2, y: size.height / 2 + 20)

        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 16)
        panel.fillColor = SKColor(red: 0.12, green: 0.08, blue: 0.22, alpha: 0.95)
        panel.strokeColor = SKColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 1)
        panel.lineWidth = 2
        panel.position = panelCenter
        overlay.addChild(panel)

        // Title
        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = "MIXODEX"
        title.fontSize = 24
        title.fontColor = SKColor(red: 0.9, green: 0.75, blue: 1, alpha: 1)
        title.position = CGPoint(x: panelCenter.x, y: panelCenter.y + panelH / 2 - 35)
        overlay.addChild(title)

        // Progress
        let prog = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        prog.text = "\(model.discoveredCount)/\(model.totalCreatures) Discovered"
        prog.fontSize = 14
        prog.fontColor = SKColor(white: 1, alpha: 0.7)
        prog.position = CGPoint(x: panelCenter.x, y: panelCenter.y + panelH / 2 - 55)
        overlay.addChild(prog)

        // Progress bar
        let barW: CGFloat = panelW - 60
        let barBg = SKShapeNode(rectOf: CGSize(width: barW, height: 8), cornerRadius: 4)
        barBg.fillColor = SKColor(white: 0.2, alpha: 1)
        barBg.strokeColor = .clear
        barBg.position = CGPoint(x: panelCenter.x, y: panelCenter.y + panelH / 2 - 72)
        overlay.addChild(barBg)

        let fillW = barW * CGFloat(model.mixodexProgress)
        if fillW > 1 {
            let barFill = SKShapeNode(rectOf: CGSize(width: fillW, height: 8), cornerRadius: 4)
            barFill.fillColor = SKColor(red: 1, green: 0.85, blue: 0.3, alpha: 1)
            barFill.strokeColor = .clear
            barFill.position = CGPoint(x: panelCenter.x - (barW - fillW) / 2, y: panelCenter.y + panelH / 2 - 72)
            overlay.addChild(barFill)
        }

        // Grid: 4x4 with headers
        let cellSize: CGFloat = 65
        let gridSpacing: CGFloat = 6
        let elements: [Element] = [.fire, .water, .earth, .air]
        let gridOriginX = panelCenter.x - (4 * cellSize + 3 * gridSpacing) / 2 + 20
        let gridOriginY = panelCenter.y + panelH / 2 - 115

        // Column headers (body element)
        for (col, elem) in elements.enumerated() {
            let headerIcon = SKSpriteNode(imageNamed: "element_\(elem.rawValue)")
            headerIcon.size = CGSize(width: 20, height: 20)
            headerIcon.position = CGPoint(
                x: gridOriginX + CGFloat(col) * (cellSize + gridSpacing) + cellSize / 2,
                y: gridOriginY + 15
            )
            overlay.addChild(headerIcon)
        }

        // Row headers (head element)
        for (row, elem) in elements.enumerated() {
            let headerIcon = SKSpriteNode(imageNamed: "element_\(elem.rawValue)")
            headerIcon.size = CGSize(width: 20, height: 20)
            headerIcon.position = CGPoint(
                x: gridOriginX - 25,
                y: gridOriginY - CGFloat(row) * (cellSize + gridSpacing) - cellSize / 2
            )
            overlay.addChild(headerIcon)
        }

        // Cells
        for (row, headElem) in elements.enumerated() {
            for (col, bodyElem) in elements.enumerated() {
                let cellX = gridOriginX + CGFloat(col) * (cellSize + gridSpacing) + cellSize / 2
                let cellY = gridOriginY - CGFloat(row) * (cellSize + gridSpacing) - cellSize / 2

                let cell = SKNode()
                cell.position = CGPoint(x: cellX, y: cellY)
                cell.name = "mixodexCell_\(headElem.rawValue)_\(bodyElem.rawValue)"

                let bg = SKShapeNode(rectOf: CGSize(width: cellSize, height: cellSize), cornerRadius: 8)
                bg.name = cell.name

                if model.isDiscovered(head: headElem, body: bodyElem) {
                    bg.fillColor = SKColor(red: 0.2, green: 0.15, blue: 0.35, alpha: 1)
                    bg.strokeColor = elementColor(headElem).withAlphaComponent(0.5)

                    let creature = CreatureDatabase.creature(head: headElem, body: bodyElem)
                    let sprite = SKSpriteNode(imageNamed: creature.spriteName)
                    sprite.size = CGSize(width: cellSize - 12, height: cellSize - 12)
                    sprite.zPosition = 1
                    sprite.name = cell.name
                    cell.addChild(sprite)
                } else {
                    bg.fillColor = SKColor(white: 0.1, alpha: 0.8)
                    bg.strokeColor = SKColor(white: 0.3, alpha: 0.5)

                    let question = SKLabelNode(fontNamed: "AvenirNext-Bold")
                    question.text = "?"
                    question.fontSize = 28
                    question.fontColor = SKColor(white: 0.4, alpha: 1)
                    question.verticalAlignmentMode = .center
                    question.zPosition = 1
                    cell.addChild(question)
                }

                bg.lineWidth = 1.5
                cell.addChild(bg)
                overlay.addChild(cell)
            }
        }

        addChild(overlay)
        mixodexOverlay = overlay

        // Fade in
        overlay.alpha = 0
        overlay.run(SKAction.fadeIn(withDuration: 0.2))
    }

    private func dismissMixodex() {
        mixodexOverlay?.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.15),
            SKAction.removeFromParent()
        ]))
        mixodexOverlay = nil
    }

    // MARK: - Detail Card

    private func showDetailCard(for creature: Creature) {
        dismissDetailCard()

        let overlay = SKNode()
        overlay.name = "detailOverlay"
        overlay.zPosition = 60

        let cardW: CGFloat = 260
        let cardH: CGFloat = 320
        let cardCenter = CGPoint(x: size.width / 2, y: size.height / 2 + 40)

        // Card background
        let card = SKShapeNode(rectOf: CGSize(width: cardW, height: cardH), cornerRadius: 16)
        card.fillColor = SKColor(red: 0.15, green: 0.1, blue: 0.28, alpha: 0.97)
        card.strokeColor = elementColor(creature.headElement)
        card.lineWidth = 3
        card.position = cardCenter
        overlay.addChild(card)

        // Creature sprite (large)
        let sprite = SKSpriteNode(imageNamed: creature.spriteName)
        sprite.size = CGSize(width: 120, height: 120)
        sprite.position = CGPoint(x: cardCenter.x, y: cardCenter.y + 70)
        sprite.zPosition = 1
        overlay.addChild(sprite)

        // Name
        let nameLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        nameLabel.text = creature.name
        nameLabel.fontSize = 22
        nameLabel.fontColor = .white
        nameLabel.position = CGPoint(x: cardCenter.x, y: cardCenter.y - 10)
        nameLabel.zPosition = 1
        overlay.addChild(nameLabel)

        // Element badges
        let headBadge = createElementBadge(creature.headElement, label: "HEAD")
        headBadge.position = CGPoint(x: cardCenter.x - 50, y: cardCenter.y - 45)
        overlay.addChild(headBadge)

        let bodyBadge = createElementBadge(creature.bodyElement, label: "BODY")
        bodyBadge.position = CGPoint(x: cardCenter.x + 50, y: cardCenter.y - 45)
        overlay.addChild(bodyBadge)

        // Description (wrapped manually)
        let desc = creature.description
        let maxCharsPerLine = 28
        let words = desc.split(separator: " ")
        var lines: [String] = []
        var currentLine = ""
        for word in words {
            if currentLine.isEmpty {
                currentLine = String(word)
            } else if currentLine.count + 1 + word.count <= maxCharsPerLine {
                currentLine += " \(word)"
            } else {
                lines.append(currentLine)
                currentLine = String(word)
            }
        }
        if !currentLine.isEmpty { lines.append(currentLine) }

        for (i, line) in lines.enumerated() {
            let lineLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
            lineLabel.text = line
            lineLabel.fontSize = 12
            lineLabel.fontColor = SKColor(white: 0.8, alpha: 1)
            lineLabel.position = CGPoint(x: cardCenter.x, y: cardCenter.y - 80 - CGFloat(i) * 16)
            lineLabel.zPosition = 1
            overlay.addChild(lineLabel)
        }

        addChild(overlay)
        detailOverlay = overlay

        overlay.alpha = 0
        overlay.setScale(0.8)
        overlay.run(SKAction.group([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ]))
    }

    private func dismissDetailCard() {
        detailOverlay?.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.15),
                SKAction.scale(to: 0.9, duration: 0.15)
            ]),
            SKAction.removeFromParent()
        ]))
        detailOverlay = nil
    }

    private func createElementBadge(_ element: Element, label: String) -> SKNode {
        let node = SKNode()
        node.zPosition = 1

        let bg = SKShapeNode(rectOf: CGSize(width: 70, height: 24), cornerRadius: 12)
        bg.fillColor = elementColor(element).withAlphaComponent(0.3)
        bg.strokeColor = elementColor(element)
        bg.lineWidth = 1
        node.addChild(bg)

        let icon = SKSpriteNode(imageNamed: "element_\(element.rawValue)")
        icon.size = CGSize(width: 14, height: 14)
        icon.position = CGPoint(x: -20, y: 0)
        node.addChild(icon)

        let lbl = SKLabelNode(fontNamed: "AvenirNext-DemiBold")
        lbl.text = label
        lbl.fontSize = 9
        lbl.fontColor = SKColor(white: 1, alpha: 0.7)
        lbl.verticalAlignmentMode = .center
        lbl.position = CGPoint(x: 8, y: 0)
        node.addChild(lbl)

        return node
    }

    // MARK: - UI Updates

    private func updateUI() {
        essenceLabel.text = "\(model.essence)"
        progressLabel.text = "\(model.discoveredCount)/\(model.totalCreatures) discovered"
        updateMixButton()
    }

    private func updateShelfPositions() {
        let creatures = model.ownedCreatures()
        let totalWidth = CGFloat(creatures.count) * (shelfItemSize + shelfSpacing)
        let startX = max(size.width / 2 - totalWidth / 2 + shelfItemSize / 2,
                         shelfItemSize / 2 + shelfSpacing)

        for (index, node) in shelfCreatureNodes.enumerated() {
            let x = startX + CGFloat(index) * (shelfItemSize + shelfSpacing) + shelfScrollOffset
            node.position = CGPoint(x: x, y: node.position.y)
        }
    }

    // MARK: - Helpers

    private func elementColor(_ element: Element) -> SKColor {
        switch element {
        case .fire:  return SKColor(red: 1, green: 0.42, blue: 0.21, alpha: 1)
        case .water: return SKColor(red: 0.24, green: 0.65, blue: 0.85, alpha: 1)
        case .earth: return SKColor(red: 0.49, green: 0.7, blue: 0.26, alpha: 1)
        case .air:   return SKColor(red: 0.7, green: 0.62, blue: 0.86, alpha: 1)
        }
    }

    private func elementFromString(_ str: String) -> Element {
        return Element(rawValue: str) ?? .fire
    }

    private func createSparkleTexture() -> SKTexture {
        let texSize = CGSize(width: 32, height: 32)
        let renderer = UIGraphicsImageRenderer(size: texSize)
        let image = renderer.image { _ in
            let center = CGPoint(x: 16, y: 16)
            let path = UIBezierPath()
            let outerRadius: CGFloat = 14
            let innerRadius: CGFloat = 5
            for i in 0..<8 {
                let radius = i % 2 == 0 ? outerRadius : innerRadius
                let angle = CGFloat(i) * .pi / 4 - .pi / 2
                let point = CGPoint(
                    x: center.x + radius * cos(angle),
                    y: center.y + radius * sin(angle)
                )
                if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
            }
            path.close()
            UIColor.white.setFill()
            path.fill()
        }
        return SKTexture(image: image)
    }

    private func nodeContains(_ node: SKNode, point: CGPoint, radius: CGFloat) -> Bool {
        let nodePos = node.parent == self ? node.position : convert(node.position, from: node.parent!)
        return point.distance(to: nodePos) < radius
    }
}

// MARK: - CGPoint Distance

extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        return sqrt(pow(x - other.x, 2) + pow(y - other.y, 2))
    }
}

// MARK: - SKColor Helpers

extension SKColor {
    func withAlphaComponent(_ alpha: CGFloat) -> SKColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return SKColor(red: r, green: g, blue: b, alpha: alpha)
    }
}

// MARK: - TestableGame Conformance (DEBUG only)

#if DEBUG
extension GameScene: TestableGame {
    var gameName: String { "Mixodia" }

    func queryState() -> [String: Any] {
        var state = model.stateDict()
        state["scene"] = "GameScene"
        state["sceneSize"] = ["width": size.width, "height": size.height]
        state["isMixing"] = isMixing
        state["discoveredIDs"] = Array(model.discoveredIDs)
        state["ownedCreatureIDs"] = model.ownedCreatureIDs
        return state
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

        case "select_creature":
            guard let creatureID = parameters["creature_id"] as? String,
                  let creature = CreatureDatabase.all[creatureID] else {
                return ["error": "invalid creature_id"]
            }
            // Set model state directly to avoid UI/touch interference
            if model.headSelection == nil {
                model.selectHead(creature)
            } else if model.bodySelection == nil {
                model.selectBody(creature)
            } else {
                model.clearSelection()
                model.selectHead(creature)
            }
            updateMixButton()
            return ["success": true, "headSelection": model.headSelection?.id ?? NSNull(), "bodySelection": model.bodySelection?.id ?? NSNull()]

        case "mix":
            guard model.canMix() else {
                return ["error": "cannot mix - need head + body selected and enough essence"]
            }
            let result = model.performMix()
            clearSlotVisual(headSlot)
            clearSlotVisual(bodySlot)
            model.save()
            rebuildShelf()
            updateUI()
            switch result {
            case .newDiscovery(let c):
                return ["success": true, "result": "new_discovery", "creature": c.id, "name": c.name]
            case .duplicate(let c):
                return ["success": true, "result": "duplicate", "creature": c.id, "name": c.name]
            case .notEnoughEssence:
                return ["success": false, "error": "not_enough_essence"]
            }

        case "clear_selection":
            model.clearSelection()
            clearSlotVisual(headSlot)
            clearSlotVisual(bodySlot)
            updateSlotVisuals()
            return ["success": true]

        case "open_mixodex":
            showMixodex()
            return ["success": true]

        case "close_mixodex":
            dismissMixodex()
            return ["success": true]

        case "reset":
            model.reset()
            rebuildShelf()
            updateUI()
            return ["success": true]

        default:
            return ["error": "unknown action: \(name)"]
        }
    }

    var availableActions: [[String: Any]] {
        return [
            [
                "name": "tap",
                "description": "Tap at a point in the scene",
                "parameters": [
                    ["name": "x", "type": "number", "optional": true, "description": "X coordinate"],
                    ["name": "y", "type": "number", "optional": true, "description": "Y coordinate"]
                ]
            ],
            [
                "name": "select_creature",
                "description": "Select a creature for mixing (first call = head, second = body)",
                "parameters": [
                    ["name": "creature_id", "type": "string", "optional": false, "description": "Creature ID like 'fire_fire' or 'water_earth'"]
                ]
            ],
            [
                "name": "mix",
                "description": "Perform the mix with currently selected head and body creatures",
                "parameters": [] as [[String: Any]]
            ],
            [
                "name": "clear_selection",
                "description": "Clear both head and body selections",
                "parameters": [] as [[String: Any]]
            ],
            [
                "name": "open_mixodex",
                "description": "Open the Mixodex collection overlay",
                "parameters": [] as [[String: Any]]
            ],
            [
                "name": "close_mixodex",
                "description": "Close the Mixodex overlay",
                "parameters": [] as [[String: Any]]
            ],
            [
                "name": "reset",
                "description": "Reset all game progress",
                "parameters": [] as [[String: Any]]
            ]
        ]
    }
}
#endif
