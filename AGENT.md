# AGENT.md — SakuKu

Instructions for AI coding agents working on this repository. Read this file fully before making changes.

## 1. Project

SakuKu is an offline-first personal finance tracker for Android (iOS later). Users record income and expenses, manage wallets, set monthly budgets per category, and read spending reports. All data lives on the device in SQLite. There is no backend and no login in the MVP.

## 2. Source of truth

When documents disagree, resolve in this order and mention the conflict in your summary:

1. `PRD.md`: behavior, business rules, data model, priorities (Must / Should / Could).
2. `DESIGN.md`: colors, typography, spacing, radius, component specs, microcopy rules.
3. Stitch screens (in `design/`): layout of each screen. Match them closely; copy UI text verbatim.

If something is not covered, make the smallest reasonable choice, state the assumption in your summary, and do not invent features beyond `PRD.md`.

## 3. Stack (default)

Change this section if the team picks a different stack.

| Concern | Choice |
|---|---|
| Framework | Flutter (stable), Dart, Material 3 |
| State | Riverpod (`flutter_riverpod`) |
| Navigation | `go_router` |
| Database | Drift (SQLite) with generated code |
| Charts | `fl_chart` |
| Formatting / i18n | `intl` with `id_ID`, ARB files via `flutter gen-l10n` |
| Tests | `flutter_test`, plus `integration_test` for key flows |

Ask before adding any dependency that is not listed here.

## 4. Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift / codegen
flutter gen-l10n                                           # after editing .arb files
dart format .
flutter analyze
flutter test
flutter run                                                # run on connected device/emulator
```

Before declaring a task done, `dart format .`, `flutter analyze` and `flutter test` must all pass with no new warnings.

## 5. Repository layout

```
/
├── AGENT.md  PRD.md  DESIGN.md
├── design/                 # Stitch exports (reference only; never import from here)
├── lib/
│   ├── main.dart
│   ├── app/                # app widget, router, theme wiring
│   ├── core/
│   │   ├── theme/          # tokens from DESIGN.md -> ThemeData + ThemeExtension
│   │   ├── widgets/        # shared components (BalanceCard, TransactionTile, ...)
│   │   └── utils/          # money + date formatters, extensions
│   ├── data/
│   │   ├── db/             # Drift database, tables, DAOs, migrations
│   │   └── repositories/   # the only layer that talks to the database
│   ├── l10n/               # app_id.arb
│   └── features/
│       ├── home/
│       ├── transactions/   # history + add/edit transaction
│       ├── reports/
│       ├── budget/
│       ├── accounts/       # wallets + transfer
│       ├── categories/
│       └── profile/
└── test/
```

Each feature uses `presentation/` (screens, widgets), `application/` (Riverpod providers/notifiers), and relies on `data/repositories`. UI never calls the database directly.

## 6. Conventions

**Money**
- Store and compute amounts as `int` Rupiah. Never use `double` for money.
- Format only through `lib/core/utils/money.dart` (`Rp 1.250.000`, signed variants, compact `Rp 1,2 jt`). Do not concatenate currency strings by hand.

**Dates**
- Store the transaction date as a date (no time-of-day logic in business rules). Use the device's local timezone. Month boundaries are calendar months.

**Data rules** (see `PRD.md` section 6)
- Transfers are not income or expense and never count toward reports or budgets.
- Wallets and categories that are referenced are archived, not deleted.
- Wallet balance is derived: initial balance + income − expense ± transfers. Do not store a running balance column.
- Any schema change needs a Drift migration and a test. Never edit an existing migration.

**UI**
- All colors, text styles, spacing, and radii come from `lib/core/theme/` per `DESIGN.md`. No hardcoded hex values, font sizes, or magic paddings in feature code.
- Build a shared widget in `core/widgets/` when a component from `DESIGN.md` section 6 appears on more than one screen.
- User-facing strings live in `app_id.arb`. For existing screens, copy the Stitch text verbatim.
- Support light and dark themes from the start. Touch targets at least 48dp, support 130% text scale, add semantic labels on icon-only buttons and charts.

**Code style**
- Follow `flutter_lints` (strict). Prefer `const` constructors, small widgets, and immutable models.
- Name files `snake_case.dart`, types `UpperCamelCase`, providers `somethingProvider`.
- Keep business rules in `application/` or `data/repositories`, not inside widgets.
- Handle loading, empty, and error states for every screen that reads data.
- Comments explain why, not what. No commented-out code.

## 7. Testing

- Unit tests for: money formatting, balance calculation, report aggregation, budget status thresholds (< 80%, 80–99%, ≥ 100%), and transfer exclusion.
- Repository tests against an in-memory Drift database.
- Widget tests for TransactionTile, AmountInput/keypad, and BudgetProgress.
- One integration test for the main flow: add expense → balance updates → appears in history → counts in report.
- Fix the code, not the test, unless the test contradicts `PRD.md`.

## 8. Workflow

1. Restate the task and list which `PRD.md` requirement IDs it touches (for example `FR-01`).
2. Make small, focused changes; one feature or fix per change.
3. Build in the milestone order from `PRD.md` section 10 unless told otherwise.
4. Run the commands in section 4.
5. Summarize: what changed, files touched, assumptions made, anything that deviates from `DESIGN.md` or the Stitch screen, and what remains.

Commit messages: imperative, present tense, with the requirement ID when relevant (`Add transaction form (FR-01)`).

## 9. Boundaries

**Always**
- Keep the app fully usable offline.
- Keep the layering: UI → providers → repositories → database.
- Write or update tests with the code.

**Ask first**
- Adding or upgrading dependencies, changing the target Android version, or changing the database schema.
- Anything that sends data off the device (analytics, crash reporting, cloud sync).
- Deviating from a Stitch screen or `DESIGN.md`.

**Never**
- Use `double` for money, or store derived balances.
- Hardcode colors, sizes, or user-facing strings in widgets.
- Commit secrets, keystores, `local.properties`, or generated files that are git-ignored.
- Edit files in `design/`, existing migrations, or generated `*.g.dart` files by hand.
- Add features marked out of scope in `PRD.md` section 3.

## 10. Definition of done

- Behavior matches the acceptance criteria in `PRD.md` for the requirement IDs involved.
- UI matches the Stitch screen and `DESIGN.md` in both light and dark themes.
- Loading, empty, and error states exist.
- `dart format .`, `flutter analyze`, and `flutter test` pass.
- The summary lists assumptions and any deviations.
