---
name: debug
description: Debug iOS game issues including Xcode build errors, runtime crashes, simulator testing, and performance profiling. Use after implementing changes to catch bugs before players encounter them.
---

# Debug Skill

**Purpose**: Diagnose and fix iOS game bugs through build verification, runtime debugging, simulator testing, and performance profiling.

**Use this skill when**: After implementing changes, when the game crashes, or when performance degrades.

---

## Step 0: Identify the Problem Category

| Category | Symptoms | Primary Tool |
|----------|----------|-------------|
| **Build Error** | Xcode won't compile | `xcodebuild` output, fix Swift errors |
| **Runtime Crash** | App launches then crashes | Crash log, stack trace analysis |
| **Logic Bug** | Game behaves incorrectly | Unit tests, code review |
| **Performance** | Frame drops, memory growth | Instruments profiling |
| **Visual Bug** | UI misaligned, wrong colors | Simulator testing, layout debugging |
| **Input Bug** | Touches don't register/wrong target | Hit testing, gesture recognizer conflicts |

---

## Step 1: Build Verification

### Check if the project builds

```bash
# Build for simulator
xcodebuild -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -50

# If using workspace (CocoaPods/SPM)
xcodebuild -workspace {GameName}.xcworkspace \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | tail -50
```

### Common Build Errors

| Error Pattern | Cause | Fix |
|---------------|-------|-----|
| `Cannot find type 'X' in scope` | Missing import or typo | Add `import SpriteKit` or fix type name |
| `Value of type 'X' has no member 'Y'` | Wrong type or API change | Check API docs, cast to correct type |
| `Missing return in closure` | Incomplete closure | Add return statement |
| `Ambiguous use of 'X'` | Multiple matching overloads | Add explicit type annotations |
| `No such module 'X'` | Missing dependency | Add via SPM/CocoaPods, or check target membership |
| `Signing requires a development team` | No provisioning | Set team in project settings or use simulator only |

### Fix Cycle

1. Read the error message carefully - Xcode errors are usually precise
2. Find the file and line number
3. Read the surrounding code context
4. Fix the issue
5. Rebuild to verify

---

## Step 2: Runtime Crash Debugging

### Reading Crash Logs

When the app crashes in the simulator, check:

```bash
# Recent crash logs (macOS)
ls -lt ~/Library/Logs/DiagnosticReports/ | head -10

# Read the most recent crash
cat ~/Library/Logs/DiagnosticReports/$(ls -t ~/Library/Logs/DiagnosticReports/ | head -1)
```

### Common Runtime Crashes

| Crash | Cause | Fix |
|-------|-------|-----|
| `EXC_BAD_ACCESS` | Accessing deallocated memory | Check for strong reference cycles, use `[weak self]` |
| `Fatal error: Index out of range` | Array bounds violation | Add bounds checking before access |
| `Fatal error: Unexpectedly found nil` | Force-unwrapping nil optional | Use `guard let` or `if let` |
| `Thread 1: signal SIGABRT` | Failed assertion or constraint | Check console for detailed message |
| `EXC_BREAKPOINT` | Hit a runtime check | Look for `fatalError()` or failed precondition |

### Debugging Techniques

**Add strategic print statements:**
```swift
// Temporary debug output (remove before ship)
#if DEBUG
print("[GameScene] Touch at: \(location), nodes: \(nodes(at: location).map { $0.name ?? "unnamed" })")
#endif
```

**Check for nil safely:**
```swift
// BAD - crashes if node doesn't exist
let player = childNode(withName: "player")!

// GOOD - handles missing node gracefully
guard let player = childNode(withName: "player") else {
    print("[ERROR] Player node not found in scene")
    return
}
```

---

## Step 3: Unit Testing

### Run Tests from Command Line

```bash
# Run all tests
xcodebuild test \
  -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  2>&1 | grep -E "(Test Case|passed|failed|error:)"

# Run specific test class
xcodebuild test \
  -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:{GameName}Tests/GameModelTests \
  2>&1 | grep -E "(Test Case|passed|failed|error:)"
```

### Writing Game Logic Tests

```swift
import XCTest
@testable import {GameName}

class GameModelTests: XCTestCase {

    func testScoreIncreasesOnEnemyDefeat() {
        let model = GameModel()
        let initialScore = model.score

        let events = model.processAction(.attack(targetId: "enemy1"))

        XCTAssertGreaterThan(model.score, initialScore,
            "Score should increase after defeating enemy")
    }

    func testResourcesCannotGoNegative() {
        let model = GameModel()
        model.gold = 5

        let events = model.processAction(.purchase(itemId: "expensive_item", cost: 100))

        XCTAssertGreaterThanOrEqual(model.gold, 0,
            "Gold should never go negative")
    }

    func testGameStateSerializationRoundTrip() {
        let model = GameModel()
        model.score = 42
        model.level = 3

        let data = try! JSONEncoder().encode(model)
        let restored = try! JSONDecoder().decode(GameModel.self, from: data)

        XCTAssertEqual(restored.score, 42)
        XCTAssertEqual(restored.level, 3)
    }
}
```

### Test Design Principles

**Test behavior, not specific numbers:**
```swift
// BAD - breaks when balance changes
XCTAssertEqual(model.gold, 150)

// GOOD - tests intent
XCTAssertGreaterThan(model.gold, initialGold, "Winning should reward gold")
```

**Test edge cases:**
```swift
func testEmptyInventoryHandledGracefully() {
    let model = GameModel()
    model.inventory = []

    // Should not crash
    let events = model.processAction(.useItem(index: 0))
    XCTAssertTrue(events.contains(where: { $0.type == .error }))
}
```

---

## Step 4: Performance Profiling

### Quick Frame Rate Check

In Xcode, when running on simulator:
- Open Debug Navigator (Cmd+7)
- Watch FPS counter, CPU %, and Memory

### Common Performance Issues in iOS Games

| Issue | Symptom | Diagnostic | Fix |
|-------|---------|------------|-----|
| Too many draw calls | Low FPS, high GPU | Xcode GPU report | Use texture atlases, batch sprites |
| Memory leak | RAM grows over time | Instruments > Leaks | Fix retain cycles, use `[weak self]` |
| Excessive allocations | Periodic stutters | Instruments > Allocations | Object pooling, avoid creating objects in update loop |
| Overdraw | Low FPS on complex scenes | Xcode > Debug > Show Drawing | Reduce overlapping transparent sprites |
| Physics overhead | Stutters during collisions | Time Profiler | Simplify physics bodies, reduce contact tests |
| Unoptimized textures | High memory, slow load | Memory report | Use power-of-2 sizes, compress textures |

### SpriteKit-Specific Performance Tips

```swift
// Use texture atlases (compile in Xcode build phase)
let atlas = SKTextureAtlas(named: "Gameplay")

// Avoid per-frame allocations
// BAD
override func update(_ currentTime: TimeInterval) {
    let newLabel = SKLabelNode(text: "Score: \(score)") // New object every frame!
    addChild(newLabel)
}

// GOOD
private let scoreLabel = SKLabelNode()
override func update(_ currentTime: TimeInterval) {
    scoreLabel.text = "Score: \(score)" // Update existing object
}

// Limit physics bodies
physicsBody = SKPhysicsBody(rectangleOf: size) // Prefer rectangles
// NOT: SKPhysicsBody(texture: texture, size: size) // Per-pixel is expensive
```

### Memory Management

```swift
// Watch for retain cycles in closures
enemy.run(SKAction.sequence([
    SKAction.fadeOut(withDuration: 0.5),
    SKAction.run { [weak self] in
        self?.handleEnemyDefeated(enemy) // weak self prevents retain cycle
    },
    SKAction.removeFromParent()
]))

// Clear references when transitioning scenes
override func willMove(from view: SKView) {
    removeAllChildren()
    removeAllActions()
}
```

---

## Step 5: Simulator Testing

### Test Across Device Sizes

```bash
# List available simulators
xcrun simctl list devices available | grep -E "(iPhone|iPad)"

# Boot a specific simulator
xcrun simctl boot "iPhone SE (3rd generation)"
xcrun simctl boot "iPhone 16 Pro Max"
xcrun simctl boot "iPad Pro 13-inch (M4)"

# Build and run
xcodebuild -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation)' \
  build

# Take a screenshot of the simulator
xcrun simctl io booted screenshot screenshot.png
```

### Device Size Checklist

| Device | Screen Size | Points | Aspect |
|--------|------------|--------|--------|
| iPhone SE | 4.7" | 375x667 | 16:9 |
| iPhone 16 | 6.1" | 393x852 | ~19.5:9 |
| iPhone 16 Pro Max | 6.9" | 440x956 | ~19.5:9 |
| iPad (10th gen) | 10.9" | 820x1180 | ~4:3 |
| iPad Pro 13" | 13" | 1032x1376 | ~4:3 |

### Common Visual Issues

| Issue | Cause | Fix |
|-------|-------|-----|
| UI cut off on small screens | Hardcoded positions | Use `scene.size` relative positioning |
| Sprites too small on iPad | Fixed pixel sizes | Scale based on screen size |
| Safe area overlap | Ignoring notch/home indicator | Respect `safeAreaInsets` |
| Wrong orientation | Missing supported orientations | Set in Info.plist and lock in view controller |

---

## Step 6: Common iOS Game Bugs

### Touch Handling Issues

```swift
// Bug: Touches pass through UI to game scene
// Fix: Check if touch is on UI element first
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let location = touch.location(in: self)

    // Check UI nodes first
    let touchedNodes = nodes(at: location)
    for node in touchedNodes {
        if let button = node as? ButtonNode {
            button.handleTap()
            return // Don't process game touch
        }
    }

    // Process game touch
    handleGameTap(at: location)
}
```

### State Persistence Issues

```swift
// Bug: Game state lost on app kill
// Fix: Save on scene transitions AND app background
NotificationCenter.default.addObserver(
    self,
    selector: #selector(saveGameState),
    name: UIApplication.willResignActiveNotification,
    object: nil
)

@objc func saveGameState() {
    let encoder = JSONEncoder()
    if let data = try? encoder.encode(gameModel) {
        UserDefaults.standard.set(data, forKey: "gameState")
    }
}
```

### Audio Issues

```swift
// Bug: Background music stops when app is interrupted
// Fix: Handle audio session properly
do {
    try AVAudioSession.sharedInstance().setCategory(.ambient)
    try AVAudioSession.sharedInstance().setActive(true)
} catch {
    print("[Audio] Failed to configure session: \(error)")
}
```

---

## Quick Debug Checklist

Before marking a fix complete:

- [ ] Project builds without warnings or errors
- [ ] All existing unit tests pass
- [ ] New test added for the bug (if applicable)
- [ ] Tested on smallest screen size (iPhone SE)
- [ ] Tested on largest screen size (iPad Pro)
- [ ] No memory leaks introduced (check Instruments if uncertain)
- [ ] Frame rate stable at 60fps during gameplay
- [ ] Game state saves and restores correctly
- [ ] Touch interactions work as expected
- [ ] No force-unwraps on user data or external input

---

## When You Can't Reproduce

If a bug is reported but you can't reproduce it:

1. **Check device-specific issues** - Some bugs only appear on certain screen sizes
2. **Check iOS version** - API behavior changes between versions
3. **Check memory pressure** - Bug may only appear when memory is low
4. **Check timing** - Race conditions in async code
5. **Add defensive code** - Guard against the reported condition even if you can't trigger it
