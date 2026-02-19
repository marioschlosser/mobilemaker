#!/usr/bin/env python3
"""
Generate images using Gemini 2.5 Flash Image API.

Usage:
    python scripts/generate_image.py generate "A beautiful sunset" output.png
    python scripts/generate_image.py generate "A cat" cat.png --aspect-ratio 16:9
    python scripts/generate_image.py generate "A wagon sprite" wagon.png --transparent

Requires GEMINI_API_KEY environment variable (loaded from .env if present).
"""
import argparse
import base64
import os
import sys
from pathlib import Path

# Load environment variables from .env file if it exists
def load_env_file():
    """Load environment variables from .env file in project root."""
    # Find project root (look for .env file)
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    env_file = project_root / ".env"

    if env_file.exists():
        with open(env_file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, _, value = line.partition('=')
                    key = key.strip()
                    value = value.strip()
                    # Remove quotes if present
                    if value and value[0] in ('"', "'") and value[-1] == value[0]:
                        value = value[1:-1]
                    if key and key not in os.environ:
                        os.environ[key] = value

load_env_file()

# Optional PIL import for transparency support
try:
    from PIL import Image
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

try:
    from google import genai
    from google.genai import types
except ImportError:
    print("Error: google-genai package not installed.")
    print("Install with: pip install google-genai")
    sys.exit(1)


def remove_green_background(image_path: str, tolerance: int = 50) -> bool:
    """
    Remove green screen background from an image, making it transparent.

    Args:
        image_path: Path to the image file (will be modified in place)
        tolerance: How much deviation from pure green to allow (0-255)

    Returns:
        True if successful, False if PIL not available
    """
    if not PIL_AVAILABLE:
        print("Warning: PIL/Pillow not installed. Cannot remove background.")
        print("Install with: pip install Pillow")
        return False

    img = Image.open(image_path)
    img = img.convert('RGBA')
    pixels = img.load()

    width, height = img.size
    transparent_count = 0

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]
            # Check if pixel is "green enough" - green dominant over red and blue
            if g > 100 and g > r + tolerance and g > b + tolerance:
                pixels[x, y] = (0, 0, 0, 0)
                transparent_count += 1

    img.save(image_path)
    pct = 100 * transparent_count / (width * height)
    print(f"Removed background: {transparent_count} pixels ({pct:.1f}%) made transparent")
    return True


def auto_crop_transparent(image_path: str, padding: int = 0) -> bool:
    """
    Crop transparent borders from a PNG image.

    Trims fully-transparent rows/columns from all edges so the content
    fills the image bounds. Optionally adds uniform padding.

    Args:
        image_path: Path to the PNG image (modified in place)
        padding: Pixels of transparent padding to keep around content

    Returns:
        True if cropped, False if PIL not available or no change needed
    """
    if not PIL_AVAILABLE:
        print("Warning: PIL/Pillow not installed. Cannot auto-crop.")
        return False

    img = Image.open(image_path).convert('RGBA')
    bbox = img.getbbox()
    if bbox is None:
        print(f"Skipped (fully transparent): {image_path}")
        return False

    # Check if there's anything to crop
    w, h = img.size
    if bbox == (0, 0, w, h) and padding == 0:
        print(f"Skipped (no transparent border): {image_path}")
        return False

    # Apply padding
    if padding > 0:
        crop_box = (
            max(0, bbox[0] - padding),
            max(0, bbox[1] - padding),
            min(w, bbox[2] + padding),
            min(h, bbox[3] + padding),
        )
    else:
        crop_box = bbox

    cropped = img.crop(crop_box)
    cw, ch = cropped.size
    print(f"Cropped {Path(image_path).name}: {w}x{h} -> {cw}x{ch} "
          f"(removed T:{bbox[1]} B:{h-bbox[3]} L:{bbox[0]} R:{w-bbox[2]})")
    cropped.save(image_path)
    return True


def generate_image(
    prompt: str,
    output_path: str,
    aspect_ratio: str = "1:1",
    model: str = "gemini-2.5-flash-image",
    transparent: bool = False
) -> dict:
    """
    Generate an image using Gemini 2.5 Flash Image.

    Args:
        prompt: Text description of the image to generate
        output_path: Path to save the generated image
        aspect_ratio: Aspect ratio (1:1, 16:9, 9:16, 4:3, 3:4, etc.)
        model: Model to use for generation
        transparent: If True, generate with green screen and remove background

    Returns:
        dict with keys: success, path, text_response, error
    """
    # If transparent mode, modify prompt to use green screen
    if transparent:
        prompt = f"{prompt}, solid bright green background #00FF00"
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {
            "success": False,
            "error": "GEMINI_API_KEY environment variable not set"
        }

    try:
        client = genai.Client(api_key=api_key)

        # Generate content with image output
        response = client.models.generate_content(
            model=model,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_modalities=["TEXT", "IMAGE"],
                image_config=types.ImageConfig(
                    aspect_ratio=aspect_ratio
                )
            )
        )

        # Process response parts
        text_response = None
        image_saved = False

        for part in response.candidates[0].content.parts:
            if hasattr(part, 'text') and part.text:
                text_response = part.text
            elif hasattr(part, 'inline_data') and part.inline_data:
                # Save the image
                # inline_data.data may be bytes or base64 string depending on SDK version
                raw_data = part.inline_data.data
                if isinstance(raw_data, str):
                    image_data = base64.b64decode(raw_data)
                else:
                    image_data = raw_data  # Already bytes
                output_file = Path(output_path)
                output_file.parent.mkdir(parents=True, exist_ok=True)
                output_file.write_bytes(image_data)
                image_saved = True
                print(f"Image saved to: {output_path}")

        if image_saved:
            # Remove green background if transparent mode
            if transparent:
                remove_green_background(output_path)
                auto_crop_transparent(output_path)

            return {
                "success": True,
                "path": str(output_path),
                "text_response": text_response
            }
        else:
            return {
                "success": False,
                "error": "No image was generated in the response",
                "text_response": text_response
            }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def edit_image(
    prompt: str,
    input_path: str,
    output_path: str,
    model: str = "gemini-2.5-flash-image"
) -> dict:
    """
    Edit an existing image using Gemini 2.5 Flash Image.

    Args:
        prompt: Text description of the edit to make
        input_path: Path to the input image
        output_path: Path to save the edited image
        model: Model to use for generation

    Returns:
        dict with keys: success, path, text_response, error
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {
            "success": False,
            "error": "GEMINI_API_KEY environment variable not set"
        }

    input_file = Path(input_path)
    if not input_file.exists():
        return {
            "success": False,
            "error": f"Input file not found: {input_path}"
        }

    try:
        client = genai.Client(api_key=api_key)

        # Read input image
        image_data = input_file.read_bytes()
        image_base64 = base64.b64encode(image_data).decode('utf-8')

        # Determine mime type
        suffix = input_file.suffix.lower()
        mime_types = {
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.gif': 'image/gif',
            '.webp': 'image/webp'
        }
        mime_type = mime_types.get(suffix, 'image/png')

        # Create the image part
        image_part = types.Part(
            inline_data=types.Blob(
                mime_type=mime_type,
                data=image_base64
            )
        )

        # Generate content with both text prompt and image
        response = client.models.generate_content(
            model=model,
            contents=[prompt, image_part],
            config=types.GenerateContentConfig(
                response_modalities=["TEXT", "IMAGE"]
            )
        )

        # Process response parts
        text_response = None
        image_saved = False

        for part in response.candidates[0].content.parts:
            if hasattr(part, 'text') and part.text:
                text_response = part.text
            elif hasattr(part, 'inline_data') and part.inline_data:
                # Save the image
                # inline_data.data may be bytes or base64 string depending on SDK version
                raw_data = part.inline_data.data
                if isinstance(raw_data, str):
                    output_data = base64.b64decode(raw_data)
                else:
                    output_data = raw_data  # Already bytes
                output_file = Path(output_path)
                output_file.parent.mkdir(parents=True, exist_ok=True)
                output_file.write_bytes(output_data)
                image_saved = True
                print(f"Edited image saved to: {output_path}")

        if image_saved:
            return {
                "success": True,
                "path": str(output_path),
                "text_response": text_response
            }
        else:
            return {
                "success": False,
                "error": "No image was generated in the response",
                "text_response": text_response
            }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def mix_images(
    prompt: str,
    input_paths: list,
    output_path: str,
    aspect_ratio: str = "1:1",
    model: str = "gemini-2.5-flash-image"
) -> dict:
    """
    Combine multiple input images into a new image using Gemini 2.5 Flash Image.

    Supports composition (combining elements from different images), style
    transfer (applying the style of one image to a subject), and more.

    Args:
        prompt: Text description of how to combine the images
        input_paths: List of paths to input images (up to 14)
        output_path: Path to save the resulting image
        aspect_ratio: Aspect ratio for the output (1:1, 16:9, 9:16, etc.)
        model: Model to use for generation

    Returns:
        dict with keys: success, path, text_response, error
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        return {
            "success": False,
            "error": "GEMINI_API_KEY environment variable not set"
        }

    if len(input_paths) < 1:
        return {"success": False, "error": "At least one input image is required"}
    if len(input_paths) > 14:
        return {"success": False, "error": "Maximum 14 input images supported"}

    # Verify all input files exist
    for p in input_paths:
        if not Path(p).exists():
            return {"success": False, "error": f"Input file not found: {p}"}

    try:
        client = genai.Client(api_key=api_key)

        # Build contents: images first, then text prompt
        contents = []
        mime_types = {
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.gif': 'image/gif',
            '.webp': 'image/webp'
        }

        for img_path in input_paths:
            img_file = Path(img_path)
            image_data = img_file.read_bytes()
            image_base64 = base64.b64encode(image_data).decode('utf-8')
            suffix = img_file.suffix.lower()
            mime_type = mime_types.get(suffix, 'image/png')
            contents.append(types.Part(
                inline_data=types.Blob(
                    mime_type=mime_type,
                    data=image_base64
                )
            ))

        contents.append(prompt)

        response = client.models.generate_content(
            model=model,
            contents=contents,
            config=types.GenerateContentConfig(
                response_modalities=["TEXT", "IMAGE"],
                image_config=types.ImageConfig(
                    aspect_ratio=aspect_ratio
                )
            )
        )

        # Process response parts
        text_response = None
        image_saved = False

        for part in response.candidates[0].content.parts:
            if hasattr(part, 'text') and part.text:
                text_response = part.text
            elif hasattr(part, 'inline_data') and part.inline_data:
                raw_data = part.inline_data.data
                if isinstance(raw_data, str):
                    output_data = base64.b64decode(raw_data)
                else:
                    output_data = raw_data
                output_file = Path(output_path)
                output_file.parent.mkdir(parents=True, exist_ok=True)
                output_file.write_bytes(output_data)
                image_saved = True
                print(f"Mixed image saved to: {output_path}")

        if image_saved:
            return {
                "success": True,
                "path": str(output_path),
                "text_response": text_response
            }
        else:
            return {
                "success": False,
                "error": "No image was generated in the response",
                "text_response": text_response
            }

    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


def main():
    parser = argparse.ArgumentParser(
        description="Generate images using Gemini 2.5 Flash Image API"
    )

    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # Generate command
    gen_parser = subparsers.add_parser("generate", help="Generate a new image from text")
    gen_parser.add_argument("prompt", help="Text description of the image to generate")
    gen_parser.add_argument("output", help="Output path for the generated image")
    gen_parser.add_argument(
        "--aspect-ratio", "-a",
        default="1:1",
        help="Aspect ratio (1:1, 16:9, 9:16, 4:3, 3:4, etc.)"
    )
    gen_parser.add_argument(
        "--model", "-m",
        default="gemini-2.5-flash-image",
        help="Model to use"
    )
    gen_parser.add_argument(
        "--transparent", "-t",
        action="store_true",
        help="Generate with transparent background (uses green screen removal)"
    )

    # Crop command
    crop_parser = subparsers.add_parser("crop", help="Auto-crop transparent borders from PNG images")
    crop_parser.add_argument("images", nargs="+", help="One or more PNG image paths to crop")
    crop_parser.add_argument(
        "--padding", "-p",
        type=int,
        default=0,
        help="Pixels of transparent padding to keep (default: 0)"
    )

    # Edit command
    edit_parser = subparsers.add_parser("edit", help="Edit an existing image")
    edit_parser.add_argument("prompt", help="Text description of the edit to make")
    edit_parser.add_argument("input", help="Input image path")
    edit_parser.add_argument("output", help="Output path for the edited image")
    edit_parser.add_argument(
        "--model", "-m",
        default="gemini-2.5-flash-image",
        help="Model to use"
    )

    # Mix command
    mix_parser = subparsers.add_parser("mix", help="Combine multiple images into a new image")
    mix_parser.add_argument("prompt", help="Text description of how to combine the images")
    mix_parser.add_argument("inputs", nargs="+", help="Input image paths (2-14 images)")
    mix_parser.add_argument("-o", "--output", required=True, help="Output path for the combined image")
    mix_parser.add_argument(
        "--aspect-ratio", "-a",
        default="1:1",
        help="Aspect ratio (1:1, 16:9, 9:16, 4:3, 3:4, etc.)"
    )
    mix_parser.add_argument(
        "--model", "-m",
        default="gemini-2.5-flash-image",
        help="Model to use"
    )

    args = parser.parse_args()

    if args.command == "generate" or args.command is None:
        # Default to generate if no subcommand but args provided
        if args.command is None:
            # Legacy mode: prompt output
            if len(sys.argv) >= 3:
                prompt = sys.argv[1]
                output = sys.argv[2]
                aspect_ratio = "1:1"
                if len(sys.argv) >= 5 and sys.argv[3] == "--aspect-ratio":
                    aspect_ratio = sys.argv[4]
                result = generate_image(prompt, output, aspect_ratio)
            else:
                parser.print_help()
                sys.exit(1)
        else:
            result = generate_image(
                args.prompt,
                args.output,
                args.aspect_ratio,
                args.model,
                args.transparent
            )

        if result["success"]:
            print(f"Success! Image saved to: {result['path']}")
            if result.get("text_response"):
                print(f"Model response: {result['text_response']}")
        else:
            print(f"Error: {result['error']}")
            sys.exit(1)

    elif args.command == "crop":
        if not PIL_AVAILABLE:
            print("Error: Pillow not installed. Install with: pip install Pillow")
            sys.exit(1)
        cropped = 0
        for img_path in args.images:
            if not Path(img_path).exists():
                print(f"Warning: {img_path} not found, skipping")
                continue
            if auto_crop_transparent(img_path, args.padding):
                cropped += 1
        print(f"\nCropped {cropped}/{len(args.images)} images")

    elif args.command == "edit":
        result = edit_image(
            args.prompt,
            args.input,
            args.output,
            args.model
        )

        if result["success"]:
            print(f"Success! Edited image saved to: {result['path']}")
            if result.get("text_response"):
                print(f"Model response: {result['text_response']}")
        else:
            print(f"Error: {result['error']}")
            sys.exit(1)

    elif args.command == "mix":
        result = mix_images(
            args.prompt,
            args.inputs,
            args.output,
            args.aspect_ratio,
            args.model
        )

        if result["success"]:
            print(f"Success! Mixed image saved to: {result['path']}")
            if result.get("text_response"):
                print(f"Model response: {result['text_response']}")
        else:
            print(f"Error: {result['error']}")
            sys.exit(1)


if __name__ == "__main__":
    main()
