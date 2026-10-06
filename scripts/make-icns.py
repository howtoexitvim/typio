import os, subprocess, tempfile
from PIL import Image, ImageDraw, ImageFont

SF_PRO = "/System/Library/Fonts/SFNS.ttf"
def load_font(px: int) -> ImageFont.FreeTypeFont:
    font = ImageFont.truetype(SF_PRO, px)
    font.set_variation_by_axes([100, 17, 400, 700])
    return font

def make_icon(size):
    # Let's make an app icon that looks like the menu bar icon (grey/black squircle with white T)
    # App icons are typically squircle. But let's just make it a nice dark grey box with a white T.
    big = size * 4
    plate = Image.new("RGBA", (big, big), (0,0,0,0))
    draw = ImageDraw.Draw(plate)
    # Draw dark grey rounded rectangle
    draw.rounded_rectangle((0, 0, big-1, big-1), radius=big*0.22, fill=(40, 40, 40, 255))

    glyph = "T"
    font = load_font(int(big * 0.6))
    l, t, r, b = font.getbbox(glyph)
    ink_w, ink_h = r - l, b - t

    text = Image.new("RGBA", (big, big), (0,0,0,0))
    x = (big - ink_w) / 2 - l
    y = (big - ink_h) / 2 - t
    ImageDraw.Draw(text).text((x, y), glyph, font=font, fill=(255,255,255,255))

    plate.paste(text, (0,0), text)
    return plate.resize((size, size), Image.LANCZOS)

out_dir = "/tmp/Typio.iconset"
os.makedirs(out_dir, exist_ok=True)
for s in [16, 32, 64, 128, 256, 512]:
    make_icon(s).save(f"{out_dir}/icon_{s}x{s}.png")
    make_icon(s*2).save(f"{out_dir}/icon_{s}x{s}@2x.png")
subprocess.run(["iconutil", "-c", "icns", out_dir, "-o", "../resources/images/him.icns"], check=True)
