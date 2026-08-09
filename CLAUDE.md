# Hanafuda Koi-Koi Go-Stop

Native iOS app for playing Koi-Koi (Japanese hanafuda flower-card matching game, also
known as Go-Stop in Korea with a Hwatu deck). Play vs AI at three difficulty levels, or
pass-and-play locally against a second human (Pro).

**Status: 🟡 READY FOR RESUBMISSION AFTER 2026-08-18, pending Apple's Guideline 5.6 account
hold.** The whole developer account (19 apps, including this one) was hit with a Guideline
5.6 "Developer Code of Conduct — Review Suspended" flag, almost certainly triggered by
submitting ~19 similar template-style apps within an 8-day window (2026-08-01 through
2026-08-08). This is an account-level flag, not a per-app rejection — resubmission is
hard-blocked until 2026-08-18. Prior state: v1.0.1 (build 4) submitted 2026-08-02,
WAITING_FOR_REVIEW. **Do not touch App Store Connect or resubmit before 2026-08-18.**

## Stack
- iOS (Swift/SwiftUI), iOS 16.0+
- StoreKit 2 (Products.storekit present)
- No external APIs, fully offline
- XcodeGen (`project.yml`) — run `xcodegen generate` after editing project.yml
- Localization: manual bundle-swap `L()`/`LocalizationManager` (`Core/Localization.swift`),
  `en.lproj`/`ja.lproj` — same house pattern as PhomTaLa/SamLoc/etc.

## Project Structure
- `HanafudaKoiKoi/Core/` — HanafudaCard (deck), YakuScorer, AIPlayer, GameModel,
  PurchaseManager, Localization
- `HanafudaKoiKoi/Views/` — HomeView, GameView, CardView, UpgradeView, OnboardingView,
  YakuGuideView
- `rebuild.sh` — regenerate + rebuild
- `capture_shots.py` / `capture_shots_ja.py` — real in-app App Store screenshots via
  `HK_CAPTURE` DEBUG hook (not updated this pass for the new `yakuguide`/2-player scenarios —
  fine for now since no re-screenshot is planned before 2026-08-18)

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

  **🔴 REJECTED 2026-07-19** (build 2, submission `0b41f5f1`): Guideline 4.0 Design —
  "not optimized to support all screen sizes or resolutions," specifically iPad. App is
  `TARGETED_DEVICE_FAMILY: "1"` (iPhone-only) but iPad still runs iPhone-only apps in a
  compatibility window (Apple does not let you opt out of this), and Apple's reviewer
  tests it there. Root cause: `GameView`'s board (score header, opponent hand, 2 captured
  rows, 2-row field grid, message, player hand — all fixed sizes off a 58×81pt card) adds
  up to ~820pt of content, more than fits in the compat window's short viewport, so the
  bottom of the board (player hand / "your move" prompt) got clipped.

  **🟢 FIXED + RESUBMITTED 2026-07-29, same session.** `GameView` now wraps its body in a
  `GeometryReader` and derives `cardWidth`/`cardHeight`/gap sizes from a `scale` factor
  (`min(1.0, max(0.6, availableHeight / 820))`), threaded down into `fieldGrid`,
  `capturedRow`, and `capturePicker` as params instead of stored `let`s. Verified by
  installing the built app on an **iPad mini (A17 Pro) simulator** (real repro of Apple's
  compatibility-window path, launched via `SIMCTL_CHILD_HK_CAPTURE=table xcrun simctl
  launch` to jump straight to the table screen) — board now fits with room to spare, no
  clipping.

  Build 3 uploaded same as build 1's flow (`-authenticationKeyPath/-ID/-IssuerID` +
  `xcrun altool --upload-app`), `CURRENT_PROJECT_VERSION` bumped 2→3 in `project.yml`
  (check `GET /v1/apps/6792249228/builds` for the next unused version number before any
  future upload — duplicate build numbers are rejected). Resubmitted via the API using
  the cancel-old→attach-build→create-submission→attach-version→submit flow in memory
  `[[asc-resubmit-after-rejection]]` (old submission `0b41f5f1` canceled, new submission
  `5f16739f` created, build 3 attached to version, submitted — now `WAITING_FOR_REVIEW`).

  Migration note: this session was the first Mac-mini run of this project — `xcodegen`
  wasn't installed (`brew install xcodegen`) and `xcode-select` still pointed at
  CommandLineTools instead of `/Applications/Xcode.app` (needed `sudo xcode-select -s`,
  which required the user to run it from a real Terminal.app window since Claude Code's
  `!` prefix doesn't give sudo a real TTY for the password prompt).

  **2026-08-02 — 🟢 v1.0.1 (build 4) SUBMITTED, WAITING_FOR_REVIEW.** Bug found +
  fixed this session: despite build 3's resubmission going through cleanly, the
  `hanafudakoikoi.pro` IAP was never actually attached to any of the review
  submissions (including this one) — it sat at `READY_TO_SUBMIT` since launch
  while the app itself was `READY_FOR_SALE`, meaning nobody could buy Pro this
  whole time. Same root cause hit across this app portfolio this week, see Sam
  Loc's CLAUDE.md and `[[feedback_iap_must_ride_with_first_version_submission]]`.
  Fixed by bumping to v1.0.1, ticking the IAP into a new draft submission via the
  ASC web UI, attaching the new version via API, and submitting together.

  Next check-in: watch for Apple's review outcome on v1.0.1 (build 4) —
  typically 24-48h. If rejected again, check
  `GET /v1/apps/6792249228/reviewSubmissions` for the reason.

  **2026-08-09 — Pre-resubmission quality pass (code-only, no ASC actions).** The whole
  developer account got a Guideline 5.6 review-suspended flag for submitting 19
  similar apps in an 8-day window; this session's job was a genuine local review/fix
  pass on this app while the account is hard-blocked until 2026-08-18. Bumped to
  **v1.1.0, build 5** (`project.yml`).

  **Real bug fixed — koi-koi score-doubling was wrong.** `settleHand()` only doubled
  the winner's score by *their own* koi-koi calls (`koiKoiCalls[winner]`). Standard
  rule: the score doubles once per koi-koi call made during the hand *by either
  player* — the whole point of the mechanic is that calling koi-koi is a gamble that
  raises the stakes for whoever ends up winning, even if that turns out to be the
  opponent. Fixed to sum both seats' calls (`GameModel.swift`). This was silently
  under-scoring hands where the loser had called koi-koi and the winner hadn't —
  a real, user-visible scoring-correctness bug, not cosmetic.

  **Real bug fixed — Pro sold two features that didn't exist.** `UpgradeView` and
  the IAP's own `Products.storekit` description advertised "Local two-player mode"
  and "Alternate card back designs" as Pro perks; neither existed anywhere in the
  code (`HomeView` only had 3 AI-difficulty buttons, `CardBackView` was a single
  hardcoded design). Since v1.0.1 already shipped with this claim and may have real
  paying Pro purchasers, the fix was to build both features for real rather than
  quietly walk back the copy:
  - **Local two-player (pass-and-play)**: `GameModel` gained a `GameMode` (`vsAI` /
    `twoPlayer`). In `twoPlayer` mode seat `.ai` (labelled "Player 2") is human-driven
    through the same code paths as `.player` — capture-choice prompts, koi-koi/shoubu
    decisions (generalized to `callsKoiKoi()`/`callsShoubu()` keyed off `currentTurn`
    instead of hardcoded to `.player`), and hand-card selection
    (`selectFromHand(_:)`). `GameView` swaps which hand is face-up/tappable based on
    whose turn it is, relabels captured-row/score-header text ("Player 1"/"Player 2"
    instead of "You"/"Opponent"), and shows a full-screen "pass the device" privacy
    gate between turns so a player doesn't see the other's hand mid-pass. Entry point:
    "Local Two-Player" on Home, Pro-gated same as Hard AI.
  - **Alternate card backs**: `CardBackStyle` enum (Ink Leaf / Sakura, distinct
    gradient+accent+icon), a picker in `UpgradeView` (visible once Pro), persisted via
    `@AppStorage("cardBackStyle")`, read by `GameView` for whichever hand is face-down.
  - Also fixed a small related bug while in there: `UpgradeView` showed an infinite
    "loading product" spinner for Pro users who have nothing left to buy — reordered
    the condition to check `isPro` first.
  - Verified via DEBUG capture-hook screenshots (`HK_CAPTURE=upgrade`) that the picker
    renders and both styles are visually distinct in both languages. **Not verified via
    live interactive tap-through** — no idb/XCUITest tooling available in this
    environment (same documented limitation as sibling apps' review passes); the
    turn-swap/pass-gate logic is verified by code review + the deterministic capture
    scenarios (which exercise real `GameModel` state), not a live full two-player game.

  **Bilingual localization added — was entirely missing.** Despite the App Store
  listing itself being bilingual (en-US + hand-written ja per the Key Decisions above),
  there was **zero in-app localization infrastructure** — no `.lproj`, no
  `NSLocalizedString`, no `L()` — every on-screen string, including all 25 card names
  and all 13 yaku names, was hardcoded English. This violates the standing
  bilingual-by-default rule. Fixed properly, matching the house `L()`/
  `LocalizationManager` pattern used by PhomTaLa/SamLoc/etc. (manual bundle-swap so
  language changes live without relaunching):
  - `Core/Localization.swift` (new), `en.lproj`/`ja.lproj/Localizable.strings` (new,
    ~180 keys each, verified identical key sets via `diff`).
  - Every card name and yaku name is now looked up via `nameKey`/`localizedName`
    (`HanafudaCard`, `Yaku` in `YakuScorer.swift`) rather than a hardcoded English
    string — the Japanese card/yaku names are the **authentic traditional terms**
    (松, 鶴, 五光, 猪鹿蝶, 赤短, etc.), not transliterations of the English, since this
    is a real Japanese game and those terms are public-domain game vocabulary (not the
    licensed artwork this app deliberately avoids).
  - Language picker (segmented, EN/日本語) on Home, persisted across launches. Debug
    hook `HK_LANG` added to `ContentView` for capture scripts, mirroring `HK_CAPTURE`.
  - Verified via DEBUG capture-hook screenshots in both languages across all screens
    (home, onboarding, table/yaku-prompt, match-over, upgrade, yaku guide) — correct
    Japanese rendering (Hiragino, no tofu boxes/mojibake), no untranslated strings, no
    layout breakage from longer/shorter Japanese text.

  **Yaku scoring guide added.** The existing onboarding (4-page walkthrough) explained
  the *mechanic* of yaku/koi-koi but never listed the actual yaku or their point
  values — didn't fully satisfy the standing "explain the scoring" rule. Added
  `YakuGuideView` (new): all 13 yaku with point value + plain-language description,
  reachable from Home ("Yaku Guide") and from Onboarding's "Collect Yaku" page ("See
  the full Yaku Guide →"). `YakuScorer.referenceList` is the static data source.

  **Reviewed and confirmed already correct:**
  - Yaku detection logic (`YakuScorer.swift`) — re-verified every yaku against the
    standard rule set: brights (5/4/3, rain-man exclusion on 3-bright and the
    Shikou/Ame-Shikou split on 4-bright are both correctly implemented), Tane/Ino-
    Shika-Chou, Tanzaku/Akatan/Aotan/combo, Kasu, Tsukimi-zake/Hanami-zake. The 48-card
    deck (`HanafudaCard.swift`) matches the real hanafuda deck exactly: 5 brights, 9
    animals, 10 ribbons (3 poetry + 3 plain-red + 3 blue + 1 plain), 24 chaff.
  - `PurchaseManager`'s `#if DEBUG { isPro = true }` is the only DEBUG special-case in
    the purchase path and doesn't double-gate against any other isPro check — no
    instance of this developer's recurring DEBUG/isPro double-gating bug found here.
  - No TODO/FIXME/placeholder/Lorem-ipsum/dummy text anywhere in the source tree (full
    grep sweep, zero hits, before and after this pass).
  - `xcodegen generate` + both Debug and Release builds for iOS Simulator: clean, zero
    warnings besides the routine "no AppIntents.framework dependency" notice,
    `BUILD SUCCEEDED`. Toolchain (`xcodegen`, `xcode-select`) confirmed working.

  **Differentiation work this pass:** local two-player and alternate card backs (above)
  are genuinely new functionality, not just bug fixes — but they were scoped as bug
  fixes (undelivered paid features) rather than discretionary differentiation, per the
  "prioritize correctness over redesign" guidance for this review wave. The Yaku Guide
  is the one purely-additive differentiation piece.

  **Still open / left for a future pass (not blocking resubmission):**
  - No live device sideload or interactive tap-through (idb/XCUITest) of a full local
    two-player match was performed — code-review + capture-scenario verification only.
    If time allows before 2026-08-18, worth a manual playtest specifically of the
    pass-and-play flow (turn handoff, capture-choice prompts on Player 2's turn,
    koi-koi decision on Player 2's turn) since it's the least-tested new surface.
  - `capture_shots.py`/`capture_shots_ja.py` were not updated for the new `yakuguide`
    scenario or a local-two-player screenshot — not needed unless a screenshot refresh
    is planned before resubmission.
  - Card-back designs are palette-only (no new art/texture) — fine for now, same
    "revisit if conversion data justifies it" note as sibling apps.

## Instructions for Claude Code
At the end of every session, update the Current State section to reflect progress made.

## Reasoning Mode
You are a Koi-Koi player who grew up with the game, a game AI engineer, an iOS
developer, and a card-game UX designer. You know the real yaku list and scoring, the
capture-selection edge cases (multiple field matches, month sweeps), and the tension
that makes koi-koi/shoubu the heart of the game. If a requested change would break an
authentic rule or make the AI feel exploitable, say so before implementing it.
