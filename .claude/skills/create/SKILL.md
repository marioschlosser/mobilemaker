---
name: create
description: Create a new iOS game from scratch. Performs theme research, writes a Game Design Document, scaffolds an Xcode project with Swift code, and sets up the asset pipeline.
---

# Create Game Skill

**Purpose**: Create a new iOS mobile game from scratch, themed around a concept, person, company, event, or genre. The game is built from comprehensive research about the theme.

**Use this skill when**: The user wants to create a brand new iOS game.

---

## Theme Types

Games can be themed around:

| Theme Type | Examples | Research Focus |
|------------|----------|----------------|
| **Genre** | Tower defense, endless runner, puzzle RPG | Top games in genre, core mechanics, what makes them fun |
| **Person** | Historical figure, celebrity | Life story, achievements, signature concepts |
| **Company** | Tesla, NASA, SpaceX | Products, history, industry dynamics |
| **Event** | Moon landing, gold rush | Timeline, key figures, turning points |
| **Country** | Japan, Brazil, Egypt | History, culture, geography, famous exports |

---

## Phase 1: Theme Research (CRITICAL)

**Goal**: Gather comprehensive information about the theme to inform game design.

### Research Checklist

**For GENRES:**

1. **Top Games Analysis**
   - Search: `"best {genre} games iOS 2025"`
   - Search: `"{genre} game mechanics breakdown"`
   - Find: What makes the best games in this genre fun

2. **Core Mechanics**
   - Search: `"{genre} game design patterns"`
   - Search: `"{genre} game core loop"`
   - Find: Essential mechanics, what players expect

3. **Monetization & Retention**
   - Search: `"{genre} mobile game retention strategies"`
   - Find: Session length, progression pacing, replay value

**For PERSONS:**

1. **Professional Profile**
   - Search: `"{person name}" career history achievements`
   - Find: Key milestones, frameworks, methodologies

2. **Story Arc**
   - Search: `"{person name}" biography journey`
   - Find: Progression from beginning to mastery

3. **Signature Concepts**
   - Search: `"{person name}" philosophy approach`
   - Find: Ideas that become game mechanics

**For COMPANIES:**

1. **Company Overview**
   - Search: `"{company}" history products services`
   - Find: Core business model, key products

2. **Industry Dynamics**
   - Search: `"{company}" competitors industry challenges`
   - Find: Competitive landscape, strategic decisions

**For EVENTS / COUNTRIES:**

1. **Timeline & Key Figures**
   - Search for historical arc, turning points, factions
   - Find: Natural progression that maps to game stages

### Research Output

After research, identify:

1. **Core Identity**: What defines this theme? (1-2 sentences)
2. **Key Concepts**: 3-5 signature ideas that become mechanics
3. **Progression Arc**: Natural story from beginning to mastery
4. **Resource Types**: What does the player manage?
5. **Decision Points**: What meaningful choices does the player make?

### Design the Core Loop and Metrics

**Core Loop**: The fundamental cycle players repeat
- Example: "Deploy units -> Battle enemies -> Earn rewards -> Upgrade army -> Repeat"
- Must be satisfying on a phone in 2-5 minute sessions

**Key Metrics** (3-5 resources/stats that drive gameplay):

| Metric | Sources (gains) | Sinks (costs) | Balance Goal |
|--------|-----------------|---------------|--------------|
| Gold | Battle wins, quests | Upgrades, unlocks | Slight surplus early, tight late |
| Energy | Time regen, items | Actions, abilities | Forces pacing decisions |
| XP | All actions | Level thresholds | Steady progression feel |

**Avoid these design mistakes**:
- **Inflationary**: Resource with no sinks -> accumulates forever -> trivializes game
- **Deflationary**: Sinks exceed sources -> death spiral -> frustrating
- **Unconnected**: Metric that doesn't affect anything -> feels pointless

---

## Phase 2: Game Design Document

**Goal**: Create GDD.md with initial systems based on research.

### GDD.md Template

```markdown
# {Game Name} - Game Design Document

**Version**: 1.0 | **Platform**: iOS | **Engine**: {SpriteKit/Unity/Godot} | **Updated**: {date}

**Core Loop**: {One sentence describing the main gameplay loop}

---

## Overview

{2-3 paragraph description of the game concept, inspired by research findings}

**Target Audience**: {Who is this for?}
**Session Length**: {Typical play session duration}
**Orientation**: {Portrait/Landscape}

---

## Core Loop and Metrics Balance

**Core Loop**: {Action} -> {Result} -> {Reward} -> {Investment} -> Repeat

**Key Metrics**:

| Metric | Sources | Sinks | Balance Goal |
|--------|---------|-------|--------------|
| {Primary currency} | {How gained} | {How spent} | {Target behavior} |
| {Secondary resource} | {How gained} | {How spent} | {Target behavior} |

---

## Core Systems

### 1. {Primary Mechanic}

{Description of main gameplay mechanic}

### 2. {Progression System}

| Stage | Unlocks | Requirements |
|-------|---------|--------------|
| {Stage 1} | {Features} | Start |
| {Stage 2} | {Features} | {Requirement} |
| {Stage 3} | {Features} | {Requirement} |

### 3. {Theme-Specific System}

{A system unique to this theme}

---

## Controls & Input

- **Tap**: {Primary action}
- **Swipe**: {Secondary action}
- **Long press**: {Tertiary action}
- **Pinch**: {If applicable}

---

## UI Screens

1. **Main Menu**: Title, play button, settings, achievements
2. **Gameplay**: {Core game screen description}
3. **Upgrade/Shop**: {Progression screen}
4. **Results**: {End of round/level summary}

---

## Art Style

**Visual Direction**: {e.g., "Pixel art with vibrant colors", "Low-poly 3D", "Hand-drawn watercolor"}
**Color Palette**: {Primary colors}
**Key Assets Needed**:
- Backgrounds: {list}
- Characters/Sprites: {list}
- UI Elements: {list}
- App Icon: {description}

---

## Audio

- **Music**: {Style, mood}
- **SFX**: {Key sound effects needed}

---

## Version History

### v1 - Initial Release - {date}
- {System 1}
- {System 2}
- {System 3}

---

## Roadmap

### v2: BALANCE + CONTENT
- [ ] Balance: {tasks}
- [ ] Content: {new content}
- [ ] Polish: {polish tasks}

### v3+: Future Ideas
- {Future system 1}
- {Future system 2}
```

---

## Phase 3: Xcode Project Setup

**Goal**: Create a buildable Xcode project with initial game code.

### Project Creation

```bash
# Create project directory
mkdir -p {GameName}/{GameName}
mkdir -p {GameName}/{GameName}Tests
mkdir -p {GameName}/assets/{sprites,backgrounds,ui}
```

### For SpriteKit Games (Most Common)

Create the key files:

1. **GameScene.swift** - Main game scene
2. **GameViewController.swift** - View controller hosting the scene
3. **GameModel.swift** - Core game state and logic (separated from rendering)
4. **AppDelegate.swift** - App lifecycle

### Key Patterns for iOS Games

**Game State Separation**: Keep game logic separate from rendering
```swift
// GameModel.swift - Pure game logic, no SpriteKit imports
class GameModel {
    var score: Int = 0
    var level: Int = 1
    var resources: [String: Int] = [:]

    func processAction(_ action: GameAction) -> [GameEvent] {
        // Pure logic, returns events for the scene to animate
    }
}

// GameScene.swift - Rendering and input only
class GameScene: SKScene {
    let model = GameModel()

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Convert touch to game action
        let events = model.processAction(.tap(location))
        // Animate events
        for event in events {
            animate(event)
        }
    }
}
```

**Touch Handling Best Practices**:
```swift
// Minimum 44pt tap targets
let buttonSize = CGSize(width: 44, height: 44)

// Respond on touch-up, not touch-down (allows cancel by dragging away)
override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)
    // Process tap
}
```

**Performance Patterns**:
```swift
// Use texture atlases for sprites
let atlas = SKTextureAtlas(named: "Characters")
let texture = atlas.textureNamed("knight_idle")

// Object pooling for frequently created/destroyed nodes
class NodePool<T: SKNode> {
    private var available: [T] = []

    func get() -> T {
        return available.popLast() ?? T()
    }

    func recycle(_ node: T) {
        node.removeFromParent()
        available.append(node)
    }
}
```

### Implementation Checklist

- [ ] Xcode project builds without errors
- [ ] Game scene loads and displays
- [ ] Touch input responds correctly
- [ ] Core game loop runs (action -> result -> feedback)
- [ ] At least 3 player actions implemented
- [ ] Game state persists between sessions (UserDefaults or file)
- [ ] Runs at 60fps on simulator
- [ ] Works in both iPhone and iPad sizes

---

## Phase 4: Asset Pipeline

**Goal**: Generate initial art assets for the game.

### Generate Key Assets

```bash
# App icon (1024x1024 for App Store)
python scripts/generate_image.py generate "{game theme} app icon, bold colorful, mobile game style" assets/icons/appicon_1024.png

# Game background (landscape)
python scripts/generate_image.py generate "{scene description}, game background, {art style}" assets/backgrounds/main_bg.png --aspect-ratio 16:9

# Character sprites (transparent background)
python scripts/generate_image.py generate "{character description}, side view, {art style}" assets/sprites/hero.png --transparent

# UI elements
python scripts/generate_image.py generate "Game UI button, {style}, golden border" assets/ui/button.png --transparent
```

### iOS Asset Catalog Setup

For each image asset, you need multiple resolutions:

| Scale | Multiplier | Example (100pt icon) |
|-------|-----------|---------------------|
| @1x | 1x | 100x100 px |
| @2x | 2x | 200x200 px |
| @3x | 3x | 300x300 px |

### App Icon Sizes (Required)

| Size | Usage |
|------|-------|
| 1024x1024 | App Store |
| 180x180 | iPhone @3x |
| 120x120 | iPhone @2x |
| 167x167 | iPad Pro @2x |
| 152x152 | iPad @2x |

---

## Phase 5: Verification

### Step 1: Build
```bash
xcodebuild -project {GameName}.xcodeproj -scheme {GameName} -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Step 2: Run Tests
```bash
xcodebuild test -project {GameName}.xcodeproj -scheme {GameName} -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Step 3: Visual Check
- Open in Xcode, run on simulator
- Verify game scene renders
- Test all touch interactions
- Check all device sizes (iPhone SE, iPhone 16, iPad)

### Step 4: Performance Check
- Monitor frame rate in Xcode debug navigator
- Check memory usage stays reasonable (< 200MB for simple games)
- No visible frame drops during gameplay

---

## Output Checklist

By the end of this skill, you should have created:

1. **Game Design Document**: `{GameName}/GDD.md`
2. **Xcode Project**: `{GameName}/{GameName}.xcodeproj`
3. **Game Code**: Core Swift files (GameScene, GameModel, etc.)
4. **Test Suite**: `{GameName}/{GameName}Tests/`
5. **Art Assets**: Initial sprites, backgrounds, and app icon
6. **Buildable Project**: `xcodebuild build` succeeds

---

## Remember

1. **Research thoroughly** - Game quality depends on understanding the theme
2. **Start simple** - v1 should be playable in 10 minutes, complexity comes in iterations
3. **Mobile first** - Short sessions, touch input, portrait or landscape based on game type
4. **Separate logic from rendering** - Makes testing and iteration much easier
5. **Performance matters** - Profile early, optimize often
