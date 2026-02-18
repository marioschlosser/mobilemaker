---
name: generate-image
description: Generate game art assets using Gemini 2.5 Flash Image API. Supports sprites, backgrounds, icons, and UI elements with iOS-specific sizes (@2x/@3x).
---

# Generate Image Skill

## Purpose

Generate game art assets on demand using Google's Gemini 2.5 Flash Image API. Create sprites, backgrounds, app icons, and UI elements for iOS games.

## Requirements

- `GEMINI_API_KEY` must be available (either in `.env` file or as environment variable)
- `google-genai` Python package installed (`pip install google-genai`)
- `Pillow` Python package for transparent backgrounds (`pip install Pillow`)

## When to Use

- Creating sprites, characters, or game objects
- Generating background art and environments
- Making app icons and UI elements
- Editing existing assets to create variants (mood changes, damage states)

## Commands

### Generate New Image

```bash
python scripts/generate_image.py generate "prompt" output_path.png
```

**Examples:**
```bash
# Character sprite with transparent background
python scripts/generate_image.py generate "A cartoon knight character, side view, pixel art style" assets/sprites/knight.png --transparent

# Game background (16:9 for landscape games)
python scripts/generate_image.py generate "A fantasy forest scene, vibrant colors, game background" assets/backgrounds/forest.png --aspect-ratio 16:9

# Portrait background (9:16 for portrait games)
python scripts/generate_image.py generate "A vertical dungeon corridor, dark and atmospheric" assets/backgrounds/dungeon.png --aspect-ratio 9:16

# App icon (square)
python scripts/generate_image.py generate "App icon for a space shooter game, bold neon colors, minimal" assets/icons/appicon.png
```

### Edit Existing Image

```bash
python scripts/generate_image.py edit "prompt" input.png output.png
```

**Examples:**
```bash
# Create damage variant of a character
python scripts/generate_image.py edit "Add battle damage, torn clothes, scratches" assets/sprites/knight.png assets/sprites/knight_damaged.png

# Change scene mood
python scripts/generate_image.py edit "Make the scene nighttime with moonlight" assets/backgrounds/forest.png assets/backgrounds/forest_night.png

# Remove elements
python scripts/generate_image.py edit "Remove the clouds, make sky clear blue" assets/backgrounds/sky.png assets/backgrounds/sky_clear.png
```

### Crop Transparent Borders

```bash
python scripts/generate_image.py crop image1.png image2.png ...
```

**Examples:**
```bash
# Crop a single sprite
python scripts/generate_image.py crop assets/sprites/knight.png

# Crop with padding
python scripts/generate_image.py crop assets/sprites/knight.png --padding 4

# Crop all sprites
python scripts/generate_image.py crop assets/sprites/*.png
```

## Parameters

### Generate Command
| Parameter | Required | Description |
|-----------|----------|-------------|
| prompt | Yes | Text description of the image to generate |
| output | Yes | Path to save the generated image |
| --aspect-ratio, -a | No | Aspect ratio (default: 1:1). Options: 1:1, 16:9, 9:16, 4:3, 3:4 |
| --transparent, -t | No | Generate with transparent background (for sprites/icons) |

### Edit Command
| Parameter | Required | Description |
|-----------|----------|-------------|
| prompt | Yes | Text description of the edit to make |
| input | Yes | Path to the input image |
| output | Yes | Path to save the edited image |

### Crop Command
| Parameter | Required | Description |
|-----------|----------|-------------|
| images | Yes | One or more PNG image paths to crop |
| --padding, -p | No | Pixels of transparent padding to keep (default: 0) |

## iOS-Specific Asset Tips

### App Icon Sizes

Generate at 1024x1024 (App Store size), then resize for device sizes:

| Size | Usage |
|------|-------|
| 1024x1024 | App Store |
| 180x180 | iPhone @3x |
| 120x120 | iPhone @2x |
| 167x167 | iPad Pro @2x |
| 152x152 | iPad @2x |

### Sprite Sizes (@2x/@3x)

Design sprites at @2x resolution, then scale for other densities:

| Design Size (points) | @1x (px) | @2x (px) | @3x (px) |
|----------------------|----------|----------|----------|
| 32x32 | 32x32 | 64x64 | 96x96 |
| 64x64 | 64x64 | 128x128 | 192x192 |
| 128x128 | 128x128 | 256x256 | 384x384 |

### Background Sizes

| Orientation | Device | Recommended Size |
|-------------|--------|-----------------|
| Landscape | iPhone | 2796x1290 (@3x) |
| Portrait | iPhone | 1290x2796 (@3x) |
| Landscape | iPad | 2732x2048 (@2x) |

### Launch Screen Images

Generate separate launch screen backgrounds for different device families.

## Transparent Backgrounds

The `--transparent` flag creates images with transparent backgrounds, ideal for game sprites.

### How It Works
1. Appends "solid bright green background #00FF00" to your prompt
2. Generates the image with a green screen background
3. Automatically removes the green pixels and makes them transparent
4. Auto-crops transparent borders

### Tips
- Keep subjects simple and distinct from green (avoid green objects)
- Works best for: sprites, icons, characters, objects, UI elements
- May not work well for: landscapes, scenes with green elements

## Creating Character Variants with Edit

The `edit` command creates consistent character variations (moods, damage states, power-ups).

### Technique
1. Start with ONE good reference image
2. Use `edit` to change only the expression/state
3. Always edit from the SAME reference (don't chain edits)

### Example: Character State Set

```bash
REF=assets/sprites/hero.png

# Idle state (reference)
python scripts/generate_image.py generate \
    "A cartoon hero character, standing pose, pixel art, side view" \
    $REF --transparent

# Attack state
python scripts/generate_image.py edit \
    "Change ONLY the pose to attacking with a sword swing. Same character, same art style, same colors." \
    $REF assets/sprites/hero_attack.png

# Damaged state
python scripts/generate_image.py edit \
    "Add battle damage, scratches, torn clothes. Same character, same art style, same pose." \
    $REF assets/sprites/hero_damaged.png

# Power-up state
python scripts/generate_image.py edit \
    "Add a glowing golden aura around the character. Same character, same pose, same style." \
    $REF assets/sprites/hero_powered.png
```

### Tips for Consistency
- Always edit from the SAME reference image
- Be explicit about what stays the same (style, colors, proportions)
- Describe changes in physical terms
- Run variants in parallel (independent operations)

## Prompt Tips

### For Game Sprites
- Specify art style: "pixel art", "cartoon", "flat vector", "hand-drawn"
- Include view: "side view", "top-down", "isometric", "front-facing"
- Describe clearly: size, pose, key features

### For Backgrounds
- Include mood: "peaceful", "dangerous", "mysterious"
- Describe depth: "foreground trees, midground path, background mountains"
- Specify lighting: "golden hour", "moonlit", "overcast"

### For UI Elements
- Keep it simple: "flat design button with rounded corners"
- Specify state: "normal state", "pressed state", "disabled state"
- Include style: match the game's overall art direction

## Troubleshooting

### "GEMINI_API_KEY environment variable not set"
```bash
# Add to .env file
echo 'GEMINI_API_KEY=your-api-key-here' >> .env

# Or export directly
export GEMINI_API_KEY="your-api-key-here"
```

### "No image was generated"
- Prompt may have triggered safety filters - rephrase it
- Avoid content that might trigger restrictions

### "google-genai package not installed"
```bash
pip install google-genai Pillow
```
