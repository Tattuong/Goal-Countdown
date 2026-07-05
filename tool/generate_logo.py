"""Generate Motivation Quotes square app logo (1024x1024, sharp corners)."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = Path(__file__).resolve().parents[1] / "assets" / "logo.png"

PURPLE = (108, 60, 224)
PINK = (255, 107, 157)
ORANGE = (255, 159, 67)
GOLD = (255, 215, 0)
WHITE = (255, 255, 255)
DEEP = (45, 27, 105)


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def square_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            tx = x / size
            ty = y / size
            t = tx * 0.5 + ty * 0.5
            r = lerp(DEEP[0], PURPLE[0], t * 0.6)
            g = lerp(DEEP[1], PINK[1], t * 0.45)
            b = lerp(DEEP[2], ORANGE[2], t * 0.35)
            px[x, y] = (r, g, b)
    return img


def draw_quote_marks(draw: ImageDraw.ImageDraw, cx: int, cy: int) -> None:
    for ox in (-120, 120):
        draw.rounded_rectangle(
            (cx + ox - 70, cy - 90, cx + ox + 70, cy + 90),
            radius=28,
            fill=(255, 255, 255, 35),
        )
    draw.text((cx - 155, cy - 95), "\u201C", fill=GOLD, font_size=180)
    draw.text((cx + 55, cy - 15), "\u201D", fill=GOLD, font_size=180)


def draw_star(draw: ImageDraw.ImageDraw, cx: int, cy: int, r: int, fill) -> None:
    points: list[tuple[float, float]] = []
    for i in range(10):
        angle = math.radians(-90 + i * 36)
        radius = r if i % 2 == 0 else r * 0.42
        points.append((cx + radius * math.cos(angle), cy + radius * math.sin(angle)))
    draw.polygon(points, fill=fill)


def draw_sparkles(draw: ImageDraw.ImageDraw, cx: int, cy: int) -> None:
    for ox, oy, scale in ((220, -220, 0.55), (-230, -180, 0.45), (240, 200, 0.4), (-210, 210, 0.35)):
        draw_star(draw, cx + ox, cy + oy, int(34 * scale), (255, 255, 255, 180))


def main() -> None:
    base = square_gradient(SIZE).convert("RGBA")
    overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    cx, cy = SIZE // 2, SIZE // 2
    draw.ellipse((cx - 360, cy - 360, cx + 360, cy + 360), fill=(255, 255, 255, 18))
    draw_sparkles(draw, cx, cy)

    card = (cx - 280, cy - 180, cx + 280, cy + 180)
    draw.rounded_rectangle(card, radius=48, fill=(255, 255, 255, 230))
    draw.rounded_rectangle(card, radius=48, outline=(255, 255, 255, 60), width=6)

    for i, width in enumerate((220, 180, 140)):
        y = cy - 40 + i * 48
        draw.rounded_rectangle(
            (cx - width // 2, y, cx + width // 2, y + 16),
            radius=8,
            fill=PURPLE if i == 0 else (PINK[0], PINK[1], PINK[2], 180),
        )

    draw_star(draw, cx - 220, cy - 130, 28, GOLD)
    draw_star(draw, cx + 210, cy + 120, 22, ORANGE)

    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((cx - 300, cy - 200, cx + 300, cy + 240), fill=(255, 255, 255, 35))
    glow = glow.filter(ImageFilter.GaussianBlur(50))

    composed = Image.alpha_composite(base, glow)
    composed = Image.alpha_composite(composed, overlay)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    composed.convert("RGB").save(OUT, format="PNG", optimize=True)
    print(f"Saved Motivation Quotes logo: {OUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
