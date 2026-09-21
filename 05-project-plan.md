# 05 — Project Plan

Timeline assumes one developer working with an AI coding agent (Antigravity), roughly 15–20 focused hours per week. Halve it if two people work in parallel (one on domain/data, one on glass UI).

## 1. Phases at a glance

```
Week 0     Phase 0  Setup ─────────┐
Week 1     Phase 1  Foundation ────┤  ← domain + data + glass kit (no screens yet)
Week 2     Phase 2  Core loop ─────┤  ← Tasks screen, scrubber, editor, detail   ★ usable app
Week 3     Phase 3  Breadth ───────┤  ← Calendar, Insights, Reminders, Settings
Week 4     Phase 4  Polish & beta ─┘  ← a11y, perf, goldens, icon, store assets
Week 5+    Phase 5  Team & sync (v2)
```

## 2. Phase details

### Phase 0 — Setup (0.5–1 day)

- Install Flutter stable, Android Studio SDK/emulator (Windows). Verify `flutter doctor`.
- `flutter create --org com.yourname --project-name brim brim`; copy this bundle to `docs/`.
- Add lints, `analysis_options.yaml`, CI workflow, `.gitignore`, README.
- Add dependencies from `02-architecture.md`; bundle fonts.
- Confirm **Impeller** is on for Android; run a 20-line spike screen with one `liquid_glass_renderer` surface over an aurora background on a real device or emulator.

**Exit criteria:** app runs on Android; CI green; spike shows refractive glass; decision logged if the package is unusable (then Frost becomes the top tier).

### Phase 1 — Foundation (Week 1)

| Work item | Output |
|---|---|
| Design tokens + theme (light/dark) | `core/theme/*` |
| `GlassSurface`, tiers, `GlassScope`, tier provider | `core/glass/*` + widget tests |
| Aurora background widget | animated, pausable, reduce-motion aware |
| Domain entities + `period_math` + `rollup` + `streak` | 100 % unit-tested incl. DST/leap/week starts |
| Drift schema, DAOs, migrations, repositories | in-memory DB tests |
| Use cases: create/update/archive work, `SetProgress`, `WatchPeriodSnapshot` | tested with fakes |
| Seed/demo data generator (debug only) | 12 works, 8 weeks of history |

**Exit criteria:** `flutter test` green, coverage ≥ 90 % in `domain/`, a "Glass gallery" debug page shows every component in all 3 tiers × 2 themes.

### Phase 2 — Core loop (Week 2) ★ first usable version

| Work item | Output |
|---|---|
| `ProgressScrubber` (gesture, snap, precision scrub, haptics, semantics) | widget-tested |
| `WorkCard`, `PeriodSummaryPanel`, `PeriodNavigator` | golden tests |
| `GlassSegmentedControl` + Tasks page (Daily / Weekly / Monthly) | live from DB |
| Work editor sheet (create/edit) | validation, defaults |
| Work detail page with stepper + history sparkline | Hero transition |
| `GlassTabBar` + "+" button + app shell + router | scroll-hide behaviour |
| Undo toast | 4 s |

**Exit criteria:** add a work, drag it to 60 %, kill the app, reopen: 60 % is there; switch between the three views; summary numbers are correct against a hand-computed sample.

### Phase 3 — Breadth (Week 3)

- Weekly daily-strip and Monthly weekly-bars + heatmap.
- Calendar screen.
- Insights screen (range toggle, completion trend, streak, best weekday, category split, neglected works).
- Reminders (permission flow, schedule/cancel, notification tap deep link).
- Settings (theme, glass intensity, week start, snap step, streak threshold, haptics, export/import JSON).
- Onboarding.
- Empty / loading / error states everywhere.

**Exit criteria:** every screen in `04-screen-layouts.md` exists and is navigable; export → wipe → import round-trips losslessly (test).

### Phase 4 — Polish and beta (Week 4)

- Accessibility pass: TalkBack walkthrough, text scale 200 %, contrast checks in all tiers, Reduce Motion / Transparency behaviour.
- Performance pass on a mid-range Android device: profile scrubbing and scrolling, tune blur radii, enable the performance guard, reduce liquid surface count where needed.
- Golden tests for 3 views × 2 themes × 3 tiers.
- App icon (glass vessel), splash, Play Store listing assets (screenshots, feature graphic, short and long description).
- Crash reporting decision (opt-in only, or none).
- Internal test track release (Google Play) or side-loaded APK to 5–10 people; collect feedback.

**Exit criteria:** performance budget met (see `02-architecture.md` §11), no P0/P1 bugs, checklist in §5 signed off.

### Phase 5 — Team and sync (v2, after launch)

Supabase project, auth, workspaces and invites, outbox sync, per-member progress, realtime bars, activity feed, home-screen widget. Plan separately once v1 has real users.

## 3. Milestones

| Milestone | When | Demo |
|---|---|---|
| M0 Spike | End of Phase 0 | One liquid glass capsule over aurora, on device |
| M1 Engine | End of Phase 1 | Glass gallery + passing domain tests |
| M2 Usable | End of Phase 2 | Track real work for a week (dogfood) |
| M3 Feature-complete | End of Phase 3 | All screens |
| M4 Beta | End of Phase 4 | Test track build |

## 4. Definition of done (every task)

- Code follows the layer rules (no DB in widgets, no Flutter in domain).
- `dart format`, `flutter analyze --fatal-infos`, `flutter test` all pass.
- New logic has tests; new UI has a widget or golden test.
- Works in light + dark and in all three glass tiers.
- No hard-coded colours, spacings or strings (tokens and ARB only).
- Semantics labels present on interactive elements.
- No new dependency added without a note in `docs/decisions.md`.

## 5. QA checklist (before beta)

**Functional**
- [ ] Create, edit, archive, delete a work in each cadence
- [ ] Daily weekday mask respected
- [ ] One-off appears in its due period and becomes overdue afterwards
- [ ] Weekly views honour week-start setting (Mon / Sun / Sat)
- [ ] Month rollover, year rollover, leap day, DST change dates
- [ ] Progress persists across restart and across device reboot
- [ ] Undo restores the previous value
- [ ] Export / import round-trip
- [ ] Reminders fire, survive reboot, and open the right work

**Gesture**
- [ ] Scrubber inside a scrolling list: vertical scroll still works, horizontal drag never scrolls the list
- [ ] Precision scrub speeds behave and never make the thumb jump
- [ ] Multi-touch does not corrupt state; system back-swipe does not commit a value

**Visual**
- [ ] Glass legible over every aurora colour, light and dark
- [ ] No text below 4.5:1 contrast in any tier
- [ ] Layout intact at text scale 200 % and on a 360 dp wide device
- [ ] Notch / punch-hole / gesture bar insets correct

**Performance**
- [ ] Scrubbing at 60 fps on a mid-range Android phone
- [ ] 100 works × 2 years of history: home screen still < 100 ms to first frame after switching views
- [ ] Battery: aurora paused in background (verify via Battery Historian or DevTools)

## 6. Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `liquid_glass_renderer` is experimental; API or perf changes | High | Medium | Isolate behind `GlassSurface`; pin version; Frost/Solid tiers always work; spike in Phase 0 |
| Glass hurts frame rate on low-end Android | High | High | Budget of ≤ 3 liquid surfaces, performance guard, Balanced/Off settings, FakeGlass in lists |
| Drag gesture conflicts with list scroll or system back-swipe | Medium | High | Custom gesture arena rules, slop 8 dp, tests, edge-inset safe zone of 16 dp for scrubber start |
| Period/date bugs (DST, week start, rollover) | Medium | High | Date-only strings, `DateTime(y,m,d)` constructors only, exhaustive unit tests |
| Scope creep into team features | High | Medium | v1 is local-only; Phase 5 is a separate plan |
| Contrast failures on translucent surfaces | Medium | Medium | Golden tests with worst-case backgrounds, scrim on text over liquid glass |
| iOS testing needs macOS | Certain (Windows dev) | Low | Android-first; use Codemagic / macOS CI for iOS builds when needed |
| Agent generates code that violates architecture | Medium | Medium | Standing rules in the prompt; review each phase; analyzer rules; small phased prompts |

## 7. Backlog after v1.0

Search + filters, drag reorder, category manager, home-screen widget, CSV export, app shortcuts, streak-freeze, weekly review screen, shared workspaces, cloud backup, watch glance.
