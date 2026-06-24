# SquadUp — Free Fire & Ludo Tournament + Top-Up App

A Flutter mobile app (Android-first, also runs on web) for **Free Fire / Ludo tournaments**, a **wallet**, and a **game top-up + e-commerce store**. Brand name shown in-app: **SquadUp** (pubspec package name `squadup`; Android namespace `nexus.SquadUp`).

> **This README is written so any developer or AI assistant can understand the whole app and safely extend it.** Read the "Architecture", "Conventions", and "How to extend" sections before changing code.

---

## 1. What the app does (feature tour)

The app launches at a **Splash** → **Login/Register** (mock auth, any credentials work) → **Shell** (bottom-nav with 3 tabs).

**Bottom nav tabs (Shell):** `Shop · Home · Profile` (Home is the default center tab).

- **Home** — a launch **Notice popup** (image carousel, shows once per launch + on bell tap) + promo banners + **"CHOOSE YOUR GAME"** with 2 category cards:
  - **Free Fire** → modes grid (BR / CS / Lone Wolf / Free) → match list → match info → join flow.
  - **Ludo Game** → Ludo King / Auto Ludo → ludo match list (filter chips + JOIN cards + "Win SS" header button) → ludo join screen → win-screenshot **Upload Evidence** screen.
- **Shop** — promo banners + **TOP-UP STORE** (Free Fire diamonds / Ludo Kingpass coins, 3-step top-up flow with discount packs) + **GAMING STORE** (e-commerce product grid) + "Why Choose Us".
- **Profile** — user header + wallet balance, Account links (Edit Profile, Wallet, My Matches, Top Players), **Settings** (Dark Mode toggle), More (Share App, Match Rules, Terms, Developer, Logout).
- **Wallet** — balance card, Add Money (deposit → demo gateway), Withdraw (bKash/Nagad), Transaction history, how-to guides (bottom sheets).

**Currency:** Bangladeshi Taka `৳` via the global `taka(num)` helper in `app_constants.dart`.

---

## 2. Tech stack

| Concern | Choice |
|---|---|
| Framework | Flutter (Dart SDK `>=3.5.0 <4.0.0`), Material 3 |
| State management & routing | **GetX** (`get`) — named routes, `GetxController`, `GetxService`, `Obx` reactivity |
| Local persistence | `shared_preferences` (theme mode only) |
| Notifications | `flutter_local_notifications` (OS notifications; conditional import for web) |
| Permissions | `permission_handler` |
| External links | `url_launcher` |
| Date formatting | `intl` |
| Backend | **None — all data is mock** (`lib/app/data/mock/mock_data.dart`). `SessionService` simulates a backend with `Future.delayed`. |

**Removed on purpose (don't re-add without reason):** `webview_flutter` (unused), `carousel_slider` (replaced by a `PageView`), `flutter_easyloading` (replaced by `AppLoader`), `cupertino_icons` (unused).

---

## 3. Architecture

**Feature-first** layout. Shared infrastructure lives in `lib/app/`, each screen in `lib/features/<feature>/`.

```
lib/
├── main.dart                       # GetMaterialApp, theme wiring, text-scale clamp
├── app/
│   ├── core/                       # app-wide singletons & helpers (see below)
│   │   ├── app_constants.dart      # brand strings, asset paths, taka() formatter
│   │   ├── initial_binding.dart    # registers permanent services at startup
│   │   ├── theme_controller.dart   # dark/light ThemeMode (persisted) + system UI
│   │   ├── app_toast.dart          # premium TOP snackbars: success/error/warning/info
│   │   ├── app_dialogs.dart        # AppDialogs.confirm(...) themed dialog
│   │   ├── app_sheets.dart         # AppSheet.show(...) premium bottom sheet
│   │   ├── app_loader.dart         # AppLoader.show()/dismiss() overlay spinner
│   │   ├── app_links.dart          # AppLinks.open(url) external launcher
│   │   └── notice_popup.dart       # launch notice carousel (once/launch + bell)
│   ├── data/
│   │   ├── mock/mock_data.dart     # ALL demo data lives here
│   │   ├── models/                 # plain data classes (see §6)
│   │   └── services/               # GetxServices: session, notification, permission
│   ├── routes/
│   │   ├── app_routes.dart          # route NAME constants
│   │   └── app_pages.dart          # route name → screen widget (GetPage list)
│   ├── theme/                      # design tokens (see §5)
│   └── widgets/                    # reusable widgets (see §7)
└── features/                       # one folder per screen/area
    ├── splash/ auth/ shell/ home/ matches/ my_matches/
    ├── wallet/ shop/ profile/ edit_profile/ top_players/ misc/
```

**Service registration** (`initial_binding.dart`, called before the first frame in `main.dart`):
`ThemeController`, `SessionService`, `NotificationService`, `PermissionService` — all `Get.put(..., permanent: true)`. Access anywhere via `SessionService.to`, `ThemeController.to`, etc.

**Per-screen state**: screens create their controller inline with `Get.put(MyController())` inside `build`, and read mock data through `SessionService.to`.

---

## 4. Navigation / routes

Routes are centralized. **Always** add a name to `app_routes.dart` AND a `GetPage` to `app_pages.dart`. Navigate with `Get.toNamed(AppRoutes.x, arguments: ...)`; read args with `Get.arguments`.

| Route const | Path | Screen | Arguments |
|---|---|---|---|
| `splash` | `/` | SplashScreen | — |
| `login` / `register` | `/login` `/register` | Auth | — |
| `shell` | `/shell` | ShellScreen (tabs) | — |
| `freeFire` | `/free-fire` | FreeFireScreen (modes grid) | — |
| `ludo` | `/ludo` | LudoScreen (Ludo King/Auto) | — |
| `ludoMatchList` | `/ludo-match-list` | LudoMatchListScreen | `GameMode` |
| `ludoJoin` | `/ludo-join` | LudoJoinScreen | `FfMatch` |
| `uploadEvidence` | `/upload-evidence` | UploadEvidenceScreen (win SS) | — |
| `topup` | `/topup` | TopupScreen (3-step) | `TopupCategory` |
| `products` | `/products` | ProductsScreen (e-commerce) | — |
| `matchList` | `/match-list` | MatchListScreen (FF) | `GameMode` |
| `matchInfo` | `/match-info` | MatchInfoScreen | `FfMatch` |
| `joinMatch` | `/join-match` | JoinMatchScreen (FF) | `FfMatch` |
| `matchRules` | `/match-rules` | MatchRulesScreen | — |
| `myMatches` | `/my-matches` | MyMatchesScreen | — |
| `wallet` `deposit` `depositWebview` `withdraw` `transactions` | … | Wallet flow | deposit args: amount |
| `editProfile` `topPlayers` `terms` `developer` | … | Profile sub-screens | — |

---

## 5. Design system (theme tokens)

All visual constants live in `lib/app/theme/`. **Never hard-code colors/sizes in screens** — use these.

- **`app_colors.dart`** — brand palette + an important `BuildContext` extension `AppColorsX` for **theme-aware colors**:
  - `context.cBg`, `context.cBgAlt`, `context.cSurface`, `context.cSurfaceAlt`, `context.cBorder`, `context.cText`, `context.cTextDim`, `context.cTextMuted`.
  - These auto-switch between dark and light values. **Use `context.cX` for any background / surface / border / text color** in custom containers. Accent colors (`AppColors.primary` blue, `gold`, `matchesGreen`, `danger`, `winningTeal`, `killRed`, `silver`, `bronze`) stay the same in both themes.
- **`app_text_styles.dart`** — `AppTextStyles.h1/h2/h3/title/button/body1/body2/label/caption`. Fonts: **Baloo Da 2** (display/headings), **Google Sans** (body).
- **`app_spacing.dart`** — `AppSpacing.xs..huge`, `AppRadius.sm..pill`, `AppDurations.fast/base/slow`, `AppCurves.standard/spring/emphasized`.
- **`app_shadows.dart`** — `AppShadows.card/raised/glow(color)`.
- **`app_theme.dart`** — builds the Material 3 dark & light `ThemeData` (incl. floating-label `InputDecorationTheme`). `AppCard`, `StatCell`, `ListNavTile` etc. already read `Theme.of(context)` so they are theme-aware automatically.

**Light/Dark mode**: toggled from Profile → Settings → Dark Mode (`ThemeController.toggle()`), persisted in shared_preferences, and it also updates the system status/navigation bar.

---

## 6. Data layer

### Models (`lib/app/data/models/`)
- **`user_model.dart`** — `UserModel` (mirrors `/api/user/fetch_profile`).
- **`wallet_model.dart`** — `WalletModel`, `TransactionModel`, `TxType` enum.
- **`match_model.dart`** — `GameCategory` (Home categories), `GameMode` (FF modes & Ludo games), `Participant`, `FfMatch` (used for both FF and Ludo matches; `match.code` → `#M<id>`).
- **`misc_models.dart`** — `LeaderboardEntry`, `BannerItem` (promo banners; `image` + `route`/`url`), `NoticeItem` (popup; `image` + `route`/`url`), `ShopFeature`, `PaymentChannel`, `TopupPack` (`amount`,`unit`,`price`,`regularPrice`,`save`), `HowToSection`, `TopupCategory`, `Product`.
- **`notification_model.dart`** — `AppNotification`, `NotifType`.

### Mock data (`lib/app/data/mock/mock_data.dart`)
**This is the single source of truth for all demo content** — user, wallet, rules text (Bengali), game modes, ludo games, matches (FF + Ludo), leaderboard, home/shop banners, **notices**, **topup categories + packs**, **products**, withdraw channels. To change what the app shows, edit here.

### Services (`lib/app/data/services/`)
- **`session_service.dart`** (`SessionService.to`) — the **mock backend**. Reactive state: `user`, `wallet`, `matches`, `transactions`. Methods: `login/register/logout`, `refreshMatches`, `matchesForMode(key)`, `joinedMatches`, `joinMatch`, `deposit`, `withdraw`, `updateProfile`, `changePassword`. **Each method has a `Future.delayed` and a comment marking where a real REST call goes** (intended backend: `https://panel.playtourbd.com/api/`).
- **`notification_service.dart`** — in-app feed + OS notifications. `notifications/notif_platform.dart` does a conditional import (`notif_native.dart` on mobile, `notif_stub.dart` on web).
- **`permission_service.dart`** — requests notification + photos/storage permissions once on entering the app.

---

## 7. Reusable widgets & helpers (use these, don't reinvent)

| Helper | Usage |
|---|---|
| `AppToast.success/error/warning/info('msg')` | Premium animated **top** notification. Used app-wide instead of raw SnackBars. |
| `AppDialogs.confirm(title, message, destructive:, ...)` → `Future<bool>` | Themed confirm dialog (e.g. logout). |
| `AppSheet.show(title:, subtitle:, child:)` | Premium glass bottom sheet (forgot-password, share, how-to guides). |
| `AppLoader.show('status')` / `AppLoader.dismiss()` | Blocking overlay spinner (replaces flutter_easyloading). |
| `AppLinks.open(url)` | Open external URL/app (Telegram, YouTube, mailto). |
| `NoticePopup.show()` / `showIfFirstLaunch()` | Image notice carousel popup. |
| `PrimaryButton(label, onPressed, variant, icon, loading)` | Gradient action button (`ButtonVariant.blue/green/red`). |
| `AppCard`, `SectionHeader`, `StatCell`, `ListNavTile`, `EmptyState`, `StatusPill` | In `widgets/common_widgets.dart` — theme-aware building blocks. |
| `AuthField(label, hint, icon, controller, isPassword, textInputAction, onSubmitted)` | Labeled text field with **floating label** + keyboard "next/done" focus traversal. |
| `GlassSurface`, `PressableScale` | `widgets/glass.dart` — frosted blur surface + press-scale feedback. |
| `Skeleton`, `SkeletonList` | Shimmer loading placeholders. |
| `ResponsiveCenter(child:)` | Caps content width on tablets/large screens (wrap scrollable bodies with it). |
| `GameModeCard(mode, matchesFound, onTap)` | Shared image grid tile (Free Fire modes + Ludo games). |
| `PromoBanner(banners:)` | Auto-scrolling image banner carousel (taps open `route` or `url`). |

---

## 8. Build, run & validate

> ⚠️ **Local `flutter build` does NOT work in this Termux environment** (the `flutter` wrapper can't do heavy work here). Full APK/AAB builds run via **GitHub Actions**.

**CI build:** `.github/workflows/krinry-build.yml` — manual `workflow_dispatch` with inputs:
- `build_type`: debug / profile / release
- `output_type`: apk / appbundle / apk-split
- release builds add `--obfuscate --split-debug-info` and R8 minify + resource shrink (configured in `android/app/build.gradle.kts` + `android/app/proguard-rules.pro`).

**Local static validation IS possible** using the Flutter-bundled Dart SDK (verified working in Termux). Path:
```
/data/data/com.termux/files/usr/opt/flutter/bin/cache/dart-sdk/bin/dart
```
Run after any code change:
```bash
DART=/data/data/com.termux/files/usr/opt/flutter/bin/cache/dart-sdk/bin/dart
"$DART" pub get          # only after changing pubspec.yaml
"$DART" format lib/      # also a syntax check (only formats valid files)
"$DART" fix --apply lib/ # auto-fix lints (const, etc.)
"$DART" analyze lib/ test/   # MUST print "No issues found!" before pushing
```
Target state: **`dart analyze` reports zero issues.** Keep it green.

**Tests:** `test/taka_test.dart` covers the `taka()` formatter. Widget tests need the full Flutter tool (run in CI).

---

## 9. How to extend (recipes for common updates)

> **Golden rules:** (1) reuse the helpers in §7, (2) use `context.cX` theme colors + `AppSpacing`/`AppTextStyles` tokens, (3) put demo content in `mock_data.dart`, (4) add a route in BOTH `app_routes.dart` and `app_pages.dart`, (5) run `dart analyze` until clean, (6) never hard-code dark colors (breaks light mode).

**Add a new screen**
1. Create `lib/features/<area>/<name>_screen.dart` (a `StatelessWidget`/`StatefulWidget`).
2. Add a route const in `app_routes.dart` + a `GetPage` in `app_pages.dart`.
3. Navigate with `Get.toNamed(AppRoutes.<name>, arguments: ...)`.
4. Wrap the scrollable body in `ResponsiveCenter` and use theme tokens.

**Add / change a home or shop banner** — edit `MockData.homeBanners` / `shopBanners`. Each `BannerItem` takes `image` (asset path or `https` URL), and either `route: '/some-route'` (in-app) or `url: 'https://...'` (external).

**Add / change a launch notice** — edit `MockData.notices`. `NoticeItem` is image-only (square) with `route` or `url`. Drop the image in `assets/images/`, add it to `pubspec.yaml` assets, set `image:`.

**Add a top-up pack / category** — edit `MockData.topupCategories`. `TopupPack(amount, unit, price, regularPrice)`; the screen auto-renders the discount + "SAVE" badge. Add a `HowToSection` for help text and optional `guideImage`.

**Add a store product** — add a `Product` to `MockData.products` (name, icon, price, optional `oldPrice`).

**Add a tournament match** — add an `FfMatch` to `MockData.matches` with the correct `modeKey` (`br/cs/lone_wolf/free` for FF; `ludo_king/auto_ludo` for Ludo). It automatically appears in the right list and updates category badge counts.

**Add an image asset** — copy into `assets/images/`, list it under `flutter: assets:` in `pubspec.yaml`, add a path constant in `app_constants.dart`. **Compress large images** (a `cwebp` binary is available in this env): `cwebp -q 85 in.png -o out.webp`. Keep the bundle small. Do NOT list `assets/branding/` — those are source images for the icon/splash generators, not runtime assets.

**Change theme colors** — edit dark/light values in `app_colors.dart` (and the `AppColorsX` getters). Everything using `context.cX` updates automatically.

**Wire a real backend** — replace the mock bodies in `SessionService` (and `MockData` reads) with real HTTP calls. The method signatures and reactive `Rx` fields are already shaped for it; add an `http`/`dio` dependency and keep the same return types so the UI doesn't change.

---

## 10. Known constraints / TODO

- **Mock backend** — no real API yet (see `SessionService`). Wallet starts at `৳0`, so paid joins/withdraws are recorded but balances don't enforce funds.
- **Image picker is simulated** — `UploadEvidenceScreen` fakes the "screenshot attached" state (no `image_picker` dependency). Wire `image_picker` for real file selection.
- **Payment is mock** — top-up "Proceed to Pay" and product "Add to Cart" show success toasts only.
- **Demo links are placeholders** — Telegram/YouTube/Facebook URLs in `mock_data.dart` (`https://t.me/squadup`, etc.) should be replaced with real channels.
- **Branding mid-rename** — package `squadup`, Android namespace `nexus.SquadUp`; some references mention "Play Tour BD".

---

## 11. Project facts cheat-sheet (for AI)

- Entry: `lib/main.dart` → `SquadUpApp` → `GetMaterialApp` (initialRoute `/`).
- 67 Dart files, ~25 screens, GetX everywhere, Material 3, dark default + working light mode.
- Currency formatter: `taka(num)` in `app_constants.dart`.
- Theme-aware colors: `context.cSurface`, `context.cText`, etc. (extension in `app_colors.dart`).
- To validate edits locally: run the bundled `dart analyze lib/ test/` (must be clean). Full builds = CI only.
- All demo content: `lib/app/data/mock/mock_data.dart`.
