#!/usr/bin/env python3
"""Japanese-locale App Store screenshots. Real in-app UI captures with HK_LANG=ja
forcing the actual Japanese localization bundle (added 2026-08-09 — this used to run
the English UI with only a translated caption band, which was stale/misleading once
the app became genuinely bilingual), composited with a native-Japanese caption band.
Output: screenshots/final_ja/*.png"""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from capture_shots import APP_DIR, BUNDLE, build_app, compose, find_device

JA_FONT_PATHS = ["/System/Library/Fonts/Hiragino Sans GB.ttc",
                 "/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc",
                 "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"]

import subprocess
import time

OUT = APP_DIR / "screenshots" / "final_ja"
OUT.mkdir(parents=True, exist_ok=True)

SHOTS = [
    ("01-home",      "home",      "花札・こいこい\nごーすとっぷが一つに"),
    ("02-table",     "table",     "本格48枚の花札 —\n月・光・短冊で勝負"),
    ("03-twoplayer", "twoplayer", "友達と2人対戦 —\n1台の端末でパス&プレイ"),
    ("04-cardbacks", "upgrade",   "カード裏面を選べる —\n墨葉 or 桜"),
    ("05-yaku",      "yaku",      "本物の役を獲得 —\n三光、猪鹿蝶"),
    ("06-matchover", "matchover", "AI対戦 —\nかんたん・ふつう・むずかしい"),
]


def sh(*a, **k):
    return subprocess.run(a, check=True, capture_output=True, text=True, **k)


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
                       env={"SIMCTL_CHILD_HK_CAPTURE": cap, "SIMCTL_CHILD_HK_LANG": "ja",
                            "SIMCTL_CHILD_HK_SKIP_ONBOARDING": "1"}
                            | dict(__import__("os").environ),
                       capture_output=True)
        time.sleep(2)
        sh("xcrun", "simctl", "io", DEVICE, "screenshot", str(raw))
        compose(raw, headline, OUT / f"{shotname}.png", font_paths=JA_FONT_PATHS)
    raw.unlink(missing_ok=True)
    subprocess.run(["xcrun", "simctl", "terminate", DEVICE, BUNDLE], capture_output=True)
    print("==> done.", OUT)


if __name__ == "__main__":
    main()
