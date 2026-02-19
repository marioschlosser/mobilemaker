# LandscapeTapper - Game Design Document

**Version**: 1.0 | **Platform**: iOS | **Engine**: SpriteKit | **Updated**: 2026-02-18

**Core Loop**: Tap landscape -> Earn point -> See sparkle feedback -> Tap again

---

## Overview

LandscapeTapper is a minimalist idle/clicker game. A beautiful fantasy landscape fills the screen, and every tap anywhere on it earns the player 1 point. A score counter at the top tracks progress. Each tap produces a satisfying sparkle/ripple particle effect at the tap location.

**Target Audience**: Casual players, anyone who wants a quick dopamine hit
**Session Length**: 30 seconds to 5 minutes
**Orientation**: Portrait

---

## Core Loop and Metrics Balance

**Core Loop**: Tap -> +1 Point -> Sparkle VFX -> Repeat

**Key Metrics**:

| Metric | Sources | Sinks | Balance Goal |
|--------|---------|-------|--------------|
| Score  | Tap (+1 each) | None (accumulates) | Satisfying number growth |

---

## Core Systems

### 1. Tap Detection

Tap anywhere on the fantasy landscape image to earn 1 point. Touch response is immediate with no delay.

### 2. Score Display

Score counter displayed prominently at the top of the screen with a clean, readable font. Updates instantly on each tap.

### 3. Sparkle VFX

Each tap spawns a short-lived particle emitter at the tap location — a burst of sparkles/stars that fades out in ~0.5 seconds.

---

## Controls & Input

- **Tap**: Earn 1 point, spawn sparkle VFX

---

## UI Screens

1. **Gameplay** (only screen): Fantasy landscape background filling the screen, score label at top center

---

## Art Style

**Visual Direction**: Painterly fantasy landscape — lush, colorful, magical
**Color Palette**: Greens, blues, golds, purples
**Key Assets Needed**:
- Backgrounds: Fantasy landscape (full screen)
- VFX: Sparkle particle (built with SpriteKit particle emitter)

---

## Version History

### v1 - Initial Release - 2026-02-18
- Fantasy landscape background
- Tap-to-score mechanic
- Score counter UI
- Sparkle tap feedback VFX
- Score persistence via UserDefaults

---

## Roadmap

### v2: BALANCE + CONTENT
- [ ] Add tap sound effect
- [ ] Add milestone celebrations (every 100 points)
- [ ] Add high score tracking

### v3+: Future Ideas
- Combo multiplier for rapid taps
- Multiple landscape scenes to unlock
- Upgrades that give more points per tap
