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
- **2026-07-18 — v1.0.0 built and pushed end-to-end in one session, build uploaded to
  ASC, only two web-UI-only steps + Submit remain.**

  **Built:** full game engine (deck, capture resolution incl. multi-match picker and
  3-card sweep, yaku detection, koi-koi/shoubu flow, AI heuristics), SwiftUI table UI,
  StoreKit 2 Pro unlock, PIL-generated bold crane+sun icon. Builds clean for simulator
  and device.

  **Hosting:** repo at `github.com/qngo9871-cmyk/HanafudaKoiKoi`, GitHub Pages live at
  `qngo9871-cmyk.github.io/HanafudaKoiKoi/` serving `docs/privacy-policy.html` +
  `docs/support.html`.

  **ASC listing:** bundle `com.quyenngo.hanafudakoikoi` registered via API
  (`~/asc-tools/asc_register_hanafudakoikoi.py`, id=5LJ79JPT7J); Q created the app shell
  manually (id=6792249228, `POST /v1/apps` 403's as expected — Apple blocks that).
  Full metadata pushed for **en-US + ja** via `~/asc-tools/asc_push_hanafudakoikoi.py`:
  categories (GAMES/GAMES_CARD/GAMES_BOARD), name/subtitle/privacy URL per locale,
  keywords/description/promo/support URL per locale, the `.pro` non-consumable IAP with
  both locales' localizations. Japanese copy hand-written for JP ASO (title "花札
  こいこい - 定番カードゲーム", subtitle "AIと対戦できる本格こいこい"), not
  machine-translated — per [[feedback_aso_seo_default]].

  **Screenshots:** both locales' App Store screenshots uploaded (en-US real English UI,
  ja real UI + Japanese caption band) via `~/asc-tools/asc_push_hanafudakoikoi_screenshots.py`.
  Caught and fixed a real bug here: `capture_shots.py`'s font fallback is SF-Pro-only (no
  CJK glyphs) and PIL silently draws tofu-box placeholders instead of erroring — first ja
  batch was garbled, fixed via a `font_paths` override pointing at Hiragino for
  `capture_shots_ja.py`. Also uploaded: a private App Review attachment (paywall
  screenshot, `~/asc-tools/asc_upload_hanafudakoikoi_review_attachment.py`) AND the
  IAP's own separate review screenshot field (`~/asc-tools/asc_upload_hanafudakoikoi_iap_screenshot.py`
  — distinct resource, `inAppPurchaseAppStoreReviewScreenshots`, easy to miss).

  **Review/compliance fields:** age rating (all descriptors NONE/false → 4+), App Review
  Information (contact + detailed paywall-access notes), `contentRightsDeclaration`,
  version `copyright`/`usesIdfa` — all pushed via `~/asc-tools/asc_push_hanafudakoikoi_review.py`.

  **Pricing — solved via API, NOT UI** (earlier note that this needs the ASC UI was
  wrong; found the right endpoints): app base price Free + IAP $2.99 both set via
  `~/asc-tools/asc_pricing_hanafudakoikoi.py`. Gotchas: app price points are
  `GET /v1/apps/{id}/appPricePoints` (not a bare `/appPricePoints` — that 404s); IAP
  price points are `GET /v2/inAppPurchases/{id}/pricePoints`; but the price *schedule*
  POST for an IAP is `POST /v1/inAppPurchasePriceSchedules` (v1 base, NOT v2 — v2 404s).

  **Build:** archived + exported + uploaded + attached to version 1.0.0, all same
  session. `-exportArchive` initially failed ("No Accounts" / no App Store profile
  exists yet for a brand-new bundle ID) — fixed by adding
  `-authenticationKeyPath/-authenticationKeyID/-authenticationKeyIssuerID` flags
  pointing at the ASC API key, which let Xcode auto-create the missing distribution
  profile. Uploaded via `xcrun altool --upload-app`. Build 1 went PROCESSING → VALID in
  under a minute, then attached to the version via
  `PATCH appStoreVersions/{id}/relationships/build` (confirmed: `APP_STORE_ELIGIBLE`,
  custom crane+sun icon rendering correctly server-side).

  **🟢 SUBMITTED 2026-07-18, same session.** Q hit the exact documented trap once
  (clicked "Add for Review" from the IAP's own individual page first, which created an
  orphaned version-less draft — "Unable to Submit for Review: add an app version").
  Fixed by going to the version's own page instead and ticking the IAP there (the only
  UI path that bundles them into one submission — see the Fence AI 2.1(b) lesson).
  Confirmed via API: `reviewSubmissions` state `WAITING_FOR_REVIEW`, platform `IOS`,
  version 1.0.0 `appStoreState`/`appVersionState` both `WAITING_FOR_REVIEW`. App Privacy
  nutrition labels must have been filled by Q in the web UI too (no API exists for that
  field, and Apple won't allow submission without it) — not independently verified via
  API since there's no endpoint to check, but the successful submission implies it's done.

  Next check-in: watch for Apple's review outcome (approval or rejection) — typically
  24-48h. If rejected, check `GET /v1/apps/6792249228/reviewSubmissions` for the reason.

## Instructions for Claude Code
At the end of every session, update the Current State section to reflect progress made.

## Reasoning Mode
You are a Koi-Koi player who grew up with the game, a game AI engineer, an iOS
developer, and a card-game UX designer. You know the real yaku list and scoring, the
capture-selection edge cases (multiple field matches, month sweeps), and the tension
that makes koi-koi/shoubu the heart of the game. If a requested change would break an
authentic rule or make the AI feel exploitable, say so before implementing it.
