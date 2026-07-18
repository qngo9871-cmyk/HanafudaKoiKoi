#!/usr/bin/env python3
"""Capture REAL in-app App Store screenshots for Hanafuda Koi-Koi Go-Stop via the
simulator and DEBUG HK_CAPTURE launch args (home|table|yaku|matchover).
Adds a night-teal/gold caption band. Every shot is the actual app UI (App Review 2.3.3);
DEBUG forces isPro so no lock/upgrade prompts leak into shots. Output: screenshots/final/*.png"""
import os, re, subprocess, time
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter

APP_DIR = Path("/Users/user/HanafudaKoiKoi")
PROJECT = APP_DIR / "HanafudaKoiKoi.xcodeproj"
SCHEME = "HanafudaKoiKoi"
BUNDLE = "com.quyenngo.hanafudakoikoi"
OUT = APP_DIR / "screenshots" / "final"; OUT.mkdir(parents=True, exist_ok=True)
W, H = 1320, 2868
BAND = 470

SHOTS = [
    ("01-home",      "home",      "Hanafuda, Koi-Koi\n& Go-Stop in one app"),
    ("02-table",     "table",     "The real 48-card deck —\nmonths, brights & ribbons"),
    ("03-yaku",      "yaku",      "Score real yaku combos —\nThree Brights, Boar-Deer-Butterfly"),
    ("04-matchover", "matchover", "Play vs AI —\nEasy, Normal or Hard"),
]


def sh(*a, **k): return subprocess.run(a, check=True, capture_output=True, text=True, **k)


def find_device():
    out = subprocess.run(["xcrun", "simctl", "list", "devices", "available"],
                         capture_output=True, text=True).stdout
    for line in out.splitlines():
        m = re.search(r"^\s*(iPhone .*Pro Max)\s+\(([0-9A-F\-]{36})\)", line)
        if m:
            return m.group(2), m.group(1)
    raise SystemExit("No available 'iPhone ... Pro Max' simulator found")


def build_app():
    sh("xcodebuild", "-project", str(PROJECT), "-scheme", SCHEME, "-configuration", "Debug",
       "-sdk", "iphonesimulator", "-derivedDataPath", str(APP_DIR / "build/sim"), "build",
       cwd=str(APP_DIR))
    app = APP_DIR / "build/sim/Build/Products/Debug-iphonesimulator/HanafudaKoiKoi.app"
    if not app.exists():
        raise SystemExit(f"built app not found at {app}")
    return app


DEFAULT_FONT_PATHS = ["/System/Library/Fonts/SFNSDisplay.ttf", "/System/Library/Fonts/SFNS.ttf",
                      "/System/Library/Fonts/Supplemental/Arial Bold.ttf"]


def font(size, paths=None):
    for c in (paths or DEFAULT_FONT_PATHS):
        if Path(c).exists():
            try: return ImageFont.truetype(c, size)
            except Exception: continue
    return ImageFont.load_default()


def lerp(a, b, t): return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def compose(raw_png, headline, out_png, font_paths=None):
    shot = Image.open(raw_png).convert("RGB").resize((W, H), Image.LANCZOS)
    canvas = Image.new("RGB", (W, H))
    d = ImageDraw.Draw(canvas)
    top, bot = (16, 22, 42), (10, 48, 36)   # night indigo -> pine green
    for y in range(H):
        d.line([(0, y), (W, y)], fill=lerp(top, bot, y / H))
    lines = headline.split("\n")
    size = 100
    max_w = W * 0.9
    f = font(size, font_paths)
    while size > 56 and max(d.textlength(line, font=f) for line in lines) > max_w:
        size -= 4
        f = font(size, font_paths)
    lh = int(size * 1.18)
    y = (BAND - lh * len(lines)) // 2 + 8
    for line in lines:
        w = d.textlength(line, font=f)
        d.text(((W - w) / 2, y), line, font=f, fill=(255, 210, 110)); y += lh
    avail_h = H - BAND - 70
    sw = int(W * 0.84); sh_ = int(shot.height * sw / shot.width)
    if sh_ > avail_h: sh_ = avail_h; sw = int(shot.width * sh_ / shot.height)
    shot = shot.resize((sw, sh_), Image.LANCZOS)
    mask = Image.new("L", (sw, sh_), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, sw, sh_], radius=54, fill=255)
    px = (W - sw) // 2; py = BAND + (avail_h - sh_) // 2 + 35
    shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle([px, py + 16, px + sw, py + sh_ + 16], radius=54, fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    canvas = Image.alpha_composite(canvas.convert("RGBA"), shadow).convert("RGB")
    canvas.paste(shot, (px, py), mask)
    canvas.save(out_png); print(f"  wrote {out_png.name}")


def main():
    DEVICE, name = find_device()
    print(f"==> device {name}")
    APP = build_app()
    subprocess.run(["xcrun", "simctl", "shutdown", DEVICE], capture_output=True)
    subprocess.run(["xcrun", "simctl", "boot", DEVICE], capture_output=True)
    sh("xcrun", "simctl", "bootstatus", DEVICE, "-b")
    subprocess.run(["xcrun", "simctl", "status_bar", DEVICE, "override", "--time", "9:41",
                    "--batteryLevel", "100", "--batteryState", "charged",
                    "--cellularBars", "4", "--wifiBars", "3"], capture_output=True)
    sh("xcrun", "simctl", "install", DEVICE, str(APP))
    raw = OUT / "_raw.png"
    for shotname, cap, headline in SHOTS:
        subprocess.run(["xcrun", "simctl", "terminate", DEVICE, BUNDLE], capture_output=True)
        subprocess.run(["xcrun", "simctl", "launch", DEVICE, BUNDLE],
                       env=dict(os.environ, SIMCTL_CHILD_HK_CAPTURE=cap), capture_output=True)
        time.sleep(2)
        sh("xcrun", "simctl", "io", DEVICE, "screenshot", str(raw))
        compose(raw, headline, OUT / f"{shotname}.png")
    raw.unlink(missing_ok=True)
    subprocess.run(["xcrun", "simctl", "terminate", DEVICE, BUNDLE], capture_output=True)
    print("==> done.", OUT)


if __name__ == "__main__":
    main()
