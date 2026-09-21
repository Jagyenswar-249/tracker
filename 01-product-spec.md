# 01 — Product Spec

## 1. Vision

Give people one calm place to see **how far along every piece of work is**, and to update it in one gesture: drag the bar. Then answer three questions instantly: *What is today's progress? How is this week going? How is this month shaping up?*

**Primary job to be done:** "Let me record progress on my works in two seconds, and show me where I stand today / this week / this month."

**Design promise:** it feels like liquid: dragging fills a glass vessel, and the interface around it is glass.

## 2. Users

| Persona | Need |
|---|---|
| Student / researcher | Track thesis chapters, experiments, reading, assignments with partial completion |
| Freelancer / builder | Track deliverables per client with % done, weekly targets, monthly goals |
| Small team (v2) | Shared works with per-person progress, one glance status |

## 3. Core concepts

- **Work**: a thing you are working on (e.g. "Write methods section", "Gym", "Monthly report").
- **Cadence**: how often the work repeats. `daily`, `weekly`, `monthly`, or `once` (one-off with a due date).
- **Period**: one occurrence of a cadence: a specific day, week, or month.
- **Progress entry**: the 0–100 % value for one work in one period. Recurring works get a fresh 0 % entry every period; history is kept.
- **Roll-up**: the period-level number computed from the works in that period.

## 4. Features

### MVP (v1.0)

1. **Works CRUD**: title, notes, category, colour, cadence, active weekdays (for daily), due date (for one-off), effort weight (1–3), reminder time.
2. **Progress scrubber** on every work card: drag horizontally to set 0–100 %, snapping to steps (default 5 %), magnetic detents at 0/25/50/75/100, haptic ticks, live percentage bubble, 4-second undo.
3. **Daily / Weekly / Monthly views** with a period navigator (previous / next / jump to today).
4. **Period summary panel**: overall %, done / total, remaining, overdue count, streak, next due.
5. **Work detail**: large scrubber, ±5 % steppers, history sparkline (last 14 periods), notes, schedule, edit / archive / delete.
6. **Calendar**: month heatmap, tap a day to open that day's list.
7. **Insights**: completion rate over time, streaks, best weekday, category split.
8. **Local reminders** per work.
9. **Settings**: theme (system / light / dark), glass intensity (Full / Balanced / Off), week start, snap step (1 / 5 / 10 %), haptics on/off, JSON export / import.
10. **Liquid Glass UI** across the app with automatic fallback tiers.

### v1.1

Search and filters, drag-to-reorder, category management, home-screen widget, app shortcuts ("Add work"), CSV export.

### v2

Shared workspaces (invite by link), per-member progress, comments, activity feed, cloud sync + backup, Wear OS / watchOS glance.

## 5. User stories and acceptance criteria

| # | Story | Acceptance |
|---|---|---|
| US1 | As a user I drag a work's bar to set my progress | Bar follows the finger at 60 fps; value snaps to step; percent bubble follows the thumb; value persists after app restart |
| US2 | I switch between Daily / Weekly / Monthly | List, summary and navigator update within one frame of the switch animation ending; selected segment persists between launches |
| US3 | I add a work in under 10 seconds | Sheet opens from "+", only title is required, sensible defaults (daily, all days, effort 1) |
| US4 | I mark a work 100 % | Success haptic, brim-overflow animation, card shows "Done"; undo available for 4 s |
| US5 | I see how the week is going | Weekly summary shows overall %, 7-day strip of daily averages, list of weekly works and one-offs due that week |
| US6 | I see how the month is going | Monthly summary shows overall %, week-by-week bars, heatmap, monthly works and one-offs due that month |
| US7 | I go back to a previous day / week / month | Navigator shows that period's saved progress; editing past periods is allowed |
| US8 | I get a reminder | Local notification at the set time; tapping opens that work |
| US9 | The app works offline, always | No network permission required in the MVP |
| US10 | I can use the app with Reduce Transparency / Reduce Motion | Glass falls back to solid tinted surfaces; animations become fades |

## 6. Business rules

**Progress**
- Value is an integer 0–100. Steps: 1, 5 (default) or 10.
- 100 % means done. Dropping below 100 % re-opens the work.
- Each change appends an event to `progress_events` (used for undo, streaks and insights).

**Which works appear in which view**
- **Daily view** shows daily works active on that weekday, plus one-offs due that day (editable).
- **Weekly view** shows weekly works and one-offs due that week (editable), plus a read-only **Daily works** strip: 7 dots, each the day's average. Tapping a dot drills into that day.
- **Monthly view** shows monthly works and one-offs due that month (editable), plus a read-only **Weekly works** strip and a day heatmap.
- Editing always happens at the work's own cadence; higher views summarise lower ones. This avoids the same work being editable in three places with three different numbers.

**Roll-up**
- `PeriodProgress = Σ(effort × percent) / Σ(effort)` over the editable works shown in that period.
- The summary panel also shows `done / total`, where done means 100 %.

**Reset and history**
- A new period starts at 0 % for every recurring work. Nothing is overwritten; past periods stay editable.
- Weekly works belong to the week containing the viewed date, using the user's week-start setting.

**Overdue**
- A one-off is overdue if its due date is before today and it is below 100 %. Overdue works stay visible in every period from the due date until done, marked with a coral "Overdue" chip.

**Streak**
- A day is "successful" when Daily PeriodProgress ≥ threshold (default 80 %, configurable). Streak = consecutive successful days ending today (today does not break the streak until it ends).

**Dates**
- All dates are local calendar dates stored as `YYYY-MM-DD`. Never store timestamps for period logic; avoids timezone and DST bugs.

## 7. Voice and copy

Plain verbs, sentence case, no filler.

- Buttons: "Add work", "Save changes", "Archive", not "Submit".
- Empty state (Daily): "Nothing scheduled today. Add a work to start filling."
- Undo toast: "Set to 60 %  ·  Undo".
- Errors say what happened and what to do: "Couldn't save. Storage is full. Free some space and try again."

## 8. Non-goals (v1)

Subtasks/checklists, time tracking, Gantt charts, file attachments, social features, AI features.

## 9. Success metrics

- Time to update progress on a work ≤ 2 s (median).
- Time to add a work ≤ 10 s (median).
- Crash-free sessions ≥ 99.5 %.
- Scrubber and list scroll stay ≥ 55 fps p95 on a mid-range Android phone.
- Cold start < 2 s on a mid-range Android phone.
