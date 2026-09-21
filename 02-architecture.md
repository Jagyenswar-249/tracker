# 02 — Architecture

## 1. Guiding principles

1. **Local-first.** SQLite is the source of truth. The UI never waits on a network.
2. **Pure domain core.** Period math, roll-ups and streaks are plain Dart with no Flutter imports, so they are trivially unit-testable.
3. **One-way data flow.** UI → controller (intent) → use case → repository → DB → stream → UI.
4. **Glass is isolated.** Every glass surface goes through one wrapper (`GlassSurface`) so the package, the fallback tier and the performance budget are controlled in one place.
5. **Sync-ready from day one.** UUID primary keys, `updated_at`, soft deletes, append-only event log.

## 2. Tech stack

| Concern | Choice | Why |
|---|---|---|
| Framework | Flutter (latest stable), Dart 3 | One codebase, custom rendering for glass, Impeller |
| State | `flutter_riverpod` (+ `riverpod_generator`) | Testable, stream-friendly, no BuildContext coupling |
| Navigation | `go_router` | Declarative, deep links from notifications |
| Database | `drift` + `sqlite3_flutter_libs` | Typed SQL, reactive streams, migrations |
| Models | `freezed` + `json_serializable` | Immutable entities, JSON export/import |
| Liquid Glass | `liquid_glass_renderer` (Impeller shaders) behind `GlassSurface` | Real refraction. Package is experimental: pin the version, keep the fallback tiers |
| Fonts | Bundle Bricolage Grotesque + Figtree as assets | Works offline, no runtime fetch |
| Icons | `phosphor_flutter` | Rounded style that suits glass |
| Charts | `fl_chart` | Sparkline, bars |
| Notifications | `flutter_local_notifications` + `timezone` | Local reminders |
| Haptics | `HapticFeedback` (built in) | Tick, impact, success patterns |
| Preferences | `shared_preferences` | Settings only, never work data |
| Testing | `flutter_test`, `mocktail`, `integration_test`, `alchemist` (goldens) | See section 9 |
| CI | GitHub Actions | analyze, test, build APK |

Do not hard-pin versions in this doc. Run `flutter pub add <pkg>` for the latest stable, then commit the lockfile. Pin `liquid_glass_renderer` exactly because its API is still moving.

## 3. Layered structure

```
┌────────────────────────────────────────────────────────┐
│ PRESENTATION   pages · widgets · controllers (Riverpod)│
│                design system (glass kit, tokens)       │
├────────────────────────────────────────────────────────┤
│ DOMAIN (pure Dart)                                     │
│  entities · value objects · period math · roll-ups     │
│  use cases · repository interfaces                     │
├────────────────────────────────────────────────────────┤
│ DATA                                                   │
│  Drift DB · DAOs · repository impls · mappers          │
│  notifications service · export/import                 │
├────────────────────────────────────────────────────────┤
│ PLATFORM   SQLite · local notifications · haptics      │
└────────────────────────────────────────────────────────┘
Dependencies point downward only. Domain depends on nothing.
```

## 4. Folder structure

```
brim/
├─ docs/                          # this bundle
├─ assets/
│  ├─ fonts/                      # Bricolage Grotesque, Figtree
│  └─ shaders/                    # only if custom shaders are added later
├─ lib/
│  ├─ main.dart
│  ├─ app.dart                    # MaterialApp.router, theme, providers scope
│  ├─ core/
│  │  ├─ theme/                   # tokens.dart, colors.dart, typography.dart, brim_theme.dart
│  │  ├─ glass/                   # glass_surface.dart, glass_tier.dart, glass_scope.dart,
│  │  │                           # glass_segmented_control.dart, glass_tab_bar.dart,
│  │  │                           # glass_button.dart, glass_sheet.dart
│  │  ├─ motion/                  # springs.dart, durations.dart
│  │  ├─ haptics/                 # haptics.dart
│  │  ├─ router/                  # app_router.dart
│  │  └─ utils/                   # date_only.dart, result.dart
│  ├─ domain/
│  │  ├─ entities/                # work.dart, progress_entry.dart, category.dart, period.dart
│  │  ├─ period/                  # period_math.dart, rollup.dart, streak.dart
│  │  ├─ repositories/            # work_repository.dart, progress_repository.dart, ...
│  │  └─ usecases/                # set_progress.dart, watch_period_items.dart, ...
│  ├─ data/
│  │  ├─ db/                      # app_database.dart, tables.dart, daos/, migrations/
│  │  ├─ repositories/            # *_impl.dart
│  │  ├─ mappers/
│  │  └─ services/                # notification_service.dart, export_service.dart
│  └─ features/
│     ├─ tasks/                   # home: segmented views, summary, list
│     │  ├─ tasks_page.dart
│     │  ├─ tasks_controller.dart
│     │  └─ widgets/              # work_card.dart, progress_scrubber.dart,
│     │                           # period_summary_panel.dart, period_navigator.dart,
│     │                           # daily_strip.dart, weekly_bars.dart
│     ├─ work_detail/
│     ├─ work_editor/             # bottom sheet
│     ├─ calendar/
│     ├─ insights/
│     ├─ settings/
│     └─ onboarding/
├─ test/                          # unit + widget + golden
├─ integration_test/
├─ .github/workflows/ci.yml
└─ analysis_options.yaml          # very_good_analysis or flutter_lints + stricter rules
```

## 5. Data model

### 5.1 ER overview

```
categories 1───* works 1───* progress_entries
                  │  1───* progress_events   (append-only log)
                  └  1───* reminders
```

### 5.2 Drift tables (sketch)

```dart
enum Cadence { daily, weekly, monthly, once }

class Categories extends Table {
  TextColumn get id => text()();                 // uuid
  TextColumn get name => text()();
  IntColumn  get colorArgb => integer()();
  TextColumn get iconKey => text().withDefault(const Constant('folder'))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override Set<Column> get primaryKey => {id};
}

class Works extends Table {
  TextColumn get id => text()();                 // uuid v4
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn  get colorArgb => integer()();
  TextColumn get cadence => text().map(const CadenceConverter())();
  IntColumn  get weekdayMask => integer().withDefault(const Constant(127))(); // bit0=Mon … bit6=Sun; daily only
  TextColumn get startDate => text()();          // 'YYYY-MM-DD' local date
  TextColumn get dueDate => text().nullable()(); // 'YYYY-MM-DD'; used when cadence == once
  IntColumn  get effort => integer().withDefault(const Constant(1))(); // 1..3
  IntColumn  get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()(); // soft delete (sync)
  @override Set<Column> get primaryKey => {id};
}

class ProgressEntries extends Table {
  TextColumn get id => text()();
  TextColumn get workId => text().references(Works, #id)();
  TextColumn get periodStart => text()();        // 'YYYY-MM-DD' (see 6.1)
  IntColumn  get percent => integer().check(percent.isBetweenValues(0, 100))();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
  @override List<Set<Column>> get uniqueKeys => [{workId, periodStart}];
}

class ProgressEvents extends Table {             // append-only
  TextColumn get id => text()();
  TextColumn get workId => text().references(Works, #id)();
  TextColumn get periodStart => text()();
  IntColumn  get fromPercent => integer()();
  IntColumn  get toPercent => integer()();
  DateTimeColumn get at => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class Reminders extends Table {
  TextColumn get id => text()();
  TextColumn get workId => text().references(Works, #id)();
  IntColumn  get minutesOfDay => integer()();    // 0..1439, local
  IntColumn  get weekdayMask => integer().withDefault(const Constant(127))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  @override Set<Column> get primaryKey => {id};
}
```

Indexes: `progress_entries(work_id, period_start)` unique, `progress_entries(period_start)`, `works(cadence, archived_at, deleted_at)`.

Migrations: use Drift's `schemaVersion` + step-by-step migrations, generate schema snapshots (`drift_dev schema dump`) and test every upgrade path.

## 6. Period logic (the heart of the app)

### 6.1 One representation: `periodStart`

Every progress entry is keyed by `(workId, periodStart)` where `periodStart` is the first local calendar date of the period:

| Cadence | periodStart |
|---|---|
| daily | the day itself |
| weekly | the first day of the week containing the date (per week-start setting) |
| monthly | the 1st of the month |
| once | the work's `startDate` (a constant, so there is exactly one entry) |

Range queries (heatmap, sparkline, insights) then become simple `BETWEEN` on `periodStart`.

### 6.2 Reference implementation

```dart
// domain/period/period_math.dart  — pure Dart, no Flutter imports
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day); // never add Durations across DST

String ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime weekStartOf(DateTime d, {int weekStart = DateTime.monday}) {
  final day = dateOnly(d);
  final back = (day.weekday - weekStart + 7) % 7;
  return DateTime(day.year, day.month, day.day - back); // constructor normalises month/year rollover
}

DateTime periodStartFor(Cadence c, DateTime anchor, {int weekStart = DateTime.monday, DateTime? workStart}) {
  final d = dateOnly(anchor);
  switch (c) {
    case Cadence.daily:   return d;
    case Cadence.weekly:  return weekStartOf(d, weekStart: weekStart);
    case Cadence.monthly: return DateTime(d.year, d.month, 1);
    case Cadence.once:    return dateOnly(workStart!);
  }
}

DateTime shiftPeriod(Cadence c, DateTime start, int delta) => switch (c) {
  Cadence.daily   => DateTime(start.year, start.month, start.day + delta),
  Cadence.weekly  => DateTime(start.year, start.month, start.day + 7 * delta),
  Cadence.monthly => DateTime(start.year, start.month + delta, 1),
  Cadence.once    => start,
};
```

### 6.3 Roll-up

```dart
double rollup(Iterable<({int effort, int percent})> items) {
  var w = 0, s = 0;
  for (final i in items) { w += i.effort; s += i.effort * i.percent; }
  return w == 0 ? 0 : s / w;   // 0..100
}
```

### 6.4 Which works belong to a period

```
watchPeriodItems(view: Cadence view, anchor: DateTime) → Stream<PeriodSnapshot>

editable = works where deleted_at IS NULL AND archived_at IS NULL AND start_date <= periodEnd AND (
             cadence == view                                   -- own cadence
          OR (cadence == once AND dueDate within period)       -- one-offs due in period
          OR (cadence == once AND overdue AND view == daily AND period is today) )
       and, for daily: weekdayMask has the day's bit

each item joined LEFT with progress_entries on (work_id, periodStart) → percent (default 0)

summaryStrips (read-only):
  weekly view  → 7 daily averages (rollup of daily works per day)
  monthly view → per-week averages of weekly works + daily heatmap
```

`PeriodSnapshot` = `{ items, overall, doneCount, totalCount, overdueCount, streak, nextDue, strips }`, computed in the domain layer from raw rows, so the UI only renders.

## 7. State management

Riverpod providers (generated):

| Provider | Type | Purpose |
|---|---|---|
| `appDatabaseProvider` | `Provider<AppDatabase>` | Single DB instance |
| `settingsProvider` | `NotifierProvider<Settings>` | Theme, week start, snap step, glass tier, haptics |
| `selectedViewProvider` | `NotifierProvider<Cadence>` | Daily / Weekly / Monthly (persisted) |
| `anchorDateProvider` | `NotifierProvider<DateTime>` | Which period is being viewed |
| `periodSnapshotProvider` | `StreamProvider<PeriodSnapshot>` | Depends on view + anchor + settings |
| `workDetailProvider(id)` | `StreamProvider.family` | One work with history |
| `insightsProvider(range)` | `FutureProvider.family` | Aggregates |
| `glassTierProvider` | `Provider<GlassTier>` | Resolves user setting + device capability + reduce-transparency |

### Scrubber write path (important for smoothness)

```
onDragUpdate  → local ValueNotifier<int> percent (UI only, 60 fps, no DB)
                 └─ snap → if value changed: haptic tick
onDragEnd     → SetProgress(workId, periodStart, percent) use case
                 └─ upsert entry + append event in ONE transaction
                 └─ show undo toast (previous value kept in memory for 4 s)
(optional)    → while dragging, throttle a "live" DB write every ≥250 ms so the summary panel moves along; skip if frame budget suffers.
```

## 8. The glass layer (`core/glass`)

```dart
enum GlassTier { liquid, frost, solid }   // refractive shader · blur+tint · opaque tint

class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.shape = const GlassShape.capsule(),   // capsule | rounded(radius) | circle
    this.tint,                                  // Color? — work/category colour bleed
    this.emphasis = GlassEmphasis.regular,      // subtle | regular | strong
    this.interactive = false,                   // pressed glow / stretch
    this.tierOverride,
  });
  ...
}
```

Rules enforced here:
- Resolves the tier from `glassTierProvider` (user setting, Reduce Transparency, device class, thermal/perf fallback).
- `liquid` → `liquid_glass_renderer` (`LiquidGlassLayer` / `LiquidGlass` / `FakeGlass` as appropriate). `frost` → `BackdropFilter(ImageFilter.blur)` + tint + rim light. `solid` → tinted opaque surface with the same rim.
- **Budget:** at most **3 `liquid` surfaces on screen at once** (tab bar + segmented control + scrubber thumb being dragged). Everything else uses `frost` or `FakeGlass`.
- One shared `LiquidGlassLayer` per screen so glass shapes can blend, mounted in `GlassScope` above the page.
- Wrap moving/animating glass in `RepaintBoundary`. Avoid nesting `BackdropFilter` inside scrollables where possible; use frost cards without live blur inside long lists (pre-tinted + rim) once list length > ~12.
- Detect Impeller at startup; if unavailable → force `frost`.
- A debug overlay (`--dart-define=GLASS_DEBUG=true`) shows current tier and glass layer count.

## 9. Testing strategy

| Level | What | Tools |
|---|---|---|
| Unit | `period_math` (DST, year rollover, week starts Mon/Sun/Sat, leap years), `rollup`, `streak`, use cases | `flutter_test`, `mocktail` |
| DB | DAOs and migrations on in-memory SQLite, every schema upgrade path | `drift_dev` schema tests |
| Widget | `ProgressScrubber` (drag → snap → callback, Semantics increment/decrement), `GlassSegmentedControl`, `WorkCard` states | `flutter_test` |
| Golden | Tasks page in light/dark × liquid/frost/solid × 3 views, text scale 1.0 and 1.5 | `alchemist` |
| Integration | Add work → drag to 60 % → restart → still 60 %; switch views; navigator | `integration_test` |
| Performance | Scroll + scrub profile run, frame timings on a mid-range Android device | `flutter run --profile`, DevTools |

Target: ≥ 90 % coverage of `domain/`, ≥ 70 % overall.

## 10. Quality gates and CI

`.github/workflows/ci.yml` on every push/PR:
1. `flutter pub get`
2. `dart format --set-exit-if-changed .`
3. `flutter analyze --fatal-infos`
4. `dart run build_runner build --delete-conflicting-outputs` (fail on diff)
5. `flutter test --coverage`
6. `flutter build apk --debug`

## 11. Performance budget

| Metric | Budget |
|---|---|
| Frame time while scrubbing | < 12 ms build+raster p95 on mid-range Android |
| Cold start | < 2 s |
| Glass layers on screen (liquid) | ≤ 3 |
| DB reads for a screen | 1 stream per screen, indexed |
| APK size (release, arm64) | < 30 MB |
| Idle CPU (aurora background) | Background animation paused when app is inactive or Reduce Motion is on |

## 12. Security and privacy

- MVP stores data only on device; no analytics, no network calls.
- Export is a user-initiated JSON file via the system share sheet.
- Android: `allowBackup` on so data survives device migration; exclude nothing sensitive.
- Notifications carry work titles only, no notes.
- Phase 5 (sync): Supabase Auth, row-level security per workspace, never trust client-supplied `owner_id`.

## 13. Phase 5 sync design (not in MVP)

- Postgres tables mirror the Drift schema plus `workspace_id`, `owner_id`, `deleted_at`.
- **Outbox** table records local mutations; a sync worker pushes them and pulls changes since `last_synced_at`.
- Conflict rule: last-write-wins per row using `updated_at`; `progress_entries` merge per `(work_id, period_start, member_id)` so teammates never overwrite each other.
- Realtime channel per workspace for live bars.

## 14. Accessibility hooks in the architecture

- `ProgressScrubber` exposes `Semantics(slider: true, value: '45 percent', increasedValue, decreasedValue, onIncrease, onDecrease)`.
- `glassTierProvider` listens to `MediaQuery.disableAnimations` and platform "reduce transparency" flags where available.
- All text sizes go through `MediaQuery.textScaler`; layouts tested to 200 %.

## 15. Localization

`flutter_localizations` + ARB files from the start (English first). No hard-coded strings in widgets; dates via `intl` `DateFormat` using the device locale.
