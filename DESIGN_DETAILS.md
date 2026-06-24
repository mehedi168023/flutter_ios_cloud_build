# PlayTour BD — Design Details (Reverse-Engineered Blueprint)

> Source: decompiled APK at `~/cloneapp` (`com.sweez.playtour`, label "Play Tour").
> This document is a **UI/architecture recreation reference** derived from extracted
> assets, the Dart AOT string table (`libapp.so`), and Android resources.
> **No original source code was recovered** — only public strings, asset names,
> route names, and JSON field keys visible in the compiled binary.

---

## 1. App Identity

| Property | Value |
|---|---|
| Package | `com.sweez.playtour` |
| Display name | **Play Tour** |
| Original engine | Flutter (AOT) + **GetX** state management (confirmed: `GetMaterialController`, `*Binding`, `*Controller`) |
| Backend host | `https://panel.playtourbd.com/api/` |
| Website | `https://playtourbd.com` |
| Firebase project | `play-tour-3f489` (FCM push, sender `323460754747`) |
| Domain | Free Fire esports tournament / wallet app (Bangladesh) |
| Vendor | sweez.xyz |

> Recreation target: **Flutter latest stable + GetX** (matches original arch) or
> Riverpod if preferred. This doc assumes GetX to mirror the original 1:1.

---

## 2. Color Palette (from `logo.png` + `splash_background`)

| Token | Hex | Usage |
|---|---|---|
| `bgDark` | `#101722` | App background / splash (`splash_background` in resources) |
| `surface` | `#1A2230` | Cards, sheets (derived, +1 lightness step) |
| `surfaceAlt` | `#232D3D` | Elevated cards, inputs |
| `primaryBlue` | `#3E90D8` | Brand accent (logo strokes, buttons, links) |
| `primaryBlueLight` | `#5BA8E8` | Gradients, highlights |
| `accentOrange` | `#FF6B2C` | Muzzle-flash accent, prize/CTA highlights |
| `accentYellow` | `#F5A623` | Coins / winnings / warnings |
| `danger` | `#D93025` | Errors, "Account Banned", decline |
| `success` | `#1D873B` | Joined / success states |
| `textPrimary` | `#FFFFFF` | Primary text on dark |
| `textSecondary` | `#9AA6B8` | Subtitles, hints |

Light theme: invert background to `#F5F7FA` / surface `#FFFFFF`, keep `primaryBlue`
and `accentOrange` as-is.

---

## 3. Typography (from `flutter_assets/.../Fonts`)

| Font family | Weights present | Role |
|---|---|---|
| **Baloo Da 2** | ExtraBold, Medium, Variable | Display / headings / logo-adjacent titles, numbers (wallet balance) |
| **Google Sans** | Medium, Regular | Body, labels, buttons |
| Material Icons | — | Iconography |
| Cupertino Icons | — | iOS-style glyphs (bundled) |

Suggested Material 3 type scale:
- `displayLarge / headlineMedium` → Baloo Da 2 ExtraBold
- `titleMedium / labelLarge` → Google Sans Medium
- `bodyMedium / bodySmall` → Google Sans Regular

---

## 4. Assets Available (reusable placeholders)

`~/cloneapp/resources/assets/flutter_assets/lib/App/Assets/Images/` (all 512×512):
- `logo.png` — full PlayTour logo on dark navy
- `playtourbd.png` — logo line-art (transparent)
- `freefire_logo.png` — Free Fire game tile

Fonts in `.../Assets/Fonts/`: `BalooDa2-ExtraBold.ttf`, `BalooDa2-Medium.ttf`,
`BalooDa2-VariableFont_wght.ttf`, `GoogleSans-Medium.ttf`, `GoogleSans-Regular.ttf`.

> These can be copied directly into the clone's `assets/` (branding placeholders).

---

## 5. Complete Screen Inventory (from `*Screen` symbols)

| # | Screen | Controller / Binding | Route | Purpose |
|---|---|---|---|---|
| 1 | `LaunchScreen` / Splash | `SplashController` / `SplashBinding` | `/` | Boot, calls `/api/splash`, checks app_update_required / maintenance / ban |
| 2 | `LoginScreen` | `LoginController` / `LoginBinding` | `/login` | Phone-or-email + password login |
| 3 | `RegisterScreen` | `RegisterController` / `RegisterBinding` | `/register` | Sign up + optional refer code |
| 4 | `HomeScreen` | `HomeController` / `HomeBinding` | `/home` | Carousel banners, all games, active matches |
| 5 | `MenuScreen` | (Menu) | `/menu` | Drawer / profile menu, logout |
| 6 | `FreeFireMatchesScreen` | `FreeFireMatchesController` | `/freefire_matches` | List of joinable Free Fire matches |
| 7 | `FreeFireMatchInfoScreen` | `FreeFireMatchInfoController` | `/match_info` | Match detail: prize, entry, per-kill, slots |
| 8 | `FreeFireJoinScreen` | `FreeFireJoinController` | `/join` | Confirm join, agree to rules, pay entry |
| 9 | `MatchRulesScreen` | `MatchRulesController` | `/match_rules` | Rules text + "agree" checkbox |
| 10 | `MyMatchesScreen` | `MyMatchesController` | `/my_matches` | Joined matches, room ID/password |
| 11 | `TopPlayerScreen` | `TopPlayerController` | `/top_players` | Leaderboard |
| 12 | `WalletScreen` | `WalletController` / `WalletBinding` | `/wallet` | Balance (available / winning / withdrawable) |
| 13 | `DepositScreen` | `DepositController` / `DepositBinding` | `/deposit` | Add money — gateway selection |
| 14 | `DepositWebViewScreen` | (DepositController) | `/deposit-webview` | Payment gateway WebView |
| 15 | `WithdrawScreen` | `WithdrawController` / `WithdrawBinding` | `/withdraw` | Withdraw to wallet number/method |
| 16 | `TransactionsScreen` | `TransactionsController` | `/transactions` | Transaction history (All Transactions) |
| 17 | `EditProfileScreen` | `EditProfileController` | `/edit_profile` | Update profile data |
| 18 | (Change Password) | `EditProfileController` | `/change_password` | CHANGE PASSWORD form |
| 19 | `PrivacyScreen` | — | `/privacy` | Privacy & policy WebView |

**Confirmed route name strings:** `/deposit`, `/deposit-webview`, `/match_rules`,
`/my_matches`, `/top_players`, `/transactions`, `/withdraw` (others inferred from
screen names; `AppRoutes` class confirmed present).

---

## 6. App Flow

```
LaunchScreen (/api/splash)
   ├─ app_update_required → ForceUpdate dialog
   ├─ app_status = maintenance → Maintenance screen (maintenance_message)
   ├─ account_status = banned → BannedUserDialog ("ACCOUNT BANNED")
   ├─ no token → LoginScreen ──(Register link)──> RegisterScreen
   └─ valid token → HomeScreen
                       │
   ┌───────────────────┼───────────────────────────────┐
   ▼                   ▼                                 ▼
HomeScreen        WalletScreen                      MenuScreen
 │ carousel        │ Available / Winning / Withdrawable   │ Edit Profile
 │ all_games       │ ├─ Deposit → DepositWebView          │ Change Password
 │ active matches  │ ├─ Withdraw                          │ Transactions
 ▼                 │ └─ Transactions                      │ Top Players
FreeFireMatchesScreen                                     │ Privacy / Logout
 ▼
FreeFireMatchInfoScreen (prize, entry_fee, per_kill, slots, rules)
 ▼
MatchRulesScreen ("I have read and agree to the match rules")
 ▼
FreeFireJoinScreen (Confirm Join → join_freefire_match)
 ▼
MyMatchesScreen (Already Joined, room_id / room password)
```

---

## 7. Navigation Map  *(✅ verified against screenshots)*

- **Bottom nav (root shell) = 3 tabs:** `Shop` · `Home` · `Profile`. Active tab
  uses a rounded blue pill highlight (icon+label tint blue); inactive = grey.
- **There is no drawer.** The "Menu" surface is the **Profile tab**, which lists:
  - *ACCOUNT:* Edit Profile, My Wallet, My Matches, Top Players
  - *MORE:* Share App, Match Rules, Terms & Conditions, Developer Profile, **Logout**
- All detail screens (match info, wallet sub-pages, edit profile, leaderboard,
  match rules) push on top with a back-arrow app bar.
- GetX named routes via `Get.toNamed(...)`; bindings lazy-inject controllers.

> See **Part B** below for full per-screen specs and the exact palette measured
> from the screenshots. Where Part B and the inferred sections differ, Part B wins.

---

## 8. Data Models (from JSON field keys in binary)

### `User` / profile (`/api/user/fetch_profile`)
```
id, name, email, phone, refer_code, device_id, fcm_token,
account_status, total_matches_played, total_matches_won
```

### `Wallet` (`/api/wallet`)
```
balance, available_balance, winning_balance, withdrawable_balance,
won_amount, deposit_status, withdrawal_methods[]
```

### `Match` (Free Fire) (`/api/my_matches`, match list)
```
match_id, match_title, match_time, match_status, game_mode (solo/squad),
game_name, entry_fee, per_kill, prize / won_amount, slots, slots_type,
room_id, is_joined, rules, cover_image, map (Classic Match)
```

### `Transaction` (`/api/wallet` history)
```
id, amount, type, status, method, date / datetime, description
```

### `LeaderboardEntry` (`/api/leaderboard`)
```
rank, name, image, total_matches_won, won_amount, per_kill (top_players)
```

### `SplashConfig` (`/api/splash`)
```
app_version, app_update_required, app_status, app_status_message,
maintenance_message, account_status, default_notice_status,
default_notice_message, carousel_banners[], all_games[], shop_banner,
shop_url, deposit_gateway_status, withdraw_notice
```

### `DepositScreen config` (`/api/wallet/fetch_deposit_screen`)
```
deposit_gateway_status, deposit_gateway_url, payment_method, payment_url
```

### `WithdrawScreen config` (`/api/wallet/fetch_withdraw_screen`)
```
minimum_withdraw, maximum_withdraw, withdrawable_balance,
withdrawal_methods[], withdraw_notice
```

---

## 9. API Endpoints (confirmed from binary)

Base: `https://panel.playtourbd.com/api/`

| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/login` | `phone_or_email` + `password` → token |
| POST | `/register` | name, phone/email, password, password_confirmation, refer_code |
| GET | `/splash` | App config, banners, status gates |
| GET | `/user/fetch_profile` | Profile + stats |
| POST | `/user/update_profile_data` | Edit profile |
| POST | `/user/change_password` | current_password, new_password, password_confirmation |
| GET | `/wallet` | Balances + transactions |
| GET | `/wallet/fetch_deposit_screen` | Deposit gateway config |
| GET | `/wallet/fetch_withdraw_screen` | Withdraw limits/methods |
| POST | `/wallet/withdraw` | amount, method, wallet number |
| GET | `/my_matches` | User's joined matches |
| GET | `/game/match_rules/{id}` | Match rules text |
| POST | `/game/join_freefire_match` | match_id, team_id, slot → join |
| GET | `/leaderboard` | Top players |

Auth: Bearer **JWT** token (`token` field in login/register response,
`fcm_token` sent for push). The clone's Pure-PHP backend will mirror these paths.

---

## 10. Key UI Copy (verbatim strings, for pixel-accurate text)

- Auth: "Forgot password?", "Already have an account?", "Account created successfully!",
  "Enter refer code if any", "phone_or_email" placeholder
- Wallet: "Available Balance", "Add Money", "All Transactions", "Enter your Wallet Number",
  "Insufficient winning balance.", "Deposit is currently unavailable.",
  "Deposits are currently disabled.", "How to Withdraw?"
- Match: "Entry Fee", "ENTRY", "Confirm Join", "Already Joined", "Join Match",
  "Join Group", "Joined Successfully!", "I have read and agree to the match rules",
  "How to Join a Match?", "Classic Match", "ALL GAMES & MODES", "Failed to join."
- Profile/menu: "Edit Profile", "CHANGE PASSWORD", "Current Password",
  "Enter new password", "Confirm New Password", "Developer Profile", "Feedback", "LOGOUT"
- Gates: "ACCOUNT BANNED", "Account Banned", maintenance / force-update dialogs

---

## 11. Recreation Notes / Assumptions

- **Bottom nav layout** is inferred (icons not in string table) — validate against
  screenshots when provided.
- **Exact spacing/radius**: original uses rounded cards (~12–16 r), pill buttons.
  Confirm against screenshots; default to Material 3 `CardTheme` r=16, buttons r=12.
- **Carousel** uses `CarouselSlider` package (confirmed `CarouselSliderController`).
- **WebView** used for deposit gateway + privacy (`WebViewController` confirmed).
- **EasyLoading** overlay used for loading states (`EasyLoadingOverlayEntry` confirmed).
- Light theme is a clone addition (original appears dark-only — splash is dark navy).

---

## 12. Locked Decisions (2026-06-23)

1. **State management:** GetX (1:1 with original).
2. **Build order:** Flutter frontend first (runnable prototype, dummy data, mock services).
3. **Screenshots:** received — 20 screens, analyzed in **Part B** below.
4. **API base:** clone will point at the new Pure-PHP backend (built after the frontend).

---

# PART B — Screenshot-Verified Design Spec

> 20 screenshots analyzed. This part is the **source of truth** for pixel work and
> overrides any inferred detail above.

## B0. Critical brand finding

The deployed app is **white-label / reskinned**. The splash + store identity is
**"Play Tour / Play & Earn"**, but the **in-app header logo and brand is "WAR ZONE"**
(blue esports helmet mark, top-left of every main tab). Treat brand as a **themeable
config** (logo asset + name string) so one codebase can serve both. Currency is
**Bangladeshi Taka `৳` (BDT)**; secondary unit label "TK" appears inside match cards.

## B1. Measured palette (from screenshots)

| Token | Hex | Where seen |
|---|---|---|
| `bg` | `#0B1119` → `#0E1420` | App background (near-black navy) |
| `surface` | `#131C2B` | Cards / list tiles |
| `surfaceBorder` | `#1E2A3D` (1px) | Card outline, subtle |
| `primaryBlue` | `#2F6BFF` | Primary buttons, active nav pill, links, progress bars |
| `primaryBlueDeep` | `#3B6FE5` | Login button, tab pills |
| `success`/`add`/`join` | `#16A34A` → `#0E7A38` (gradient) | Add Money, Join Match, Active badge |
| `winningTeal` | `#2BD9A0` | "Winnings" / "Winning Balance" text + arrow |
| `danger`/`withdraw`/`logout` | `#D33B3B` → `#C42B2B` | Withdraw, Change Password, Logout |
| `gold` | `#F5B71E` | Trophy, prize, #1 rank, crown |
| `silver` | `#AEB6C2` | #2 rank |
| `bronze` | `#C77B3C` → `#B5722F` | #3 rank |
| `killRed` | `#FF4D6A` | Per-kill target icon |
| `textPrimary` | `#FFFFFF` | Titles, values |
| `textSecondary` | `#8A93A5` | Labels, hints, "matches found" grey state |
| `matchesFoundGreen` | `#2ECC71` | "N matches found" active pill |

Radii: cards **r≈18**, buttons **r≈14–28 (pill)**, input fields **r≈14**, stat cells **r≈12**.
Buttons have a soft outer **glow** matching their fill (green/blue/red) — recreate with a
low-opacity `BoxShadow` of the button color.

## B2. Per-screen specs (all 20 screens)

**1 · Splash** — centered logo with radial teal glow, "Play Tour" (Baloo ExtraBold ~34),
subtitle "Play & Earn" (grey, letter-spaced), tiny diamond loader. Calls `/api/splash`.

**2 · Login** — rounded card panel; circular logo w/ glow; "Welcome Back" (Baloo ~38),
"Sign in to continue". Fields: *Phone or Email* (person icon), *Password* (lock icon +
eye toggle). "Forgot password?" right-aligned (blue). Full-width **Login** (blue, pill).
Footer: "Don't have an account? **Register**" + "Version 1.0.0".

**3 · Register** *(not screenshotted; build from Login pattern + recovered fields)* —
Name, Phone/Email, Password, Confirm Password, "Enter refer code if any", Register button,
"Already have an account? Login". On success → green snackbar "Account created successfully!".

**4 · Home tab** — AppBar: WAR ZONE logo (left) + wallet pill `[wallet icon ৳0]` (right,
tappable → Wallet). Body: **carousel banner** (page dots, auto-scroll; e.g. "TELEGRAM
SUPPORT"). Section header "ALL GAMES & MODES" (blue left-bar). **2-col grid** of game-mode
cards: image thumbnail (Free Fire art) + title (BR MATCH / CS MATCH / LONE WOLF / FREE
MATCH) + pill "N matches found" (green w/ dot if >0, grey if 0). Tapping a card →
match-list screen for that mode.

**5 · Shop tab** — same AppBar. Promo banner carousel + "Why Choose Us?" heading + 3
feature cards (icon tile + title + subtitle): Secure Payment, Fastest Deal, 24/7 Support.

**6 · Profile tab** — AppBar wallet pill. **Profile header card:** square avatar (logo),
name "FHBB", "UID : #824" chip. **Balance card:** "Available Balance" + big `৳0` + green
**+ ADD** button; "Winnings: ৳0" teal pill. **Stats row** (3 cells): Matches / Wins /
Earnings (icon + number + label). **ACCOUNT** list: Edit Profile, My Wallet, My Matches,
Top Players (icon tile + label + chevron). **MORE** list: Share App, Match Rules,
Terms & Conditions, Developer Profile, **Logout** (red icon tile).

**7 · Match List (per mode)** — AppBar: back + mode name (e.g. "CS MATCH"). List of match
cards, OR **empty state**: centered game icon + "No matches available right now" +
"Pull down to refresh". Pull-to-refresh enabled.

**8 · Match Info — simple variant** ("BR MATCH" → "BR Solo Time 👑") — header card with
`#138` corner badge; game icon + title + date "23 Jun 2026 · 7:00 PM" (teal). **6 stat
cells (2×3):** PRIZE 160 TK, KILL 6 TK, FEE 10 TK, TYPE Solo, MAP Bermuda, VER TTP·Android.
"Registration  5/20" + blue progress bar. **Join Match** (green, full-width). Row: **Room**
(blue) + **Prizes** (blue). Footer ribbon "Starts in: 52m 14s" (live countdown).

**9 · Match Info — detailed/tabbed variant** ("BR Solo Time 👑") — **segmented tabs**
[Match Rules | Participants] (active = blue pill). *Match Rules tab:* match card +
**9 stat cells (3×3):** MAP, MODE, TYPE, PRIZE, PER KILL, ENTRY, VERSION, DEVICE, SLOTS
(5/20) + progress bar; "Active" green badge; then "Match Rules" card with Bangla rules +
**Show Full Rules / Show Less** expander. *Participants tab:* numbered list (circle index
+ controller icon + IGN). Sticky bottom **Join Match** (green).

**10 · Join Match** — match summary card (title + "Active" badge, MAP/MODE/TYPE +
PRIZE/PER KILL/ENTRY 6-cell grid, "Slots 0/4" + progress). **SELECT SLOT TYPE:** chips
*Solo (1P)* / *Duo (2P)* (selected = blue). **PLAYER NAMES (`N slot(s)`):** dynamic numbered
inputs "Player N — in-game name", count = slot type. Bottom **Join Match** (green).

**11 · My Wallet** — **balance card** (gradient navy): "Available Balance" `৳0`, inset
"Winning Balance | ৳0" (teal left-border). Buttons: **Add Money** (green) + **Withdraw**
(red). "QUICK ACTIONS" → **Transaction History** tile (icon + title + subtitle + chevron).
"HOW TO GUIDE" → 3 rows (How to Add Money? / How to Join a Match? / How to Withdraw?) each
with a blue **▶ Watch** button.

**12 · Add Money (Deposit)** — green header card: "Add Money / Secure payment via gateway"
+ "Active" badge. "ENTER AMOUNT" field (৳ prefix). **PROCEED TO PAYMENT** (green, lock icon).
Info card: 3 bullets (secure gateway / instant credit / contact support). Then →
DepositWebView (gateway URL).

**13 · Deposit WebView** — full-screen WebView of `deposit_gateway_url` with back AppBar.

**14 · Withdraw** — "CHOOSE YOUR PAYMENT CHANNEL": 2 channel cards **bKash** (selected =
green border + check) / **Nagad** (logos). Fields: "Enter your Wallet Number", "Amount" (৳).
Helper "Min: ৳105 · Max: ৳10000". **WITHDRAW** (red). "Your Withdrawal Balance is: ৳0" card.
Notice card (green-tinted, Bangla `withdraw_notice`).

**15 · All Transactions** — list of tx rows (type/amount/status/date), OR **empty state**:
receipt icon + "No transactions yet" + "Pull down to refresh". Pull-to-refresh.

**16 · Edit Profile (+ Change Password)** — *one screen, two sections.* Top: Full Name
(editable, person icon), Email (locked, lock icon), Phone (locked, lock icon), **UPDATE
PROFILE** (blue). Bottom: Current / New / Confirm New Password (lock icon + eye toggle each),
**CHANGE PASSWORD** (red).

**17 · Top Players (Leaderboard)** — **"Your Position" card** (blue): rank circle "#44" +
name + "Total Earnings ৳0". **Podium** (3 columns): #2 silver (left, lower), #1 gold (center,
tallest, medal icon + name + ৳), #3 bronze (right). **ALL PLAYERS** ranked list: rank + name
+ trophy + ৳earnings; top-3 rows have gold/silver/bronze borders.

**18 · Match Rules (standalone, from Profile)** — "Pick a mode" + horizontal scroll chips
(BR MATCH active blue / CS MATCH / LONE WOLF / FREE MATCH). Rules card per mode (🌻 header +
numbered Bangla rules). Mode switch swaps the rules body.

**19 · Terms & Conditions** — WebView/scroll of policy (`privacy_and_policy.html`).

**20 · Developer Profile** — simple info/credits screen (from MORE menu).

## B3. Reusable widgets to build first

`AppScaffold` (bg + optional WApppBar) · `BrandAppBar` (logo + wallet pill) ·
`PrimaryButton` (variant: blue/green/red + glow) · `StatCell` (icon+value+label) ·
`GameModeCard` · `MatchSummaryCard` · `BalanceCard` · `LabeledTextField` (icon + eye) ·
`SectionHeader` (blue bar + caps title) · `ListNavTile` (icon tile + label + chevron) ·
`SegmentedTabs` · `EmptyState` (icon + title + "Pull down to refresh") ·
`CountdownRibbon` · `PodiumWidget` · `RankRow` · `BottomNavBar` (Shop/Home/Profile pill).

## B4. App flow (verified)

Splash → Login/Register → **Root shell [Shop · Home · Profile]**.
Home → GameModeCard → Match List → Match Info (tabbed) → Join Match → success.
Profile → {Edit Profile · My Wallet → (Add Money→WebView / Withdraw / Transactions) ·
My Matches · Top Players · Match Rules · Terms · Developer Profile · Logout}.
Wallet pill in AppBar (any main tab) → My Wallet.
