#!/usr/bin/env python3
"""Generate Typio's input-source menu icon as a macOS template image.

Render a black circle with a transparent T cutout. macOS tints this alpha
mask via TISIconIsTemplate. The single input source shares this icon between
the menu bar and inline switcher; no input-mode labels are required.

The app icon (him.icns) is independent and is not changed by this script.
Output is a 22 x 16 pt TIFF with 1x and 2x representations.

Usage:
    scripts/make-menu-icon.py                     # writes resources/images/Typio.tiff
    scripts/make-menu-icon.py --preview out.png   # also writes a light/dark comparison sheet
    scripts/make-menu-icon.py --weight Bold --glyph-height 0.58

Requires Pillow (pip3 install pillow) and the macOS `tiffutil` tool.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import tempfile

from PIL import Image, ImageDraw, ImageFont

POINT_WIDTH = 22         # logical width of text-based input-source icons (ABC, Pinyin)
POINT_HEIGHT = 16        # logical height of every input-source icon
SUPERSAMPLE = 8          # render at this multiple, then downscale for clean antialiasing

SF_PRO = "/System/Library/Fonts/SFNS.ttf"
HELVETICA = "/System/Library/Fonts/Helvetica.ttc"


WEIGHTS = {"regular": 400, "medium": 500, "semibold": 600, "bold": 700, "heavy": 800, "black": 900}


def load_font(px: int, weight: str) -> ImageFont.FreeTypeFont:
    """SF Pro (variable font) at the requested weight, falling back to Helvetica Bold.

    SFNS.ttf exposes axes [Width, Optical Size, GRAD, Weight]; named instances are
    unreliable in Pillow, so the Weight axis is set directly. Optical size 17 is the
    "Text" cut, whose sturdier strokes survive better at 16pt.
    """
    wght = WEIGHTS.get(weight.lower()) or int(weight)
    try:
        font = ImageFont.truetype(SF_PRO, px)
        font.set_variation_by_axes([100, 17, 400, wght])
        return font
    except Exception:
        # Helvetica.ttc face index 1 is Helvetica Bold.
        return ImageFont.truetype(HELVETICA, px, index=1)


def render_rep(scale: int, glyph: str, weight: str, glyph_height: float,
               y_nudge: float) -> Image.Image:
    """Return an RGBA image (black + alpha) for one @scale representation."""
    width, height = POINT_WIDTH * scale, POINT_HEIGHT * scale
    big_w, big_h = width * SUPERSAMPLE, height * SUPERSAMPLE

    # Size the glyph by its ink height and center it in the transparent canvas.
    target_h = big_h * glyph_height
    font = load_font(int(target_h), weight)
    l, t, r, b = font.getbbox(glyph)
    ink_h = b - t
    font = load_font(int(target_h * target_h / ink_h), weight)
    l, t, r, b = font.getbbox(glyph)
    ink_w, ink_h = r - l, b - t

    text = Image.new("L", (big_w, big_h), 0)
    x = (big_w - ink_w) / 2 - l
    y = (big_h - ink_h) / 2 - t + y_nudge * big_h
    ImageDraw.Draw(text).text((x, y), glyph, font=font, fill=255)

    plate = Image.new("L", (big_w, big_h), 0)
    # A true circle, centered within the native 22 x 16 pt input-source canvas.
    diameter = big_h
    left = (big_w - diameter) // 2
    ImageDraw.Draw(plate).ellipse((left, 0, left + diameter - 1, diameter - 1), fill=255)
    keep = Image.eval(text, lambda value: 255 - value)
    alpha = Image.composite(plate, Image.new("L", (big_w, big_h), 0), keep)
    alpha = alpha.resize((width, height), Image.LANCZOS)
    out = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    out.putalpha(alpha)
    return out


def write_tiff(rep1x: Image.Image, rep2x: Image.Image, out_path: str) -> None:
    with tempfile.TemporaryDirectory() as tmp:
        p1 = os.path.join(tmp, "Typio.png")
        p2 = os.path.join(tmp, "Typio@2x.png")
        rep1x.save(p1, dpi=(72, 72))
        rep2x.save(p2, dpi=(144, 144))
        subprocess.run(["tiffutil", "-cathidpicheck", p1, p2, "-out", out_path], check=True)


def tint(template: Image.Image, colour: tuple[int, int, int]) -> Image.Image:
    """Mimic what AppKit does with a template image: keep alpha, replace colour."""
    solid = Image.new("RGBA", template.size, colour + (255,))
    solid.putalpha(template.getchannel("A"))
    return solid


def load_native_reference() -> Image.Image | None:
    ref = ("/System/Library/Input Methods/SCIM.app/Contents/PlugIns/"
           "SCIM_Extension.appex/Contents/Resources/pinyin.tiff")
    if not os.path.exists(ref):
        return None
    im = Image.open(ref)
    im.seek(1)  # 2x representation
    return im.convert("RGBA")


def write_preview(rep2x: Image.Image, out_path: str, current_icon: str | None) -> None:
    """Side-by-side sheet: native pinyin / new Typio / current blue icon, light and dark, 4x zoom."""
    zoom = 4
    cell = POINT_WIDTH * 2 * zoom
    cell_h = POINT_HEIGHT * 2 * zoom
    pad = cell // 2
    columns = []
    native = load_native_reference()
    if native is not None:
        columns.append(("Apple pinyin.tiff", native))
    columns.append(("Typio template", rep2x))
    if current_icon and os.path.exists(current_icon):
        cur = Image.open(current_icon).convert("RGBA").resize((POINT_WIDTH * 2, POINT_HEIGHT * 2), Image.LANCZOS)
        columns.append(("current him.png", cur))

    rows = [("light menu bar", (236, 236, 236), (0, 0, 0)),
            ("dark menu bar", (40, 40, 40), (255, 255, 255)),
            ("selected row", (0, 122, 255), (255, 255, 255))]

    W = pad + len(columns) * (cell + pad)
    H = pad + len(rows) * (cell + pad) + 40
    sheet = Image.new("RGB", (W, H), (255, 255, 255))
    draw = ImageDraw.Draw(sheet)
    label_font = ImageFont.truetype(HELVETICA, 14)

    for ci, (name, _) in enumerate(columns):
        draw.text((pad + ci * (cell + pad), 8), name, font=label_font, fill=(0, 0, 0))

    for ri, (_, bg, fg) in enumerate(rows):
        y0 = 40 + pad + ri * (cell + pad)
        for ci, (name, img) in enumerate(columns):
            x0 = pad + ci * (cell + pad)
            draw.rectangle((x0 - pad // 2, y0 - pad // 2, x0 + cell + pad // 2, y0 + cell + pad // 2), fill=bg)
            shown = img if name.startswith("current") else tint(img, fg)
            shown = shown.resize((cell, cell_h), Image.NEAREST)
            sheet.paste(shown, (x0, y0 + (cell - cell_h) // 2), shown)
    sheet.save(out_path)


def main() -> int:
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--glyph", default="T")
    ap.add_argument("--weight", default="Heavy",
                    help="SF Pro weight: Regular/Medium/Semibold/Bold/Heavy/Black or a number 1-1000")
    ap.add_argument("--glyph-height", type=float, default=0.56,
                    help="glyph ink height as a fraction of the 16pt canvas")
    ap.add_argument("--y-nudge", type=float, default=0.0,
                    help="vertical optical adjustment as a fraction of the canvas height (+ moves down)")
    ap.add_argument("--out", default=os.path.join(root, "resources", "images", "Typio.tiff"))
    ap.add_argument("--preview", help="also write a light/dark comparison PNG to this path")
    args = ap.parse_args()

    rep1x = render_rep(1, args.glyph, args.weight, args.glyph_height, args.y_nudge)
    rep2x = render_rep(2, args.glyph, args.weight, args.glyph_height, args.y_nudge)
    write_tiff(rep1x, rep2x, args.out)
    print(f"wrote {args.out}")

    if args.preview:
        write_preview(rep2x, args.preview, os.path.join(root, "resources", "images", "him.png"))
        print(f"wrote {args.preview}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
