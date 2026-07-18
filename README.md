# Hanafuda Koi-Koi Go-Stop

A native iOS app for playing **Koi-Koi**, the classic 48-card hanafuda flower-matching
game — known as Koi-Koi in Japan, Go-Stop in Korea (Hwatu deck). Built with Swift and
SwiftUI, original vector card art (no licensed hanafuda artwork).

## Features

- **Play vs AI** — Easy, Normal, and Hard difficulty.
- **Full yaku scoring** — Five/Four/Three Brights, Boar-Deer-Butterfly, Poetry &amp; Blue
  Ribbons, Moon/Flower Viewing, Animals, Ribbons, Chaff.
- **Koi-Koi / Shoubu decision** — push for a bigger score or bank it, with compounding
  multipliers per Koi-Koi call.
- **Best-of-three matches** with running scores.

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

## Project Structure

```
HanafudaKoiKoi/
├── HanafudaKoiKoiApp.swift   # App entry point
├── ContentView.swift          # DEBUG capture-hook routing + HomeView
├── Core/
│   ├── HanafudaCard.swift    # Card model + canonical 48-card deck
│   ├── YakuScorer.swift      # Pure yaku scoring function
│   ├── AIPlayer.swift        # AI capture-choice + koi-koi heuristics
│   ├── GameModel.swift       # Game state machine (deal/capture/turns/scoring)
│   └── PurchaseManager.swift # StoreKit 2 Pro unlock
└── Views/
    ├── HomeView.swift
    ├── GameView.swift
    ├── CardView.swift
    └── UpgradeView.swift
```

## Getting Started

1. `xcodegen generate` (or run `./rebuild.sh`)
2. Open `HanafudaKoiKoi.xcodeproj` in Xcode.
3. Select an iOS simulator or device.
4. Build and run (⌘R).

## Screenshots

`python3 capture_shots.py` builds the app, boots the simulator, and captures real
in-app App Store screenshots via the `HK_CAPTURE` DEBUG launch-arg hook (home / table /
yaku / matchover) into `screenshots/final/`.
