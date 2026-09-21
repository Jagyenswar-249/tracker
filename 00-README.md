# Brim — Work Progress Tracker (Mobile)

> Working name: **Brim**. Every work is a glass vessel; you drag to fill it to the brim.

A mobile app where each **work** has a completion bar you drag to record how far along it is, with **daily, weekly and monthly** views that roll those bars up into period-level info. The whole UI uses an **iOS-26-style Liquid Glass** look.

## Files in this bundle

| File | What it contains |
|---|---|
| `01-product-spec.md` | Vision, concepts, features (MVP / v1.1 / v2), user stories, business rules |
| `02-architecture.md` | Stack, layers, folder structure, data model (Drift/SQLite), period logic, state, testing, CI |
| `03-design-system-liquid-glass.md` | Liquid Glass tokens, material tiers, components, motion, haptics, accessibility, fallbacks |
| `04-screen-layouts.md` | Navigation map, wireframes for every screen, the progress-scrubber interaction spec |
| `05-project-plan.md` | Phases, milestones, definition of done, risks, QA checklist |
| `06-antigravity-prompt.md` | Master prompt + phase-by-phase follow-up prompts for Antigravity |
| `layout-preview.html` | Interactive visual preview (open in Chrome/Brave): glass UI, draggable bars, Daily/Weekly/Monthly switch |

## Decisions I made so you can start immediately

Change any of these and the docs still hold; the Antigravity prompt lists them as "Fixed decisions", so edit them there too.

1. **Flutter (Dart)**, one codebase for Android + iOS. Liquid Glass on Flutter is done with the `liquid_glass_renderer` package (Impeller-only, currently experimental) behind our own `GlassSurface` wrapper, so it can be swapped or downgraded per device.
2. **Local-first, no backend in the MVP.** Everything is stored on device (SQLite via Drift). Shared "our works" workspaces are a Phase 5 feature (Supabase), and the data model is already sync-ready.
3. **Solo use first, team later.** You wrote "our works", so team sharing is designed for but not built in v1.
4. **Progress is per period.** A daily work has a separate 0–100 % bar for each day, a weekly work for each week, and so on. That is what makes daily/weekly/monthly stats possible.
5. **Glass is for the control layer, not for content.** Nav bar, segmented control, scrubber thumb, buttons and sheets are true liquid glass. Work cards are lighter frosted tiles. This matches how Liquid Glass is meant to be used and keeps the frame rate healthy.

## Practical notes

- Development machine is Windows: build and test on **Android** locally. iOS builds need a Mac or a cloud CI (Codemagic / GitHub Actions macOS runners).
- Liquid Glass shaders need **Impeller**. Flutter web preview will show the fallback (blur-only) look, so judge the real effect on an Android device or emulator.

## How to use with Antigravity

1. Create an empty folder `brim/`, put this whole bundle inside as `brim/docs/`.
2. Open `brim/` as the workspace in Antigravity.
3. Paste the **Master Prompt** from `06-antigravity-prompt.md` and let the agent produce its implementation plan first.
4. Approve the plan, then feed the phase prompts one at a time, reviewing each phase's checklist before moving on.

## Open questions (answer whenever, none block the start)

- Is this just for you, or a team app from day one? (If team: pull Phase 5 forward.)
- Should unfinished weekly/monthly progress **carry over** into the next period? (Default: no, each period starts at 0 %.)
- App name and package id (`com.yourname.brim` is a placeholder).
