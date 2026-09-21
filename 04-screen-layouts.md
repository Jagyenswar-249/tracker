# 04 — Screen Layouts

Portrait phones first (360–430 dp wide). Tablets/landscape: constrain content to a 600 dp centred column in v1.

## 1. Navigation map

```
                    ┌───────────────┐
   Splash ─────────▶│  Onboarding   │ (first launch only, skippable)
                    └──────┬────────┘
                           ▼
        ┌──────────── App Shell (GlassTabBar + "+") ────────────┐
        │                                                        │
   Tasks (home)      Calendar        Insights        Settings    │
   Daily|Weekly|Monthly   │              │              │       │
        │                 │              │              ├─ Appearance / Glass
        ├─ Work Detail ◀──┘              │              ├─ Schedule (week start)
        │    └─ Edit (sheet)             │              ├─ Reminders
        └─ "+" → Work Editor (sheet)     │              └─ Data (export / import)
                                         └─ Insight detail (v1.1)
```

Routes (go_router): `/tasks`, `/work/:id`, `/calendar`, `/insights`, `/settings`, modal sheet `editor?workId=`. Notification tap → `/work/:id`.

## 2. Global layout grid

```
 ┌──────────────────────────────────┐
 │ status bar (safe area)           │
 │ 20 dp side padding               │
 │ ...content scrolls...            │
 │                                  │
 │ (content bottom padding 112 dp   │
 │  so nothing hides behind the     │
 │  floating tab bar)               │
 │  ╭────────────────────╮  ╭───╮   │
 │  │  glass tab bar     │  │ + │   │  64 dp tall, 12 dp above safe area
 │  ╰────────────────────╯  ╰───╯   │
 └──────────────────────────────────┘
```

## 3. Tasks (home)

```
┌──────────────────────────────────────┐
│ Good evening                    (avatar/settings shortcut, optional)
│ Tasks                                │  Title 28
│                                      │
│ ╭──────────────────────────────────╮ │
│ │ ( Daily )  Weekly   Monthly      │ │  GlassSegmentedControl (Liquid)
│ ╰──────────────────────────────────╯ │
│   ‹   Mon, 21 Sep   ›     [Today]    │  PeriodNavigator
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ 62%                     ◔        │ │  PeriodSummaryPanel (Frost)
│ │ of today                         │ │
│ │ Done 2/5  Left 3  Overdue 1  6d  │ │
│ │ Next: Report draft · 5 pm        │ │
│ └──────────────────────────────────┘ │
│                                      │
│ [All] [Active] [Done] [Overdue] [⌄]  │  filter chips (Frost)
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ ● Write methods section  Overdue │ │  WorkCard
│ │   Thesis · due Fri               │ │
│ │ ▓▓▓▓▓▓▓▓◉░░░░░░░░░░░░░░    45%   │ │  ProgressScrubber
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ ● Gym                            │ │
│ │   Health · every day             │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓◉  100% ✓  │ │
│ └──────────────────────────────────┘ │
│              ...                     │
│  ╭──────────────────────╮  ╭───╮     │
│  │ ▣Tasks  ▢  ▢  ▢      │  │ + │     │
│  ╰──────────────────────╯  ╰───╯     │
└──────────────────────────────────────┘
```

**Weekly variant** (differences only)

```
│   ‹   14 – 20 Sep   ›     [This week]│
│ ┌──────────────────────────────────┐ │
│ │ 71%  of this week          ◔     │ │
│ │ Done 1/3  Left 2  Overdue 0  6d  │ │
│ │  M   T   W   T   F   S   S       │ │  Daily strip (read-only, tap to drill in)
│ │  ●   ●   ◐   ○   ·   ·   ·       │ │  dot fill = that day's daily-works average
│ └──────────────────────────────────┘ │
│  Weekly works  (editable)            │  list header (plain text, sentence case)
│   … WorkCards …                      │
```

**Monthly variant**

```
│   ‹   September 2026   ›  [This month]│
│ ┌──────────────────────────────────┐ │
│ │ 54%  of this month         ◔     │ │
│ │ W1 ▓▓▓▓▓  W2 ▓▓▓▒  W3 ▓▓  W4 ░  │ │  weekly bars
│ │ View heatmap ›                   │ │
│ └──────────────────────────────────┘ │
│  Monthly works (editable) …          │
```

**States**

| State | Treatment |
|---|---|
| Empty (no works in period) | Illustration: empty glass vessel with a slow bubble. Text: "Nothing scheduled today." Button: "Add work" |
| Loading | 3 frost skeleton cards with a slow shimmer (frozen under Reduce Motion) |
| Error | Frost card: "Couldn't load your works. Restart the app. If it keeps happening, export your data from Settings." + "Try again" |
| All done | Summary shows 100 % with a kelp ring and a small brim animation once per period |
| Past period | Navigator chip shows "Past"; bars remain editable |

**Interactions**
- Tap segment / drag thumb → view switches; list cross-fades 180 ms; aurora accent shifts.
- Horizontal swipe on the summary panel or empty area → previous / next period.
- Pull-to-refresh not needed (local data).
- Scroll down → tab bar hides; scroll up → returns.

## 4. Work detail

```
┌──────────────────────────────────────┐
│ ‹ Back                        ⋯ (menu)│  glass icon buttons
│                                      │
│ ● Write methods section              │  Title 28, colour dot
│   Thesis · Weekly · due Fri          │
│                                      │
│             45%                      │  Display 56, tabular
│                                      │
│  ▓▓▓▓▓▓▓▓▓▓◉░░░░░░░░░░░░░░░░░░░░░░   │  large scrubber (height 20)
│  [ −5 ]                     [ +5 ]   │  glass steppers
│  [ Set 100% ]                        │
│                                      │
│ ┌──────────────────────────────────┐ │
│ │ History (last 14 weeks)          │ │  Frost panel + sparkline / bars
│ │  ▂▃▅▇█▆▅▇▇█▆▅▃▅                  │ │
│ │ Avg 63%  Best 100%  Streak 3     │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Notes                            │ │
│ │ Cover baseline + ablation…       │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Schedule   Weekly                │ │
│ │ Reminder   Fri 9:00 am           │ │
│ │ Effort     ●●○                   │ │
│ └──────────────────────────────────┘ │
│  [ Edit ]              [ Archive ]   │
└──────────────────────────────────────┘
```

Menu: Edit, Duplicate, Archive, Delete (confirm with destructive glass button + heavy haptic). The bar is a shared element from the card (Hero transition 280 ms).

## 5. Work editor (bottom sheet)

```
╭──────────────────────────────────────╮
│                ▬▬▬                   │  glass grabber
│ New work                             │
│ ┌──────────────────────────────────┐ │
│ │ Title                            │ │  required
│ └──────────────────────────────────┘ │
│ Repeats                              │
│ ( Daily )  Weekly  Monthly  One-off  │  segmented (Liquid)
│ Days   M T W T F S S                 │  only for Daily (chips)
│ Due    [ 25 Sep 2026 ]               │  only for One-off
│ Category  [ Thesis ⌄ ]               │
│ Colour   ● ● ● ● ● ● ● ●             │
│ Effort   [ 1 ][ 2 ][ 3 ]             │
│ Reminder [ off ⌄ ]                   │
│ Notes    …                           │
│                                      │
│ [ Cancel ]            [ Add work ]   │  primary = lagoon-tinted glass
╰──────────────────────────────────────╯
```

Only the title is required. Defaults: Daily, all days, effort 1, colour lagoon, no reminder. Keyboard opens the sheet to the 92 % detent. Validation is inline and specific: "Give this work a title."

## 6. Calendar

```
┌──────────────────────────────────────┐
│ Calendar                             │
│  ‹   September 2026   ›              │
│  M   T   W   T   F   S   S           │
│ ┌──┬──┬──┬──┬──┬──┬──┐               │
│ │  │  │  │  │  │  │  │  heat cell =  │
│ │ 1│ 2│ 3│ 4│ 5│ 6│ 7│  daily        │
│ ├──┼──┼──┼──┼──┼──┼──┤  average,     │
│ │ …                                  │  colour = lagoon opacity 10→90 %
│ └──┴──┴──┴──┴──┴──┴──┘               │
│ Legend  ░ 0–25  ▒ 25–60  ▓ 60–100    │
│                                      │
│ Mon, 21 Sep  ·  62%                  │  selected-day list (reuses WorkCard, compact)
│  ● Gym            ▓▓▓▓▓▓▓▓▓▓ 100%    │
│  ● Reading        ▓▓▓▓░░░░░░  40%    │
└──────────────────────────────────────┘
```

Tap a day → list below updates. Double-tap or "Open day" → Tasks (Daily) anchored to that date.

## 7. Insights

```
┌──────────────────────────────────────┐
│ Insights                             │
│ ( 4 weeks )  3 months   Year         │  range segmented
│ ┌──────────────────────────────────┐ │
│ │ Completion rate       ▁▃▄▆▅▇█    │ │  line/bars per week
│ │ 68%  ▲ 6 vs previous             │ │
│ └──────────────────────────────────┘ │
│ ┌────────────┐ ┌───────────────────┐ │
│ │ Streak     │ │ Best weekday      │ │
│ │ 6 days     │ │ Tuesday · 82%     │ │
│ └────────────┘ └───────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ By category                      │ │  horizontal bars
│ │ Thesis   ▓▓▓▓▓▓▓▓░░ 78%          │ │
│ │ Health   ▓▓▓▓▓▓░░░░ 61%          │ │
│ └──────────────────────────────────┘ │
│ ┌──────────────────────────────────┐ │
│ │ Most neglected works             │ │  lowest average, top 3
│ └──────────────────────────────────┘ │
└──────────────────────────────────────┘
```

## 8. Settings

```
┌──────────────────────────────────────┐
│ Settings                             │
│ Appearance                           │
│   Theme            System ⌄          │
│   Glass intensity  ( Full | Balanced | Off )
│   Reduce motion    follows system    │
│ Progress                             │
│   Snap step        1% · 5% · 10%     │
│   Streak threshold 80%               │
│   Week starts on   Monday ⌄          │
│   Haptics          [toggle]          │
│ Reminders                            │
│   Notifications    permission status │
│ Data                                 │
│   Export JSON  ·  Import JSON        │
│ About                                │
└──────────────────────────────────────┘
```

Rows are Frost tiles grouped in sections; toggles are glass capsules.

## 9. Onboarding (3 screens, skippable)

1. "Every work is a vessel." Animation: the scrubber fills itself from 0 to 70 %.
2. "Drag to fill. See your day, week and month." Segmented control demo.
3. "Add your first work." Inline title field + cadence chips → lands on Tasks with the work present.

## 10. Progress scrubber interaction spec (implementation-ready)

```
State:       idle → armed (touch down) → dragging → settling → idle
Input:       HorizontalDragGestureRecognizer, slop 8 dp; also Semantics increase/decrease
Compute:     raw = clamp((dx_from_track_left) / trackWidth, 0, 1) * 100
             speed factor from vertical distance d (dp) away from the bar:
                 d ≤ 40  → 1.0     40 < d ≤ 100 → 0.5     d > 100 → 0.25
             delta_raw = Δx / trackWidth * 100 * factor   (accumulate, don't recompute from absolute x
                                                            when factor ≠ 1, or the thumb will jump)
             snapped = round(raw / step) * step
             magnetic: if |snapped - d| ≤ 2 for d in {0,25,50,75,100} → snapped = d
Output:      onChanged(snapped)     — local UI only, fires only when the value changes → haptic tick
             onChangeEnd(snapped)   — commits via SetProgress use case, shows undo
Visual:      liquidFraction = raw / 100  (smooth, unsnapped)  ← liquid follows finger
             thumb position = snapped   (thumb is what "clicks")
             bubble text    = snapped
Edge cases:  RTL → mirror direction. Text scale ≥ 1.5 → card wraps title to 2 lines, bar unaffected.
             Drag cancelled (system gesture) → revert to last committed value.
             Rapid drags → last write wins, events are still appended per commit.
```
