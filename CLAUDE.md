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

## Polish pass (2026-08-12)

Second, deeper pre-resubmission pass (batch 7, resubmits 2026-09-06) — this app carried the
highest risk in the whole 18-app wave since the 08-09 pass had found and fixed **sold-but-
never-built Pro features** (real purchasers may have paid for a 2-player mode and card backs
that didn't exist). Job this pass was to independently re-verify, with real interactive
evidence, that all four 08-09 fixes are genuinely solid — not just re-read the code.

**Verification method:** no idb/XCUITest tooling and no working GUI automation were available
in this environment (`osascript`/System Events hit an AppleEvent timeout — Accessibility
permission isn't granted here; `screencapture` also returned a black frame — Screen Recording
isn't granted either). Built a temporary XCUITest UI-test target instead (removed after use,
not committed) to drive real taps into the Simulator and capture screenshots as evidence —
this is the only way to get genuine tap-through verification, not just code review, in this
environment.

**(a) Local two-player pass-and-play — CONFIRMED GENUINELY WORKING.** Ran a real 2P match via
XCUITest: tapped "Local Two-Player" on Home, hit the "Pass the device to Player 1" gate, tapped
"I'm ready", played a real card as Player 1, confirmed the turn correctly flipped — a *second*
pass gate appeared ("Pass the device to Player 2"), and Player 2's hand became the active
face-up/tappable hand while Player 1's flipped face-down. This is real `GameModel.currentTurn`
alternation exercised through actual taps, not a static demo screen.

**(b) Alternate card backs — CONFIRMED GENUINELY WORKING, but found and fixed one real gap.**
As Pro, selected Sakura in the picker, started a live vsAI match, and confirmed the opponent's
face-down hand rendered the Sakura gradient/icon in the real game table (not just the picker
swatch). As free user (fresh Release build — DEBUG always forces `isPro=true`, so this had to
be a genuine Release-config install to test honestly), confirmed Play—Hard and Local Two-Player
both show lock icons and gate to the paywall. **Real bug found:** once `isPro` was true, there
was **no live path back into `UpgradeView`** — both Home entry points that used to open it
(`Hard AI`, `Local Two-Player`) route straight into gameplay once Pro, and the "Unlock Pro"
teaser button was wrapped in `if !purchases.isPro`. A paying customer could pick a card back
once, right after purchasing, but could never revisit the picker again after dismissing that
sheet. **Fixed:** `HomeView`'s teaser button is now always shown, unconditionally opening
`UpgradeView`, with its label swapping to "Card Back Style" once Pro (`home.cardBackSettings`,
added to both `.lproj` files).

**(c) Localization — found and fixed a real, serious bug: live language switch was broken.**
Diffed `en.lproj`/`ja.lproj` key sets — still identical (164 keys each after this pass's
addition). But a live, mid-session XCUITest language switch (tap the 日本語 segment, no
relaunch) proved the UI **did not re-render** — waited 6s, screenshotted every second, still
showed English text, even though the segmented control's selection visibly toggled. Root
cause: `LocalizationManager.language`'s `didSet` only persisted the raw value to
`UserDefaults` — it never called `setLanguage(_:)`, the only method that swaps the internal
`bundle` used by `string(_:)`. The Home segmented Picker binds directly to `$loc.language`,
bypassing `setLanguage(_:)` entirely, so the picker toggled and persisted correctly (which is
why a *cold relaunch* showed the right language — the only verification the 08-09 pass had
done) but never actually re-rendered live. Same bug class already found in Ô Ăn
Quan/Tử Vi/Dara this session, just not yet caught here. **Fixed:** moved the bundle-swap into
`language`'s own `didSet`, so every mutation path stays consistent. Re-ran the same live-switch
test after the fix — Japanese text now renders within ~1 second of tapping, confirmed via
screenshot, no tofu boxes/mojibake.

**(d) Scoring — re-verified correct, no issues found.** Re-read `YakuScorer.swift` against the
documented point table in this file's Key Decisions — brights/animals/ribbons/chaff/moon-
viewing/flower-viewing all match, including the 3-bright rain-man exclusion and 4-bright
Shikou/Ame-Shikou split. Re-read `GameModel.settleHand()`'s koi-koi doubling fix — correctly
sums `koiKoiCalls[.player] + koiKoiCalls[.ai]` (both seats, not just the winner) and doubles by
`2^calls`, matching the standard rule and the 08-09 fix description. No regression.

**⚠️ Standing concern, not resolved this pass (out of scope per the task):** real Pro
purchasers before the 08-09 fix may have paid for a 2-player mode and card backs that didn't
exist yet. That business/refund question has not been raised with the user as of this pass —
flagging again here since it's the one open item this polish pass could not close.

**Screenshots — found and fixed real staleness.** The shipped screenshots (both locales) dated
from 2026-07-26, before *any* of the 08-09 work — no Local Two-Player button, no Card Back
Style/Yaku Guide links, no language picker, and obviously no 2P or card-back screens. Also
found the `ja` set was never real Japanese UI to begin with — `capture_shots_ja.py` only
overlaid a translated caption band on the *English* in-app UI, stale since the app became
genuinely bilingual. Recaptured both locales for real on a dedicated `HanafudaKoiKoi-Capture`
simulator (this batch runs 3 apps' capture scripts concurrently — a shared/default simulator
risks cross-app contamination): 6 screenshots per locale now (was 4), adding a real pass-and-
play screen and a real card-back-picker screen, ja captured with `HK_LANG=ja` for genuine
Japanese in-app UI. Also fixed three capture-script bugs found along the way:
`capture_shots.py`/`_ja.py` hardcoded `APP_DIR`/`REPO` to `/Users/user/HanafudaKoiKoi`, a path
that doesn't exist on this machine; the "home" capture scenario had no `HK_SKIP_ONBOARDING`
override, so on a fresh simulator it captured onboarding instead of Home; and `capture_shots.py`
never set `HK_LANG=en`, so a simulator that had previously been switched to Japanese (e.g. by
this pass's own UI-test run) leaked into the "English" screenshot set.

**ASO — description never mentioned the two real Pro features.** Pulled the live listing: the
copy was well-written (hand-authored Japanese, not machine-translated, consistent with house
style) but the *description* body never mentioned local two-player or card back customization
anywhere — only `whatsNew` did. Extended both locales' descriptions with a new "bring a friend"
section, added both features to the "play your way" bullets, and wrote new `promotionalText`
leading with them (was empty in both locales before this pass). Refreshed keywords: dropped
"solitaire" (en) / "一人プレイ" (ja) — both inaccurate now that real 2-player exists — for
"two player"/"pass n play" (en) and "2人対戦"/"パス&プレイ" (ja). Wrote fresh `whatsNew` for
both locales describing the scoring fix, the two delivered Pro features, full bilingual
localization, and the new Yaku Guide.

**Push-script bugs found and fixed** (`~/asc-tools/asc_push_hanafudakoikoi.py` +
`asc_push_hanafudakoikoi_screenshots.py` + `asc_push_hanafudakoikoi_review.py`):
- `find_app_info` (in both the metadata and review-info push scripts) keyed off
  `ai["attributes"]["state"]` instead of `appStoreState`. Confirmed live via the API that these
  are two different fields on the same appInfo resource — the live (READY_FOR_SALE) appInfo's
  `state` was `"READY_FOR_DISTRIBUTION"`, which was *in* the old "editable" tuple, so the old
  code would have silently patched the **live listing** instead of the actual REJECTED/editable
  one. Fixed to use `appStoreState` in both scripts (matches the Janggi bug from this session).
- `find_or_create_version` hardcoded `versionString: "1.0.0"` (now the live version) and forced
  `releaseType: "MANUAL"`. Fixed to target a `TARGET_VERSION` constant kept in sync with
  `project.yml` (now `1.1.1`) and the house-standard `releaseType: AFTER_APPROVAL`.
- `set_iap_localization` had no error handling — the Pro IAP is currently `IN_REVIEW` (locked),
  so pushing its localization 409s (`NAME`/`DESCRIPTION` unmodifiable in that state). Wrapped in
  try/except so this doesn't crash the whole push; confirmed the rest of the run (app-info +
  version metadata) completed successfully despite the IAP calls failing as expected.
- `asc_push_hanafudakoikoi_screenshots.py`'s `REPO` and both `asc_upload_hanafudakoikoi_*.py`
  scripts' `FILE_PATH` were hardcoded to `/Users/user/HanafudaKoiKoi` (nonexistent on this
  machine); fixed to resolve relative to `Path.home()`. The screenshot script's `ORDER` list
  also still referenced the old 4-file set (`03-yaku.png`/`04-matchover.png`) — updated to the
  new 6-file set.

**Pushed to App Store Connect, confirmed landed on the correct editable version.** Re-read the
listing after every push: `v1.0.1` was correctly found as the editable/REJECTED version, bumped
to **v1.1.1** (`releaseType=AFTER_APPROVAL`), en-US + ja metadata (name/subtitle/keywords/
description/promo/whatsNew) all landed there — `v1.0.0` (READY_FOR_SALE, live) was untouched.
All 12 screenshots (6 EN + 6 JA) uploaded and reordered correctly. IAP localization push
correctly no-op'd (locked, `IN_REVIEW`) — copy there was already accurate, nothing lost.

**Version bump:** `MARKETING_VERSION` 1.1.0 → **1.1.1**, `CURRENT_PROJECT_VERSION` 5 → **6**
(`project.yml`, both the `settings.base` and `targets.HanafudaKoiKoi.settings.base` blocks).

**Build:** `xcodegen generate` + Debug **and** Release builds for iOS Simulator, both clean, 0
warnings (besides the routine AppIntents notice) — verified after every code change this pass,
including after removing the temporary UI-test target.

**No ASC submit/review-submission action taken** — metadata + screenshot pushes only, per the
standing 2026-08-18+ staggered-resubmission plan. This app resubmits 2026-09-06 (batch 7, with
Ô Ăn Quan and Mythsmith).

## 7-day trial, then everything locks (2026-08-18)

Portfolio-wide standing rule now applies here: no app should offer free play at any
mode/difficulty forever, only a capped trial (same fix already applied to ChineseChess
and SamLoc after both shipped real downloads with **zero** IAP purchases — a permanently-
free tier was good enough that nobody ever needed to pay). This session's job was code-
prep-and-commit only, per the standing 2026-08-18+ staggered-resubmission plan — **nothing
submitted to App Store Connect**.

**What was gated before:** Easy AI and Normal AI were fully, permanently free (no trial,
no expiry) — the complete single-player game with full rules, full yaku scoring, and no
ads. Only Hard AI, Local Two-Player (pass-and-play), and alternate card backs were ever
behind the `hanafudakoikoi.pro` IAP. That free Easy/Normal tier was a real risk of the
same zero-purchase pattern seen on ChineseChess/SamLoc.

**What's gated now:** `PurchaseManager.swift` gained `trialActive`/`trialDaysRemaining`
backed by a `firstLaunchDate` UserDefaults key (7-day `trialDuration`, `evaluateTrialStatus()`
called from `init()` alongside the existing transaction listener). `HomeView.isLocked(_:)`
now gates **all three difficulties** — Easy/Normal lock once the trial expires and the
user isn't Pro; Hard stays permanently gated exactly as before (it was never part of the
free tier, so the trial doesn't change its status — it's Pro-only from day one, same as
Local Two-Player and card backs, which were untouched since they were never free). Existing
installs with no stored `firstLaunchDate` get the clock started by this update rather than
being locked out immediately. Home now shows a "Free trial — N day(s) left" caption while
the trial is active, and the upgrade-teaser footnote switches to "Trial ended — unlock Pro
to keep playing →" once it expires. `UpgradeView` gained a new subtitle line (didn't exist
before this pass) that switches the same way between trial-active and trial-ended copy.

**Also fixed a latent bug found while in `PurchaseManager.swift`:** `updateEntitlementStatus()`'s
`#if DEBUG isPro = true` was a bare override with no capture-mode exemption — unlike the
already-correct pattern this app's own `ContentView.swift` uses for `HK_CAPTURE`/`HK_LANG`/
`HK_SKIP_ONBOARDING`. Fixed to double-gate the same way (matching the SamLoc/ChineseChess
reference pattern): `HK_CAPTURE=upgrade` now correctly forces `isPro=false` so that capture
mode's App Store screenshot shows the real locked/buy-button state instead of "already
purchased," and the plain `HK_SKIP_ONBOARDING` home capture stays Pro so its screenshot
still shows all destinations unlocked. (Note: the 2026-08-09 pass's CLAUDE.md claim of "no
DEBUG/isPro double-gating bug found here" was about a *different* bug class — two competing
isPro checks fighting each other — not this missing capture-mode exemption, which didn't
exist as a concept until this trial-clock work needed it.)

**New localization keys** (`home.upgradeTeaser.trialended`, `home.trialdays`,
`upgrade.subtitle`, `upgrade.subtitle.trialended`) added to both `en.lproj` and `ja.lproj`
`Localizable.strings`, hand-written Japanese (not machine-translated, matching this app's
existing house style) — key-set parity between the two locales re-verified via `diff` after
the addition. `upgrade.subtitle`/`.trialended` are net-new concepts for this app (SamLoc/
ChineseChess already had an `upgrade.subtitle`-equivalent; this app's `UpgradeView` had none
until this pass).

**Build verified:** `xcodebuild -scheme HanafudaKoiKoi -destination 'generic/platform=iOS'
-configuration Debug build` — clean `** BUILD SUCCEEDED **`, no `xcodegen generate` run (no
`project.yml` changes this pass), no version bump.

**NOT YET SUBMITTED to the App Store.** This is a real product change for existing/future
users of a live, previously-rejected version awaiting the 2026-09-06 (batch 7) resubmission
slot — held for the user's explicit go-ahead before any archive/export/upload/submit action,
same as every other pending item in this file.

## Build staged for resubmission (2026-08-13)

Archived, exported, and uploaded a Release build ahead of the staggered resubmission — still
blocked until 2026-08-18 by the Guideline 5.6 account-level hold, this app resubmits
**2026-09-06** (batch 7). Build **1.1.1 (6)** uploaded via
`xcrun altool --upload-app` (Delivery UUID `46031850-be74-4afa-a30a-4fa79159b712`), processed to `VALID` by Apple, and
attached to the existing `REJECTED` appStoreVersion (id `76783f43-3198-408c-b867-955d8b34567f`) via a direct
`PATCH appStoreVersions/{id}/relationships/build` API call — independently re-verified via a
follow-up `GET` on the same relationship, not just trusted from the PATCH's 204 response.
**Version-mismatch bug caught and fixed before this build was made.** `project.yml` had two settings blocks (top-level `settings.base` and a `targets.HanafudaKoiKoi.settings.base` override) — an earlier polish-pass commit's version bump had only updated the top-level block (to 1.1.1/6) while the target-level override, which wins at build time, was still 1.1.0/5. The first archive attempt would have silently shipped 1.1.0 (5) despite the polish-pass notes claiming 1.1.1 (6). Caught by unzipping the IPA and checking `CFBundleShortVersionString` directly rather than trusting the build log; fixed the target-level block and re-archived/re-exported/re-uploaded — the build referenced above is the corrected one, independently confirmed as 1.1.1 (6) inside the actual IPA.

**Deliberately NOT done yet** — waiting for the user's explicit go-ahead on this app's
scheduled date, per the staggered resubmission plan:
1. Tick the Pro IAP into this version in the App Store Connect **web UI** — the API has no
   way to do this; it must be done from the version's own page (not the IAP's own page, which
   creates an orphaned draft submission — a mistake this portfolio hit once before).
2. Submit for review.

## Instructions for Claude Code
At the end of every session, update the Current State section to reflect progress made.

## Reasoning Mode
You are a Koi-Koi player who grew up with the game, a game AI engineer, an iOS
developer, and a card-game UX designer. You know the real yaku list and scoring, the
capture-selection edge cases (multiple field matches, month sweeps), and the tension
that makes koi-koi/shoubu the heart of the game. If a requested change would break an
authentic rule or make the AI feel exploitable, say so before implementing it.
