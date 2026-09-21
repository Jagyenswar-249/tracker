# 06 — Prompts for Antigravity

## How to use

1. Workspace layout: `brim/docs/` contains all files of this bundle (`00`–`05` and `layout-preview.html`).
2. Open `brim/` in Antigravity. Start a new agent task.
3. Paste **Prompt 0 (Master)**. The agent should produce an implementation plan and stop for your approval.
4. After approving, paste **Prompt 1**, then 2, 3, 4 one at a time. Review the checklist at the end of each phase before continuing.
5. If your Antigravity version supports workspace or global rules, put the **Standing rules** block there too; otherwise keep it at the top of Prompt 0 (already included).

Tips
- Keep each phase in its own conversation/task so context stays small; the agent re-reads `docs/` each time.
- Use a real Android device or emulator for glass checks. Flutter web preview shows the fallback look only.
- If the agent proposes a new dependency, ask it to justify it and log it in `docs/decisions.md`.

---

## Prompt 0 — Master prompt (paste first)

````
ROLE
You are a senior Flutter engineer and UI engineer building a production-quality mobile app called "Brim". You work plan-first, in small verified steps, and you follow the project documents exactly.

PRODUCT (one paragraph)
Brim is a mobile work-progress tracker. Every "work" has a completion bar the user drags horizontally to mark how much is done (0–100 %). The app has Daily, Weekly and Monthly views that show each period's works plus roll-up info (overall %, done/total, overdue, streak). The whole UI uses an iOS-26-style Liquid Glass design (refraction, rim light, specular highlights, stretch/morph) over an animated aurora background.

SOURCE OF TRUTH
Read every file in /docs before planning, in this order:
 1. docs/00-README.md
 2. docs/01-product-spec.md          (features, business rules)
 3. docs/02-architecture.md          (stack, layers, folders, schema, period logic)
 4. docs/03-design-system-liquid-glass.md   (tokens, tiers, components, motion, haptics, a11y)
 5. docs/04-screen-layouts.md        (wireframes, scrubber interaction spec)
 6. docs/05-project-plan.md          (phases, DoD, QA checklist)
 7. docs/layout-preview.html         (open in a browser for the visual target; it is a reference, not code to port)
If two documents disagree, 02 wins for technical decisions, 03 for visual decisions, 01 for behaviour. Note every conflict you find in docs/decisions.md.

FIXED DECISIONS (do not change without asking me)
- Flutter (latest stable), Dart 3, Android + iOS from one codebase. I develop on Windows, so verify on Android.
- State: flutter_riverpod (+ riverpod_generator). Navigation: go_router.
- Storage: drift + sqlite3_flutter_libs. Local-first, NO backend and NO network calls in v1.
- Models: freezed + json_serializable.
- Liquid Glass: liquid_glass_renderer behind our own GlassSurface wrapper, with three tiers (liquid / frost / solid) exactly as in docs/03. Pin that package to an exact version.
- Fonts bundled as assets: Bricolage Grotesque (display) and Figtree (body). Icons: phosphor_flutter. Charts: fl_chart. Reminders: flutter_local_notifications + timezone.
- Progress is stored per (workId, periodStart) with periodStart as a local 'YYYY-MM-DD' date, as defined in docs/02 section 6.

STANDING RULES (apply to every task)
1. Layers: domain/ is pure Dart (no Flutter imports). Widgets never touch the database; they use Riverpod providers and use cases. Dependencies point downward only.
2. Every glass surface goes through GlassSurface. Maximum 3 liquid-tier surfaces on screen at once. Glass is for the control layer (tab bar, segmented control, scrubber thumb, buttons, sheets); work cards and panels use the frost tier.
3. No hard-coded colours, spacings, radii, durations or user-facing strings in widgets. Use tokens (core/theme) and ARB localisation.
4. Dates: only date-only values. Build dates with DateTime(y, m, d). Never add Duration across days. Store dates as 'YYYY-MM-DD'.
5. The progress scrubber must update local UI state during drag (no DB writes per frame) and commit once on drag end via the SetProgress use case, with a 4-second undo.
6. Accessibility is part of "done": Semantics on every interactive element, slider semantics on the scrubber, contrast >= 4.5:1 in all glass tiers, text scale up to 200 %, Reduce Motion and Reduce Transparency respected.
7. Every screen must render correctly in light and dark and in all three glass tiers.
8. Add tests as you go: unit tests for domain, in-memory DB tests for data, widget tests for scrubber and glass controls, golden tests for main screens.
9. Before finishing any step run: dart format ., flutter analyze --fatal-infos, flutter test. Fix everything before reporting done.
10. Do not add any dependency that is not listed above without asking me first; if you believe one is needed, explain why and record it in docs/decisions.md.
11. Do not implement features marked v1.1 or v2 in docs/01. Do not add analytics, ads, accounts or network access.
12. Keep commits small and named by intent (conventional commits).

WHAT I WANT FROM YOU NOW (this task only)
Do NOT write app code yet. Produce:
 A. An implementation plan artifact that maps docs/05 phases 0-4 to concrete tasks, with file paths you will create, in build order, and the verification you will run for each task.
 B. A short list of risks or ambiguities you found in the docs, each with your proposed resolution.
 C. A "Phase 0 spike" proposal: the smallest Flutter screen that shows one liquid_glass_renderer surface over the aurora background so we can confirm Impeller and performance on an Android device before building more.
Then STOP and wait for my approval.
````

---

## Prompt 1 — Phase 0 + Phase 1 (Setup and Foundation)

````
Approved. Execute Phase 0 and Phase 1 from docs/05-project-plan.md.

Phase 0
- Create the Flutter project (org com.yourname, name brim) in the current workspace root, keeping /docs.
- Add analysis_options.yaml with strict lints, the CI workflow (.github/workflows/ci.yml), and all dependencies from docs/02 section 2. Bundle the fonts under assets/fonts and register them.
- Build the spike screen (aurora background + one liquid_glass_renderer capsule). Confirm Impeller is enabled for Android. Report the tier that resolved and the measured frame timings if you can run it on a device or emulator.

Phase 1
- core/theme: tokens, BrimColors ThemeExtension (dark + light), typography, ThemeData.
- core/glass: GlassSurface, GlassTier, GlassScope (shared layer), glassTierProvider (user setting, reduce transparency, Impeller check, performance guard), GlassSegmentedControl, GlassTabBar, GlassButton, GlassSheet. All follow docs/03 recipes; read the pinned package docs and map the recipe onto its real parameters.
- Aurora background widget (pausable, reduce-motion aware).
- domain: entities (Work, ProgressEntry, Category, PeriodSnapshot), period_math (periodStartFor, weekStartOf, shiftPeriod), rollup, streak, repository interfaces, use cases (CreateWork, UpdateWork, ArchiveWork, DeleteWork, SetProgress, WatchPeriodSnapshot).
- data: Drift tables exactly as docs/02 section 5, DAOs, migrations with schema snapshots, repository implementations, mappers.
- A debug-only "Glass gallery" page showing every glass component in liquid/frost/solid x light/dark.
- A debug-only seed generator (12 works across all cadences and 8 weeks of history).

Tests required: period_math (DST changes, year rollover, leap day, week start Mon/Sun/Sat), rollup, streak, SetProgress (upsert + event in one transaction), DAO and migration tests, widget tests for GlassSegmentedControl.

Definition of done: format + analyze + test all green; domain coverage >= 90 %; gallery page runs on Android. Summarise what you built, list any deviations from the docs, and show screenshots or recordings of the gallery if you can. Then stop.
````

---

## Prompt 2 — Phase 2 (Core loop, first usable app)

````
Continue with Phase 2 from docs/05-project-plan.md, using docs/04-screen-layouts.md and docs/layout-preview.html as the visual reference.

Build:
1. features/tasks/widgets/progress_scrubber.dart: implement the interaction spec in docs/04 section 10 exactly (gesture arena rules, step snapping, magnetic detents, precision scrub by vertical distance, accumulated delta so the thumb never jumps, haptics from docs/03 section 8, squash-and-stretch, brim-overflow at 100 %, double-tap thumb = 100 %, tap on track does nothing, Semantics slider with increase/decrease, RTL). The liquid fill follows the finger smoothly; the thumb and label show the snapped value.
2. WorkCard (frost tier), PeriodSummaryPanel, PeriodNavigator, filter chips.
3. Tasks page with Daily / Weekly / Monthly, wired to periodSnapshotProvider. Include the read-only daily strip in Weekly and the weekly bars in Monthly as described in docs/01 section 6 and docs/04 section 3. Persist the selected view.
4. Work editor bottom sheet (create + edit) with the defaults and validation from docs/04 section 5.
5. Work detail page with large scrubber, -5 / +5 steppers, Set 100 %, history sparkline for the last 14 periods, notes, schedule, edit/archive/delete, and the shared-element transition of the bar.
6. App shell with GlassTabBar, the separate "+" glass button, go_router routes, tab bar hide-on-scroll-down.
7. Undo toast (4 s) after every committed change.
8. Empty, loading and error states from docs/04 section 3.

Tests: widget tests for the scrubber (drag to value, snapping, detents, precision scrub, cancel, semantics), golden tests for Tasks (3 views x light/dark x 3 tiers), an integration test: add work, drag to 60 %, restart app, value is still 60 %.

Definition of done: the Phase 2 exit criteria in docs/05 pass; scrubbing and scrolling stay smooth on an Android device (report frame timings); format + analyze + test green. List deviations, then stop.
````

---

## Prompt 3 — Phase 3 (Breadth)

````
Continue with Phase 3 from docs/05-project-plan.md.

Build, following docs/04 and docs/01:
- Calendar screen with month heatmap (cell colour = that day's daily-works average), day selection list, and "Open day" navigation into Tasks (Daily) anchored to that date.
- Insights screen: range toggle (4 weeks / 3 months / year), completion-rate trend, streak, best weekday, category split, most neglected works. Use fl_chart on frost panels; glass tooltip for the selected point.
- Reminders: permission flow, schedule/cancel per work (minutesOfDay + weekdayMask), reschedule after reboot, notification tap deep-links to /work/:id. Notification text uses the work title only.
- Settings screen exactly as docs/04 section 8: theme, glass intensity (Full / Balanced / Off), week start, snap step, streak threshold, haptics, notifications status, JSON export / import via the share sheet and file picker (add file_picker or use the platform document APIs only after logging it in docs/decisions.md).
- Onboarding (3 screens, skippable).
- Consistent empty / loading / error states on every screen.

Tests: export -> wipe -> import round-trip is lossless; week-start setting changes weekly views correctly; streak calculation with the configurable threshold; reminders scheduling logic (unit-test the scheduling calculator, not the plugin).

Definition of done: every screen in docs/04 exists and is navigable; format + analyze + test green. List deviations, then stop.
````

---

## Prompt 4 — Phase 4 (Polish, performance, accessibility)

````
Continue with Phase 4 from docs/05-project-plan.md.

1. Accessibility: audit every screen with TalkBack semantics in mind, fix missing labels, verify text scale 200 % on 360 dp width, verify contrast >= 4.5:1 in all tiers using worst-case aurora backgrounds (add golden tests), make Reduce Motion and Reduce Transparency switch tiers and animations correctly.
2. Performance: profile scrubbing and list scrolling in profile mode. Report frame build/raster p95. If over budget (docs/02 section 11) tune blur radii, reduce liquid surfaces, swap list cards to pre-tinted fake glass past 12 items, and confirm the performance guard downgrades tiers. Verify the aurora pauses when the app is backgrounded.
3. Golden test matrix: 3 views x 2 themes x 3 tiers x text scale 1.0 and 1.5.
4. Visual polish against docs/03: rim-light and specular values, thumb lens magnification, brim-overflow, tab lens stretch, sheet detents.
5. App icon (glass vessel on aurora), adaptive icon for Android, splash screen.
6. Release build config: signing placeholders, ProGuard/R8 sanity, flutter build appbundle --release succeeds.
7. Write docs/RELEASE.md: how to build, how to run tests, known limitations, and the QA checklist from docs/05 section 5 with pass/fail per item.

Definition of done: QA checklist is complete or has an explicit note for each unchecked item; performance budget met or the gap is documented with a plan. Summarise results, then stop.
````

---

## Optional prompts

**Fix the glass look**
````
The glass looks too flat/too heavy on [screen] in [theme]. Compare against docs/03 section 5 and docs/layout-preview.html. Adjust only GlassSurface recipe values and the aurora blob opacities, not individual screens. Show before/after screenshots in light and dark for all three tiers.
````

**Add a feature without breaking architecture**
````
Add [feature]. First write a short design note in docs/decisions.md covering data model changes, migration, providers, UI changes and tests. Wait for my approval, then implement following the standing rules from the master prompt.
````

**Code review pass**
````
Review the whole codebase against the standing rules in the master prompt and docs/02. List violations by severity (layer breaches, DB access in widgets, hard-coded tokens/strings, missing semantics, glass-budget breaches, date-handling mistakes). Fix P0/P1 items and open a checklist for the rest.
````
