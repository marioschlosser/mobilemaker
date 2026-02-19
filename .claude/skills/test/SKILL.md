---
name: test
description: Test an iOS game using the in-game HTTP test harness. Builds, launches, and runs automated test sequences via curl commands.
---

# Test Game Skill

**Purpose**: Automated testing of iOS games through the embedded HTTP test harness. Builds the game, launches it on a simulator, then sends commands and verifies behavior via curl.

**Use this skill when**: The user wants to test game behavior, verify a fix, run a smoke test, or validate game state after changes.

---

## Prerequisites

The game must include the TestHarness module (`TestHarness/TestableGame.swift` and `TestHarness/TestHarnessServer.swift`). All games created with the `create` skill include this automatically.

---

## Phase 1: Build & Launch

### Step 1: Build for Simulator (Debug)

```bash
cd {GameName}
xcodebuild -project {GameName}.xcodeproj \
  -scheme {GameName} \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -configuration Debug \
  build 2>&1 | tail -5
```

If the build fails, use the `debug` skill to fix errors before continuing.

### Step 2: Boot Simulator

```bash
# Boot if not already running
xcrun simctl boot "iPhone 16" 2>/dev/null || true
```

### Step 3: Install & Launch App

```bash
# Find the built app
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "{GameName}.app" -path "*/Debug-iphonesimulator/*" -type d | head -1)

# Install
xcrun simctl install booted "$APP_PATH"

# Launch (terminates existing instance first)
xcrun simctl terminate booted com.{bundleid} 2>/dev/null || true
xcrun simctl launch booted com.{bundleid}
```

### Step 4: Wait for Harness

```bash
# Wait up to 10 seconds for the harness to respond
for i in $(seq 1 20); do
  if curl -s --max-time 0.5 http://localhost:7483/ping > /dev/null 2>&1; then
    echo "Harness ready!"
    break
  fi
  sleep 0.5
done
```

---

## Phase 2: Discover Game Capabilities

### Get Available Actions

```bash
curl -s http://localhost:7483/actions | python3 -m json.tool
```

This returns the game's self-describing action catalog. Use this to understand what commands are available before writing test sequences.

### Get Current State

```bash
curl -s http://localhost:7483/state | python3 -m json.tool
```

---

## CRITICAL: Use Named Actions, Not Tap Coordinates

**Always prefer named actions over tap coordinates.** The `/tap` endpoint simulates a touch at screen coordinates, but this is **unreliable** because:

1. **Phantom touches**: The iOS Simulator can generate phantom touch events that interfere with state set via the harness, causing unpredictable behavior
2. **Coordinate fragility**: Exact positions depend on screen size, layout, and scroll state — they break across devices
3. **UI interaction interference**: SpriteKit's touch handling system can race with harness-triggered state changes

**Named actions** (via `/action`) should directly manipulate the game model, bypassing the UI/touch layer entirely. This gives deterministic, reproducible results.

### Writing Good Test Harness Actions

In `performAction()` inside the `TestableGame` extension, actions should **set model state directly** rather than calling scene UI methods:

```swift
// BAD - goes through UI, can be affected by phantom touches
case "select_creature":
    selectCreatureForMixing(creature)  // Scene method that interacts with SpriteKit

// GOOD - sets model state directly, deterministic
case "select_creature":
    if model.headSelection == nil {
        model.selectHead(creature)
    } else if model.bodySelection == nil {
        model.selectBody(creature)
    } else {
        model.clearSelection()
        model.selectHead(creature)
    }
```

Only call scene methods for visual-only updates (like `updateMixButton()`) after changing model state.

---

## Phase 3: Execute Test Sequences

### Named Action Test (Preferred)

```bash
curl -s -X POST http://localhost:7483/action \
  -H "Content-Type: application/json" \
  -d '{"name":"select_creature","parameters":{"creature_id":"fire_fire"}}'
```

### Tap Test (Use Sparingly — For Stress Testing Only)

```bash
# Only use taps for stress testing / crash detection, not for verifying logic
for i in $(seq 1 10); do
  curl -s -X POST http://localhost:7483/tap \
    -H "Content-Type: application/json" \
    -d "{\"x\":$((RANDOM % 300 + 50)),\"y\":$((RANDOM % 600 + 100))}" > /dev/null
done
# Verify no crash
curl -s http://localhost:7483/ping
```

### Screenshot Verification

Two steps — capture then visually inspect:

```bash
# Step 1: Capture screenshot from simulator
xcrun simctl io booted screenshot /tmp/test_screenshot.png
```

Then use the **Read tool** on the PNG file to visually inspect it:

```
Read file: /tmp/test_screenshot.png
```

Claude Code is multimodal and can read image files directly. This is how you verify visual state — UI layout, button placement, label text, particle effects, etc. Always take + read a screenshot after key test moments.

---

## Phase 4: Verify Results

After running test sequences, verify:

1. **State correctness**: Does `/state` return expected values?
2. **Visual correctness**: Does the screenshot show expected UI?
3. **No crashes**: Does `/ping` still respond after all actions?
4. **Performance**: Did rapid actions cause any issues?

### Verification Script Pattern

```bash
# 1. Ping check
PING=$(curl -s http://localhost:7483/ping)
echo "Ping: $PING"

# 2. State check
STATE=$(curl -s http://localhost:7483/state)
echo "State: $STATE"

# 3. Screenshot (capture via Bash, then read the PNG with the Read tool to visually inspect)
xcrun simctl io booted screenshot /tmp/verify.png
```

After running the above, use the **Read tool** on `/tmp/verify.png` to see the actual screen.

---

## Convenience Script

Use `scripts/harness.sh` for shorter commands:

```bash
./scripts/harness.sh ping
./scripts/harness.sh state
./scripts/harness.sh tap 200 400
./scripts/harness.sh action fire '{"weapon":"missile"}'
./scripts/harness.sh screenshot /tmp/shot.png
./scripts/harness.sh actions
```

---

## Common Test Patterns

### Smoke Test (Run After Every Change)

1. Build (Debug)
2. Launch on simulator
3. Wait for `/ping`
4. Get `/actions` (discover available named actions)
5. Get `/state` (baseline)
6. Execute 3-5 named actions that exercise the core game loop
7. Get `/state` (verify values changed as expected)
8. Take screenshot (`xcrun simctl io booted screenshot /tmp/smoke.png`) then **Read** the PNG to visually verify
9. Verify no crashes (`/ping` still responds)

### Regression Test (Run After Bug Fix)

1. Build & launch
2. Reproduce the specific scenario that caused the bug
3. Verify the fix via state and/or screenshot
4. Run smoke test to ensure nothing else broke

### Balance Test (Run After Tuning)

1. Build & launch
2. Execute a specific gameplay sequence (e.g., 50 taps, specific actions)
3. Check resource values in state
4. Verify progression feels right (not too fast/slow)

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `/ping` not responding | Check app is running: `xcrun simctl list | grep Booted`. Rebuild & relaunch. |
| "no game connected" | Harness started before scene loaded. Relaunch app. |
| Build fails | Use `debug` skill to fix build errors first. |
| Wrong port | Check `./scripts/harness.sh port` or set `HARNESS_PORT` env var. |
| Stale state after code change | Must rebuild, reinstall, and relaunch. Hot reload is not supported. |
| State changes unexpectedly between action calls | Actions may route through scene UI methods instead of setting model state directly. Fix `performAction()` to bypass UI — see "Critical" section below. |
| Phantom touches corrupting state | The iOS Simulator can inject phantom touch events. Ensure all harness actions manipulate the model directly, not via `handleTap()` or scene touch methods. |
| `iPhone 16` simulator not found | Simulator names change across Xcode versions. Run `xcrun simctl list devices available` to find valid names (e.g., `iPhone 17 Pro`). |
| Selection/state changes unexpectedly | Phantom simulator touches interfering. Use named actions that set model state directly, not `/tap` coordinates. See "Critical: Use Named Actions" section. |
| Action works once but state lost on next call | The `performAction` handler is likely calling a scene UI method instead of setting model state directly. Rewrite handler to bypass the scene layer. |

---

## Critical: Use Named Actions, Not Tap Coordinates

**DO NOT use `/tap` with screen coordinates to test game logic.** The iOS Simulator can produce phantom touch events that interfere with tap-based testing, causing unreliable results. Coordinate-based taps are also brittle — they break when UI layout changes.

**INSTEAD, use named actions via `/action`** that directly manipulate game model state, bypassing the scene's touch handling entirely.

### Bad: Testing via tap coordinates
```bash
# UNRELIABLE — phantom touches, coordinate drift, layout-dependent
curl -s -X POST http://localhost:7483/tap \
  -d '{"x":76,"y":100}'   # Where is this? Will it still work after a UI change?
```

### Good: Testing via named actions
```bash
# RELIABLE — directly sets model state, no UI interference
curl -s -X POST http://localhost:7483/action \
  -H "Content-Type: application/json" \
  -d '{"name":"select_creature","parameters":{"creature_id":"fire_fire"}}'
```

### How to implement this in `performAction`

When writing `performAction` handlers in the `TestableGame` extension, **set model state directly** rather than calling scene UI methods:

```swift
// BAD — calls UI method which can interact with touch system
case "select_creature":
    selectCreatureForMixing(creature)  // Goes through scene's UI flow

// GOOD — directly sets model state, bypassing UI
case "select_creature":
    if model.headSelection == nil {
        model.selectHead(creature)
    } else if model.bodySelection == nil {
        model.selectBody(creature)
    } else {
        model.clearSelection()
        model.selectHead(creature)
    }
```

The `/tap` endpoint can still exist for stress testing (random taps to check for crashes), but **all functional tests should use named actions that directly change game state**.

---

## Remember

1. **Always build first** - Code changes require a fresh build + install + launch
2. **Check /ping before testing** - Ensures harness is ready
3. **Use /actions for discovery** - Don't guess what actions are available
4. **Use named actions, not taps** - Named actions directly change model state; taps are unreliable
5. **Screenshot after key moments** - Visual verification catches what state checks miss
6. **Test both happy path and edge cases** - Duplicates, boundary values, rapid sequences, etc.
