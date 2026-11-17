# DESIGN — SakuKu

Visual and interaction spec for the SakuKu personal finance app (Android, Flutter). This file defines the **tokens and rules**; the Google Stitch screens define the **layout** of each screen.

**Precedence:** behavior → `PRD.md`; layout of a screen → the Stitch screen; colors, type, spacing, radius, components → this file. If a Stitch screen conflicts with a token here (for example a low-contrast color), follow this file and flag the difference in your summary.

---

## 1. Principles

1. **Fast first.** Adding a transaction is the primary action. The (+) button is reachable from every main tab.
2. **Numbers are the hero.** Amounts are the largest and boldest text on any screen and use tabular figures so columns align.
3. **Color means money.** Green is income, rose is expense, amber is a warning. Do not use these colors for anything decorative.
4. **Calm and trustworthy.** Restrained decoration. One gradient surface per screen at most (the balance card on Home). No gradient washes on ordinary cards.

## 2. Color tokens

Base palette is emerald/teal on a cool slate neutral. Contrast values are approximate; verify with a contrast checker when in doubt.

| Token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#F8FAFC` | `#0B1220` | Screen background |
| `surface` | `#FFFFFF` | `#131C2E` | Cards, sheets, app bars |
| `surfaceVariant` | `#F1F5F9` | `#1B2740` | Inputs, unselected chips, keypad keys |
| `border` | `#E2E8F0` | `#263349` | 1px card outlines, dividers |
| `textPrimary` | `#0F172A` | `#F1F5F9` | Titles, amounts, body |
| `textSecondary` | `#475569` | `#94A3B8` | Supporting text |
| `textTertiary` | `#64748B` | `#7C8BA3` | Captions, placeholders |
| `primary` | `#047857` | `#047857` | Filled buttons (white label, ≈5.5:1) |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Text/icons on `primary` |
| `fab` | `#059669` | `#059669` | Floating action button (white icon) |
| `primaryBright` | `#10B981` | `#10B981` | Chart fills, progress fills, decorative only. Never text, never behind white text |
| `primaryContainer` | `#D1FAE5` | `#064E3B` | Selected chip, income icon tint |
| `onPrimaryContainer` | `#065F46` | `#A7F3D0` | Text/icons on `primaryContainer` |
| `incomeText` | `#047857` | `#34D399` | Income amounts, "+" values |
| `expenseText` | `#E11D48` | `#FB7185` | Expense amounts, "−" values |
| `expenseFill` | `#F43F5E` | `#F43F5E` | Expense bars, chart segments |
| `warningFill` | `#F59E0B` | `#FBBF24` | Budget at 80–99% (progress fill) |
| `warningText` | `#B45309` | `#FBBF24` | Warning text |
| `coin` | `#FBBF24` | `#FBBF24` | App icon accent only |

**Hero gradient** (balance card only): linear 135°, `#047857` → `#0F766E`. All text on it is white; keep supporting text at ≥ 14sp semibold or use full-opacity white.

**Category colors** (icon tint = color at 14% opacity as circle fill, icon in full color):

| Category | Icon (Material Symbols Rounded) | Color |
|---|---|---|
| Makan | `restaurant` | `#F59E0B` |
| Transport | `directions_bus` | `#3B82F6` |
| Belanja | `shopping_bag` | `#A855F7` |
| Tagihan | `receipt_long` | `#06B6D4` |
| Hiburan | `sports_esports` | `#EC4899` |
| Kesehatan | `health_and_safety` | `#84CC16` |
| Pendidikan | `school` | `#6366F1` |
| Lainnya (expense) | `more_horiz` | `#64748B` |
| Gaji | `payments` | `#10B981` |
| Bonus | `redeem` | `#10B981` |
| Freelance | `work` | `#10B981` |
| Hadiah | `card_giftcard` | `#10B981` |
| Lainnya (income) | `more_horiz` | `#10B981` |

## 3. Typography

Two families: **Plus Jakarta Sans** for titles and the balance, **Inter** for everything else. Both from Google Fonts (bundle the font files; do not fetch at runtime).

| Role | Family | Size / line | Weight | Use |
|---|---|---|---|---|
| `balanceDisplay` | Plus Jakarta Sans | 32 / 40 | 700 | Total balance on the hero card |
| `titleLarge` | Plus Jakarta Sans | 24 / 32 | 700 | Screen titles |
| `titleMedium` | Plus Jakarta Sans | 20 / 28 | 600 | Section headers |
| `titleSmall` | Plus Jakarta Sans | 16 / 24 | 600 | Card titles, button labels |
| `amount` | Inter | 16 / 24 | 600 | Amounts in lists (tabular figures on) |
| `body` | Inter | 14 / 20 | 400 | Default text |
| `bodyStrong` | Inter | 14 / 20 | 600 | Emphasis inside body |
| `caption` | Inter | 12 / 16 | 500 | Dates, categories, helper text |

Rules: sentence case for any new copy, no all-caps labels, no letter-spacing tricks. Enable `FontFeature.tabularFigures()` on every style that shows money. Keep text blocks under about 60 characters per line.

## 4. Spacing, radius, elevation

**Spacing** (4pt grid): `4, 8, 12, 16, 20, 24, 32, 40`. Screen horizontal padding **20**. Space between sections **24**. Card inner padding **16**. List row vertical padding **12**.

**Radius** (differs by element on purpose):

| Element | Radius |
|---|---|
| Hero balance card | 24 |
| Standard card | 16 |
| Category chip (selectable, 72×72) | 16 |
| Button | 14 |
| Text field, keypad key | 12 |
| Filter chip, segmented toggle | pill (999) |
| Category icon in list | circle, 40dp |
| Bottom sheet (top corners) | 28 |
| Dialog | 24 |

**Elevation:**
- Light: cards use a 1px `border` plus `0 1 2 rgba(15,23,42,0.06)`. FAB uses `0 6 16 rgba(4,120,87,0.30)`.
- Dark: no shadows. Separate layers with `surface` vs `surfaceVariant` and `border`.

## 5. Iconography

Material Symbols Rounded, weight 400, 24dp default (20dp inside chips, 28dp in the FAB). Bottom navigation uses filled icons when active and outlined when inactive. Every icon-only button needs a semantic label in Indonesian.

## 6. Components

**BalanceCard** (Home). Hero gradient, radius 24, padding 20. Label "Total Saldo" (caption, white), balance (`balanceDisplay`, white). Below, two stat blocks side by side: "Pemasukan" with an up arrow and "Pengeluaran" with a down arrow, each with the month's total in `amount` style, white.

**QuickActionChip.** Pill, `surfaceVariant` background, 20dp icon plus label (`bodyStrong`). Horizontally scrollable row, 8dp gap, 48dp height.

**TransactionTile.** 40dp category circle, then title (`bodyStrong`) over caption (`category • account`), amount right-aligned. Expense: `−Rp 45.000` in `expenseText`. Income: `+Rp 6.000.000` in `incomeText`. Row height at least 64dp. Tap opens edit. Trailing menu or swipe offers delete.

**DateHeader.** Caption-weight text ("Hari ini", "Kemarin", "28 Okt") on the left, daily net on the right in `textSecondary`.

**CategoryChip.** 72×72, radius 16, icon over label (`caption`). Selected: `primaryContainer` background, 2px `primary` outline, label in `onPrimaryContainer`. Unselected: `surfaceVariant`.

**SegmentedToggle** (Pengeluaran | Pemasukan; Semua | Pemasukan | Pengeluaran). Pill track in `surfaceVariant`, selected pill in `surface` with the `border`, text `bodyStrong`. Selected expense uses `expenseText`, selected income uses `incomeText`, otherwise `textPrimary`.

**AmountInput + Keypad.** Centered amount in 40sp Plus Jakarta Sans 700 with "Rp" prefix in `textSecondary`. The custom keypad has 3×4 keys (1–9, `000`, 0, backspace), each at least 56dp tall, radius 12, `surfaceVariant`. Amount is formatted live with thousands separators.

**PrimaryButton.** Full width, 52dp tall, radius 14, `primary` background, white `titleSmall` label. Disabled: `surfaceVariant` background, `textTertiary` label. A secondary button is outlined with `border` and `textPrimary` label.

**BottomNav.** 4 tabs (Home, Transactions, Reports, Profile) with a FAB (+) centered and docked above the bar. Active tab: icon and label in `primary` (dark: `incomeText`). Bar uses `surface` with a top `border`.

**BudgetProgress.** 8dp-tall pill bar on `surfaceVariant`. Fill is `primaryBright` below 80%, `warningFill` at 80–99%, `expenseFill` at 100% and above. Shown with "Rp used / Rp limit" and a status word ("Aman", "Hampir habis", "Terlampaui") so color is never the only signal.

**Charts.** Donut (category share) and grouped bar (income vs expense). Use category colors for the donut and `primaryBright` / `expenseFill` for bars. Draw gridlines in `border`, labels in `caption`. Abbreviate axis values (`Rp 1,2 jt`, `Rp 450 rb`). Every chart has a text equivalent (legend or list) beneath it.

**InsightCard.** `primaryContainer` background, radius 16, 16dp padding, one sentence in `body`, with a 20dp icon at the left. One insight at most per screen.

**EmptyState.** Centered 64dp icon in `textTertiary`, a one-line title, one line of help, and a button for the next action.

**Snackbar.** Floating above the bottom nav. Dark `textPrimary` background in light mode. Action label "Urungkan" where undo is possible.

## 7. Screens

Stitch screens are the layout reference. Summary of structure:

- **Home:** greeting row (name, notifications, avatar) → BalanceCard → QuickActionChip row → "Pengeluaran Bulan Ini" donut with legend → "Transaksi Terbaru" (5 tiles) → bottom nav.
- **Tambah Transaksi:** back + title → SegmentedToggle → AmountInput → CategoryChip grid → date, account, note rows → PrimaryButton "Simpan Transaksi" → keypad.
- **Transaksi:** title with search and filter → month selector → filter chips → grouped list.
- **Laporan:** title → Mingguan/Bulanan/Tahunan tabs → bar chart → summary card → category ranking with progress bars → InsightCard.
- **Anggaran:** title and month → summary card with circular progress → category BudgetProgress list → "Buat Anggaran Baru" button.
- **Not yet designed in Stitch:** Dompet (list, add/edit), Transfer, Kelola kategori, Profil dan pengaturan. Build them from the components above and keep the same structure (title, grouped cards, primary action at the bottom).

## 8. Motion

Keep it minimal and tied to user actions.
- Screen and sheet transitions: 250ms, ease-out.
- Charts draw in once on first appearance, 400ms.
- A deleted tile slides out and the snackbar appears; "Urungkan" restores it in place.
- No looping or decorative animation. Respect `MediaQuery.disableAnimations`.

## 9. Accessibility

- Touch targets at least 48×48dp, including icon buttons and keypad keys.
- Text contrast at least 4.5:1 (3:1 for 18sp+ bold and for non-text UI). Use `primaryBright` only for fills, never for text.
- Do not rely on color alone: amounts carry `+` / `−`, budget states carry a word.
- The layout must survive 130% text scaling without clipping; let rows grow instead of truncating amounts.
- Provide semantic labels for the icons, charts (a one-sentence summary), and the FAB ("Tambah transaksi").
- Visible focus state on all focusable elements (2px `primary` outline).

## 10. Content and microcopy

- UI language is Indonesian. For existing screens, **copy the Stitch text verbatim**. For any new text, use sentence case and plain words.
- Name an action the same way everywhere: button "Simpan transaksi" → snackbar "Transaksi disimpan"; "Hapus" → "Transaksi dihapus" + "Urungkan".
- Errors say what is wrong and how to fix it, and never apologize: "Nominal harus lebih dari Rp 0."
- Empty states invite an action: "Belum ada transaksi. Catat pengeluaran pertamamu."
- Formats: `Rp 1.250.000`; negative in lists `−Rp 45.000`; chart axis `Rp 1,2 jt`; dates "Hari ini", "Kemarin", "28 Okt 2026". Use `intl` with the `id_ID` locale, never manual string concatenation.

## 11. App icon

- 1024×1024 master, no text, no UI. Concept: minimal flat wallet with a small upward trend line or a coin, centered with generous padding.
- Background: gradient `#10B981` → `#0D9488`. Symbol: white. Coin accent: `coin` (`#FBBF24`).
- Android adaptive icon: 108dp canvas, symbol kept inside the central 66dp safe zone. Provide a separate foreground (symbol, transparent) and background (gradient) layer, plus a monochrome layer for themed icons.
- Must remain recognizable at 48px. Export with `flutter_launcher_icons`.

## 12. Implementation notes (Flutter)

- Define tokens once in `lib/core/theme/`: `app_colors.dart` (a `ThemeExtension` for `income`, `expense`, `warning`, `hero gradient`), `app_typography.dart`, `app_spacing.dart`, `app_radius.dart`, and `app_theme.dart` (light and dark `ThemeData`, Material 3).
- Map `primary`, `surface`, `background`, `onSurface` and friends into the `ColorScheme`; keep money-specific colors in the extension.
- Widgets read from `Theme.of(context)` and the extension. **No hardcoded hex, font sizes, or paddings in feature code.**
- Shared components from section 6 live in `lib/core/widgets/` and are reused across features.
