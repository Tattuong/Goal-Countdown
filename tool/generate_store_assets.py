"""Generate 5 Google Play listing images for Motivation Quotes."""
from __future__ import annotations

import textwrap
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "store_assets"
LOGO = ROOT / "assets" / "logo.png"

PURPLE = (108, 60, 224)
PINK = (255, 107, 157)
ORANGE = (255, 159, 67)
GOLD = (255, 215, 0)
WHITE = (255, 255, 255)
DARK = (18, 22, 38)
SURFACE = (255, 255, 255)
MUTED = (180, 190, 210)


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def gradient(size: tuple[int, int], c1, c2, c3=None, vertical=True) -> Image.Image:
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = (y / h if vertical else x / w)
            if c3 is None:
                r = lerp(c1[0], c2[0], t)
                g = lerp(c1[1], c2[1], t)
                b = lerp(c1[2], c2[2], t)
            else:
                t2 = t * 2
                if t2 < 1:
                    r = lerp(c1[0], c2[0], t2)
                    g = lerp(c1[1], c2[1], t2)
                    b = lerp(c1[2], c2[2], t2)
                else:
                    r = lerp(c2[0], c3[0], t2 - 1)
                    g = lerp(c2[1], c3[1], t2 - 1)
                    b = lerp(c2[2], c3[2], t2 - 1)
            px[x, y] = (r, g, b)
    return img


def load_font(size: int, bold=False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            continue
    return ImageFont.load_default()


def paste_logo(base: Image.Image, box: tuple[int, int, int, int]) -> None:
    if not LOGO.exists():
        return
    logo = Image.open(LOGO).convert("RGBA")
    x1, y1, x2, y2 = box
    logo = logo.resize((x2 - x1, y2 - y1), Image.Resampling.LANCZOS)
    base.paste(logo, (x1, y1), logo)


def draw_rounded_rect(draw: ImageDraw.ImageDraw, box, radius, fill, outline=None, width=0):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def draw_status_bar(draw: ImageDraw.ImageDraw, w: int, dark=False):
    color = WHITE if not dark else (220, 220, 230)
    draw.text((48, 42), "9:41", fill=color, font=load_font(28))
    draw.text((w - 130, 42), "●●●", fill=color, font=load_font(22))


def draw_nav_bar(draw: ImageDraw.ImageDraw, w: int, h: int, active: int, labels: list[str]):
    y = h - 150
    draw.rounded_rectangle((24, y, w - 24, h - 36), radius=28, fill=(255, 255, 255, 28) if False else (30, 34, 52))
    slot = (w - 48) // len(labels)
    icons = ["☀", "◎", "♥", "★", "⚙"]
    for i, label in enumerate(labels):
        cx = 24 + slot * i + slot // 2
        col = PURPLE if i == active else MUTED
        if i == active:
            draw.rounded_rectangle((cx - 46, y + 12, cx + 46, y + 108), radius=18, fill=(108, 60, 224, 40))
        draw.text((cx - 12, y + 22), icons[i], fill=col, font=load_font(28))
        draw.text((cx - 38, y + 62), label, fill=col, font=load_font(18, bold=(i == active)))


def wrap_text(text: str, width: int) -> str:
    return "\n".join(textwrap.wrap(text, width=width))


def screenshot_base(title: str, subtitle: str, gradient_colors) -> Image.Image:
    w, h = 1080, 1920
    base = gradient((w, h), *gradient_colors).convert("RGBA")
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    draw_status_bar(draw, w)
    draw.text((48, 110), title, fill=WHITE, font=load_font(52, bold=True))
    draw.text((48, 178), subtitle, fill=(255, 255, 255, 210), font=load_font(26))

    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    g = ImageDraw.Draw(glow)
    g.ellipse((w - 420, -120, w + 80, 380), fill=(255, 255, 255, 35))
    glow = glow.filter(ImageFilter.GaussianBlur(60))
    base = Image.alpha_composite(base, glow)
    return Image.alpha_composite(base, overlay)


def draw_quote_card(draw: ImageDraw.ImageDraw, box, quote: str, author: str):
    x1, y1, x2, y2 = box
    draw_rounded_rect(draw, box, 32, (255, 255, 255, 245))
    draw.text((x1 + 36, y1 + 28), "\u201C", fill=GOLD, font=load_font(64, bold=True))
    wrapped = wrap_text(quote, 28)
    draw.multiline_text((x1 + 36, y1 + 90), wrapped, fill=(35, 35, 45), font=load_font(34), spacing=12)
    line_y = y2 - 90
    draw.rounded_rectangle((x1 + 36, line_y, x1 + 100, line_y + 8), radius=4, fill=PURPLE)
    draw.text((x1 + 120, line_y - 8), author, fill=(100, 105, 120), font=load_font(24))


def make_screenshot_daily() -> Image.Image:
    img = screenshot_base("Quote of the Day", "Tuesday, June 16, 2026", (PURPLE, PINK, ORANGE))
    draw = ImageDraw.Draw(img)
    draw_quote_card(
        draw,
        (60, 520, 1020, 980),
        "The only way to do great work is to love what you do.",
        "Steve Jobs",
    )
    for i, (icon, label) in enumerate([("♥", "Favorite"), ("↗", "Share"), ("↻", "Next")]):
        cx = 180 + i * 300
        draw.ellipse((cx - 52, 1080, cx + 52, 1184), fill=(255, 255, 255, 55))
        draw.text((cx - 14, 1108), icon, fill=WHITE, font=load_font(32))
        draw.text((cx - 42, 1200), label, fill=(255, 255, 255, 220), font=load_font(20))
    draw_nav_bar(draw, 1080, 1920, 0, ["Today", "Explore", "Fav", "Shop", "Set"])
    return img.convert("RGB")


def make_screenshot_explore() -> Image.Image:
    img = screenshot_base("Explore", "Find inspiration by category", ((45, 27, 105), PURPLE, PINK))
    draw = ImageDraw.Draw(img)
    cats = ["All", "Success", "Motivation", "Dreams", "Wisdom"]
    x = 48
    for i, cat in enumerate(cats):
        w = 140 + len(cat) * 8
        col = PURPLE if i == 0 else (255, 255, 255, 40)
        text_col = WHITE if i == 0 else (230, 230, 240)
        draw.rounded_rectangle((x, 250, x + w, 310), radius=22, fill=col)
        draw.text((x + 18, 262), cat, fill=text_col, font=load_font(22, bold=(i == 0)))
        x += w + 16
    quotes = [
        ("Believe you can and you're halfway there.", "Theodore Roosevelt"),
        ("Dream it. Wish it. Do it.", "Unknown"),
        ("Be the change you wish to see in the world.", "Mahatma Gandhi"),
    ]
    y = 360
    for q, a in quotes:
        draw_quote_card(draw, (48, y, 1032, y + 220), q, a)
        y += 250
    draw_nav_bar(draw, 1080, 1920, 1, ["Today", "Explore", "Fav", "Shop", "Set"])
    return img.convert("RGB")


def make_screenshot_favorites() -> Image.Image:
    img = Image.new("RGB", (1080, 1920), (245, 247, 255))
    draw = ImageDraw.Draw(img)
    draw_status_bar(draw, 1080, dark=True)
    draw.text((48, 110), "Favorites", fill=DARK, font=load_font(52, bold=True))
    draw.text((48, 178), "Your saved inspiration", fill=(100, 105, 120), font=load_font(26))
    quotes = [
        ("It does not matter how slowly you go as long as you do not stop.", "Confucius"),
        ("The future belongs to those who believe in the beauty of their dreams.", "Eleanor Roosevelt"),
        ("Start where you are. Use what you have. Do what you can.", "Arthur Ashe"),
    ]
    y = 280
    for q, a in quotes:
        draw_quote_card(draw, (48, y, 1032, y + 240), q, a)
        draw.text((960, y + 16), "♥", fill=PINK, font=load_font(28))
        y += 280
    draw_nav_bar(draw, 1080, 1920, 2, ["Today", "Explore", "Fav", "Shop", "Set"])
    return img


def make_screenshot_shop() -> Image.Image:
    img = Image.new("RGB", (1080, 1920), (240, 242, 250))
    draw = ImageDraw.Draw(img)
    draw_status_bar(draw, 1080, dark=True)
    draw.text((48, 110), "Shop", fill=DARK, font=load_font(52, bold=True))
    draw.text((48, 178), "Earn stars or buy more to unlock", fill=(100, 105, 120), font=load_font(26))

    draw.rounded_rectangle((48, 260, 1032, 430), radius=32, fill=WHITE)
    draw.text((90, 300), "Your star wallet", fill=(100, 105, 120), font=load_font(24))
    draw.text((90, 340), "1,250", fill=PURPLE, font=load_font(72, bold=True))
    draw.text((280, 372), "stars", fill=(100, 105, 120), font=load_font(28))
    draw.text((820, 328), "+ Buy", fill=WHITE, font=load_font(26, bold=True))

    items = [
        ("Remove ads", "Hide banner ads", "500 ★", PURPLE),
        ("Sunset theme", "Warm coral tones", "200 ★", ORANGE),
        ("Glass card skin", "Frosted quote card", "180 ★", PINK),
        ("Unlimited favorites", "Save every quote", "300 ★", (0, 184, 148)),
    ]
    y = 470
    for name, desc, price, accent in items:
        draw.rounded_rectangle((48, y, 1032, y + 130), radius=24, fill=WHITE)
        draw.rounded_rectangle((72, y + 24, 152, y + 104), radius=18, fill=accent)
        draw.text((96, y + 44), "★", fill=WHITE, font=load_font(28))
        draw.text((180, y + 28), name, fill=DARK, font=load_font(28, bold=True))
        draw.text((180, y + 68), desc, fill=(100, 105, 120), font=load_font(22))
        draw.text((860, y + 48), price, fill=GOLD, font=load_font(24, bold=True))
        y += 150
    draw_nav_bar(draw, 1080, 1920, 3, ["Today", "Explore", "Fav", "Shop", "Set"])
    return img


def make_feature_graphic() -> Image.Image:
    w, h = 1024, 500
    base = gradient((w, h), (45, 27, 105), PURPLE, PINK, vertical=False).convert("RGBA")
    overlay = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    for i in range(6):
        draw.ellipse((700 + i * 40, -80 + i * 20, 980 + i * 40, 200 + i * 20), outline=(255, 255, 255, 25), width=2)

    paste_logo(base, (56, 118, 176, 238))

    draw.text((210, 130), "Motivation Quotes", fill=WHITE, font=load_font(58, bold=True))
    draw.text((210, 210), "Daily inspiration · Favorites · Beautiful themes", fill=(255, 255, 255, 220), font=load_font(26))
    draw.text((210, 270), "Earn stars · Unlock premium · Widget ready", fill=(255, 255, 255, 180), font=load_font(22))

    card = (620, 90, 980, 410)
    draw_rounded_rect(draw, card, 24, (255, 255, 255, 230))
    draw.text((650, 120), "\u201C", fill=GOLD, font=load_font(48, bold=True))
    draw.multiline_text(
        (650, 170),
        wrap_text("Believe you can and you're halfway there.", 16),
        fill=(35, 35, 45),
        font=load_font(24),
        spacing=8,
    )
    draw.text((650, 350), "— Theodore Roosevelt", fill=(100, 105, 120), font=load_font(18))

    stars = [(880, 60), (940, 100), (900, 420), (960, 380)]
    for sx, sy in stars:
        draw.text((sx, sy), "★", fill=GOLD, font=load_font(22))

    return Image.alpha_composite(base, overlay).convert("RGB")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    assets = [
        ("01_feature_graphic_1024x500.png", make_feature_graphic),
        ("02_screenshot_daily_quote.png", make_screenshot_daily),
        ("03_screenshot_explore.png", make_screenshot_explore),
        ("04_screenshot_favorites.png", make_screenshot_favorites),
        ("05_screenshot_shop.png", make_screenshot_shop),
    ]
    for name, fn in assets:
        path = OUT / name
        fn().save(path, format="PNG", optimize=True)
        print(f"Saved {path}")

    print(f"\nDone — 5 Google Play assets in: {OUT}")


if __name__ == "__main__":
    main()
