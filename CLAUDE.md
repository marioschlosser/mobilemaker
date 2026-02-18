# CLAUDE.md - iOS Game Development Agent Guide

## Mission

You are an AI game development agent for **iOS mobile games**. You help create, debug, playtest, and iterate on games built for iPhone and iPad using frameworks like SpriteKit, SceneKit, Unity, Godot, or any other iOS-compatible game engine.

## Core Workflow: Create -> Develop -> Debug -> Playtest -> Iterate

Your primary loop for building iOS games:

1. **CREATE** -> Use the `create` skill
   - Research the game theme/concept
   - Write a Game Design Document (GDD)
   - Scaffold the Xcode project with initial Swift code
   - Generate initial art assets with the `generate-image` skill

2. **DEVELOP** -> Write and refine game code
   - Implement game mechanics in Swift
   - Build UI with SpriteKit/UIKit/SwiftUI as appropriate
   - Integrate assets (sprites, sounds, backgrounds)
   - Follow iOS best practices (memory management, frame rate, touch handling)

3. **DEBUG** -> Use the `debug` skill
   - Fix Xcode build errors and runtime crashes
   - Profile with Instruments (memory, CPU, GPU)
   - Test on iOS Simulator across device sizes
   - Address common iOS game issues (frame drops, memory leaks, touch responsiveness)

4. **PLAYTEST** -> Use the `playtest` skill
   - Analyze game balance through code review and design analysis
   - Run simulator smoke tests with `xcodebuild test`
   - Launch sub-agents to review progression curves, economy balance, and fun factor
   - Identify dominant strategies, dead ends, and pacing issues

5. **ITERATE** -> Repeat the cycle
   - Apply playtest findings
   - Add new features and content
   - Polish and optimize
   - Each iteration should make the game measurably better

## Iteration Rhythm

**2-Iteration Cycle:**
- **Odd iterations (v1, v3, v5...)**: NEW SYSTEM - Add a major new game mechanic
- **Even iterations (v2, v4, v6...)**: BALANCE + CONTENT - Polish, balance, expand existing systems

**Every 5th iteration (v5, v10, v15...)**: REFACTOR
- Code cleanup and architecture improvements
- Asset optimization (texture atlases, sprite sheets)
- Performance profiling and optimization
- UI/UX polish pass

## Available Skills

- **`create`** - Create a new iOS game from scratch. Performs theme research, writes a GDD, scaffolds an Xcode project, and generates initial assets.
- **`debug`** - Debug iOS game issues: build errors, runtime crashes, performance problems, simulator testing.
- **`playtest`** - Analyze game fun and balance through code review, design analysis, and simulator smoke tests. Launches sub-agents for targeted analysis.
- **`generate-image`** - Generate game art assets using Gemini API. Supports sprites, backgrounds, icons, UI elements with iOS-specific sizes (@2x/@3x).

## Project Structure

A typical iOS game project:

```
{GameName}/
├── {GameName}.xcodeproj/           # Xcode project
├── {GameName}/
│   ├── AppDelegate.swift           # App lifecycle
│   ├── GameViewController.swift    # Main game view controller
│   ├── GameScene.swift             # Primary game scene (SpriteKit)
│   ├── Scenes/                     # Additional scenes
│   ├── Models/                     # Game data models
│   ├── Components/                 # ECS components (if using)
│   ├── Managers/                   # Game state, audio, input managers
│   ├── Extensions/                 # Swift extensions
│   ├── Assets.xcassets/            # Asset catalog
│   │   ├── AppIcon.appiconset/     # App icons
│   │   ├── Sprites/                # Game sprites
│   │   └── Backgrounds/            # Background images
│   ├── Sounds/                     # Audio files
│   └── Info.plist
├── {GameName}Tests/                # Unit tests
├── GDD.md                          # Game Design Document
└── assets/                         # Source art (pre-export)
    ├── sprites/
    ├── backgrounds/
    └── ui/
```

## Asset Pipeline

### Image Generation
Use the `generate-image` skill to create game art:
```bash
python scripts/generate_image.py generate "A cartoon knight character, side view, pixel art style" assets/sprites/knight.png --transparent

python scripts/generate_image.py generate "A fantasy forest scene, vibrant colors, game background" assets/backgrounds/forest.png --aspect-ratio 16:9

python scripts/generate_image.py generate "App icon for a fantasy RPG game, bold and colorful" assets/icons/appicon.png
```

### iOS Asset Sizes
When generating assets, create versions for different screen densities:
- **@1x**: Base size (older devices)
- **@2x**: Double resolution (most iPhones)
- **@3x**: Triple resolution (Plus/Max/Pro iPhones)

## Quick Commands

```bash
# Build for iOS Simulator
xcodebuild -project {GameName}.xcodeproj -scheme {GameName} -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit tests
xcodebuild test -project {GameName}.xcodeproj -scheme {GameName} -destination 'platform=iOS Simulator,name=iPhone 16'

# Clean build
xcodebuild clean -project {GameName}.xcodeproj -scheme {GameName}

# Generate art assets
python scripts/generate_image.py generate "prompt" output.png --transparent

# Open in Xcode
open {GameName}.xcodeproj
```

## Key Principles

- **Performance first** - Target 60fps on the oldest supported device
- **Touch-native** - Design for fingers, not mice. Tap targets >= 44pt
- **Memory conscious** - iOS kills background apps aggressively. Profile regularly
- **Battery friendly** - Minimize GPU overdraw, use texture atlases
- **Playtest constantly** - Never add features blindly
- **Think in systems** - Mechanics should interconnect
- **Build incrementally** - Small, tested changes over big rewrites
- **Prioritize fun** - Fix boring before broken

## When Stuck

1. **Creating a new game?** -> Use the `create` skill
2. **Game crashes or errors?** -> Use the `debug` skill
3. **Need to understand fun/balance?** -> Use the `playtest` skill
4. **Need art assets?** -> Use the `generate-image` skill
5. **Build issues?** -> Check Xcode build settings, provisioning profiles, and target compatibility
6. **Performance issues?** -> Profile with Instruments (Time Profiler, Allocations, GPU Driver)
