# Mixodia - Game Design Document

**Version**: 1.0 | **Platform**: iOS | **Engine**: SpriteKit | **Updated**: 2026-02-18

**Core Loop**: Discover creatures -> Mix two creatures -> Reveal hybrid -> Collect & catalog -> Repeat

---

## Overview

Mixodia is a bright fantasy creature-mixing game where players combine magical creatures to create powerful hybrids. Players start with four basic elemental creatures — Ember (Fire), Splash (Water), Pebble (Earth), and Breeze (Air) — and mix them to discover new hybrid species that inherit visual traits and elemental powers from both parents.

The v1 experience focuses entirely on the creature mixing lab. Players drag two creatures onto the Mixing Pedestal, watch a magical fusion animation, and discover what hybrid emerges. Each creature has a head element and a body element, creating 16 possible combinations (4x4). Discovered hybrids are cataloged in the Mixodex, driving completionist collection gameplay.

**Target Audience**: Casual gamers who enjoy collection/discovery mechanics (Pokemon, creature collectors)
**Session Length**: 2-5 minutes
**Orientation**: Portrait

---

## Core Loop and Metrics Balance

**Core Loop**: Select two creatures -> Place on Mixing Pedestal -> Watch fusion -> Discover hybrid -> Add to Mixodex -> Repeat

**Key Metrics**:

| Metric | Sources | Sinks | Balance Goal |
|--------|---------|-------|--------------|
| Essence | Discovering new hybrids, first-time mixes | Mixing cost (1 per mix) | Starts generous (10), earns 3 per new discovery |
| Mixodex Progress | Successful unique mixes | N/A (never decreases) | 16 total combinations to find |
| Creatures Owned | Starting 4 + all discovered hybrids | N/A (permanent collection) | Grows with each unique mix |

---

## Core Systems

### 1. Creature System

Each creature has:
- **Name**: Unique species name
- **Head Element**: Fire / Water / Earth / Air
- **Body Element**: Fire / Water / Earth / Air
- **Sprite**: Unique generated artwork
- **Description**: Flavor text

**Base Creatures** (4 starters):

| Name | Head | Body | Visual |
|------|------|------|--------|
| Ember | Fire | Fire | Small flame fox |
| Splash | Water | Water | Blue water otter |
| Pebble | Earth | Earth | Rocky armadillo |
| Breeze | Air | Air | Cloud-wisp bird |

**Hybrid Naming**: Head creature name prefix + Body creature name suffix
- Example: Ember (head) + Splash (body) = "Embash" (fire head, water body)

### 2. Mixing System

1. Player selects first creature (becomes HEAD donor)
2. Player selects second creature (becomes BODY donor)
3. Both placed on Mixing Pedestal with particle effects
4. Fusion animation plays (swirl, flash, reveal)
5. Hybrid creature appears with combined traits
6. If new: celebration + Mixodex entry + 3 Essence reward
7. If duplicate: smaller reward (1 Essence)

**Mix Rules**:
- Any two creatures can mix (including hybrids with base creatures)
- Head element comes from first creature selected
- Body element comes from second creature selected
- Order matters! A+B differs from B+A
- Costs 1 Essence per mix

### 3. Mixodex (Collection Catalog)

Grid of 16 slots (4x4 matrix: head element x body element):
- Undiscovered slots show a "?" silhouette
- Discovered slots show the creature sprite and name
- Tapping a discovered creature shows details (name, elements, description)
- Progress bar shows X/16 discovered

---

## Controls & Input

- **Tap creature**: Select it for mixing (first tap = head, second tap = body)
- **Tap Mixing Pedestal**: Initiate the mix (when 2 creatures selected)
- **Tap Mixodex button**: Open/close the collection catalog
- **Tap creature in Mixodex**: View creature details
- **Swipe creature shelf**: Scroll through owned creatures

---

## UI Screens

1. **Main Game Screen (Mixing Lab)**:
   - Top: Essence counter, Mixodex button
   - Center: Mixing Pedestal (two circular slots + central fusion area)
   - Bottom: Creature shelf (horizontal scrollable row of owned creatures)
   - Background: Magical laboratory with glowing potions and arcane symbols

2. **Mixodex Overlay**:
   - 4x4 grid showing all possible element combinations
   - Row headers: Head elements (Fire, Water, Earth, Air)
   - Column headers: Body elements (Fire, Water, Earth, Air)
   - Progress bar at top
   - Tap outside to dismiss

3. **Creature Detail Card** (popup):
   - Large creature sprite
   - Name, elements, description
   - Element badges (head + body)

---

## Art Style

**Visual Direction**: Bright, colorful cartoon fantasy with soft edges and magical glow effects. Think Slime Rancher meets Pokemon — friendly, inviting creature designs with vibrant elemental coloring.

**Color Palette**:
- Fire: Warm oranges, reds, golden yellows
- Water: Ocean blues, teals, seafoam
- Earth: Rich browns, forest greens, amber
- Air: Sky blues, lavender, white wisps
- UI: Deep purple backgrounds, gold accents, crystal white text

**Key Assets Needed**:
- Backgrounds: Magical mixing lab
- Creatures: 4 base + 12 hybrids = 16 creature sprites
- UI Elements: Mixing pedestal, essence icon, element badges, Mixodex frame, creature card
- App Icon: Colorful creature fusion burst

---

## Audio

- **Music**: Whimsical fantasy lab ambiance (not in v1)
- **SFX**: Mix swoosh, discovery fanfare, creature appear sparkle (not in v1)

---

## Version History

### v1 - Initial Release - 2026-02-18
- 4 base elemental creatures with generated art
- Creature mixing system (head + body element inheritance)
- 16 discoverable hybrid combinations
- Mixodex collection catalog
- Mixing Pedestal with fusion animation
- Essence resource system
- Test harness integration

---

## Roadmap

### v2: BALANCE + CONTENT
- [ ] Balance: Tune essence economy, add bonus for completing element rows/columns
- [ ] Content: Creature descriptions and lore for all 16 species
- [ ] Polish: Improved particle effects, sound effects, haptic feedback

### v3+: Future Ideas
- Battle system (turn-based combat using hybrid creatures)
- Trait inheritance (special abilities from parent elements)
- Arena progression (battle increasingly tough opponents)
- Rare/shiny creature variants
- Creature evolution (level up hybrids)
