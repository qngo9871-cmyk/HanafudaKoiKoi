# Hanafuda Koi-Koi Go-Stop

Native iOS app for playing Koi-Koi (Japanese hanafuda flower-card matching game, also
known as Go-Stop in Korea with a Hwatu deck). Play vs AI at three difficulty levels.

## Stack
- iOS (Swift/SwiftUI), iOS 16.0+
- StoreKit 2 (Products.storekit present)
- No external APIs, fully offline
- XcodeGen (`project.yml`) — run `xcodegen generate` after editing project.yml

## Project Structure
- `HanafudaKoiKoi/Core/` — HanafudaCard (deck), YakuScorer, AIPlayer, GameModel, PurchaseManager
- `HanafudaKoiKoi/Views/` — HomeView, GameView, CardView, UpgradeView
- `rebuild.sh` — regenerate + rebuild
- `capture_shots.py` — real in-app App Store screenshots via `HK_CAPTURE` DEBUG hook

## Key Decisions
- Original vector card art (SwiftUI shapes + SF Symbols + text labels), not licensed
  hanafuda artwork — avoids any Nintendo/publisher IP question entirely, and is more
  legible to a Western audience unfamiliar with the traditional imagery.
- Free: Easy/Normal AI. Pro IAP ($2.99, `com.quyenngo.hanafudakoikoi.pro`): Hard AI,
  local two-player, alternate card backs.
- Title deliberately avoids "Hanafuda Koi-Koi" — that's a one-word-swap of the existing
  552-rating "Hanafuda・Koi Koi". Went with "Hanafuda Koi-Koi Go-Stop" instead: captures
  all three major search terms (Hanafuda/Koi-Koi/Go-Stop/Hwatu across subtitle), no
  exact collision, and is the only app naming both the Japanese and Korean traditions
  in-title — see the scout in memory `project_app_scout_20260718_hanafuda_buildgate`.
- Standard Koi-Koi yaku point table (Wikipedia-sourced): Gokou 10, Shikou 8, Ame-Shikou 7,
  Sankou 6, Ino-Shika-Chou 5, Tane 1+/card beyond 5, Tanzaku 1+/card beyond 5, Akatan 6,
  Aotan 6, Akatan+Aotan combo +10, Kasu 1+/card beyond 10, Tsukimi-zake 5, Hanami-zake 5.
  Point values vary slightly by regional house rules — this is a defensible standard
  set, not a bug if a purist disputes an exact number.

## Current State
- **2026-07-18 — v1.0.0, built end-to-end same session.** Full game engine (deck, capture
  resolution incl. multi-match picker and 3-card sweep, yaku detection, koi-koi/shoubu
  flow, AI heuristics), SwiftUI table UI, StoreKit 2 Pro unlock, PIL-generated bold
  crane+sun icon, 4 real in-app screenshots captured via DEBUG hook, privacy/support
  pages, ASO metadata drafted (see `docs/asc-metadata.md`). Builds clean for simulator
  and device (both verified this session). Bundle ID `com.quyenngo.hanafudakoikoi`
  registered via API (`~/asc-tools/asc_register_hanafudakoikoi.py`, id=5LJ79JPT7J). Q
  manually created the ASC app listing (id=6792249228) after `POST /v1/apps` 403'd as
  expected. Repo pushed to `github.com/qngo9871-cmyk/HanafudaKoiKoi`, GitHub Pages live
  at `qngo9871-cmyk.github.io/HanafudaKoiKoi/` serving `docs/privacy-policy.html` +
  `docs/support.html`. **2026-07-18 same session: full ASC metadata pushed for BOTH
  en-US and ja** via `~/asc-tools/asc_push_hanafudakoikoi.py` — categories
  (GAMES/GAMES_CARD/GAMES_BOARD), app name+subtitle+privacy URL per locale, version
  1.0.0 keywords/description/promo/support URL per locale, and the
  `com.quyenngo.hanafudakoikoi.pro` non-consumable IAP with en-US + ja localizations.
  Japanese copy hand-written for JP ASO (title "花札 こいこい - 定番カードゲーム",
  subtitle "AIと対戦できる本格こいこい"), not machine-translated from the English —
  per [[feedback_aso_seo_default]]. Screenshots still English-only (ja falls back to
  en-US set until localized — acceptable per [[project_appstore_localization_expansion]]).

  NOT YET submitted to App Store Connect — remaining steps needing Q or a further
  session: (1) IAP price tier in ASC UI ($2.99) + app base price Tier 0 (Free) — pricing
  API is fiddly, do this in the UI per CLAUDE.md; (2) App Privacy questionnaire (web UI
  only) — answer "no data collected"; (3) age rating questionnaire (4+, no gambling);
  (4) archive + upload via `xcrun altool --upload-app`; (5) tick the IAP into the
  version's own submission page (NOT the API, NOT the IAP's own page) before Submit for
  Review, per [[feedback_ios_submission_checklist]] and the Fence AI 2.1(b) lesson.

## Instructions for Claude Code
At the end of every session, update the Current State section to reflect progress made.

## Reasoning Mode
You are a Koi-Koi player who grew up with the game, a game AI engineer, an iOS
developer, and a card-game UX designer. You know the real yaku list and scoring, the
capture-selection edge cases (multiple field matches, month sweeps), and the tension
that makes koi-koi/shoubu the heart of the game. If a requested change would break an
authentic rule or make the AI feel exploitable, say so before implementing it.
