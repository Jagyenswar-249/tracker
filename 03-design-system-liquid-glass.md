# 03 — Design System: Liquid Glass

## 1. Concept

**Brim** is a set of glass vessels floating over a slow-moving aurora. Each work is a vessel; progress is liquid rising inside it. The chrome (tab bar, segmented control, buttons, sheets, scrubber thumb) is Liquid Glass: it **refracts** what is behind it at the edges, catches a **specular rim light**, **stretches** when touched and **morphs** between states.

Three ideas carry the design:

1. **Something must be behind the glass.** Glass on a flat background looks like grey plastic. Every screen sits on an *aurora field* (soft coloured light blobs on a deep ink background) so refraction and tint have something to show.
2. **Glass is the control layer; content stays quieter.** Nav, segmented control, thumb, buttons and sheets are refractive glass. Work cards are lighter frosted tiles. This mirrors how Liquid Glass is meant to be used and protects performance.
3. **The one memorable moment is the scrubber.** A glass lens slides along a liquid-filled capsule. Everything else stays disciplined.

## 2. Colour

### Dark (default)

| Token | Hex | Use |
|---|---|---|
| `abyss` | `#0B1622` | Base background |
| `deep` | `#10263A` | Secondary surfaces, gradient partner |
| `foam` | `#EAF7F6` | Primary text on dark |
| `mist` | `#9DB4BF` | Secondary text (min 4.5:1 on abyss) |
| `lagoon` | `#2EC4B6` | Brand / primary accent, default work colour |
| `coral` | `#FF6B81` | Overdue, destructive |
| `saffron` | `#FFC24B` | Warnings, weekly accent |
| `orchid` | `#9B8CFF` | Monthly accent |
| `kelp` | `#5BD68A` | Done / success |

### Light

| Token | Hex |
|---|---|
| `bg` | `#EEF6F5` |
| `ink` | `#0B1F2A` |
| `inkSoft` | `#3F5A66` |
| Accents | same hues, 8–10 % darker for contrast on light |

**Work palette** (user picks one per work): lagoon, coral, saffron, orchid, kelp, `sky #5AB8FF`, `rose #FF8FD0`, `sand #D9C5A0`.

**View accents:** Daily = lagoon, Weekly = saffron, Monthly = orchid. The summary panel and segmented thumb take the view accent.

### Aurora background

- Base: linear gradient `abyss → deep` (top to bottom).
- 4 radial blobs (lagoon, orchid, coral, saffron) at 18–28 % opacity, radius 40–60 % of screen width, Gaussian blur σ ≈ 60.
- Slow drift: each blob moves ±8 % on a 30–45 s ease-in-out loop, phase-offset. **Static** when Reduce Motion is on or the app is backgrounded.
- Light mode: `bg` base with the same blobs at 35–45 % opacity in pastel.
- The blob nearest the active view's accent gets +6 % opacity (subtle colour cue when switching views).

## 3. Typography

| Role | Family | Size / line | Weight | Notes |
|---|---|---|---|---|
| Display (big percent) | Bricolage Grotesque | 56 / 56 | 700 | tabular numerals, `-1` letter-spacing |
| Title | Bricolage Grotesque | 28 / 32 | 700 | screen titles |
| Headline | Bricolage Grotesque | 18 / 24 | 600 | work titles |
| Body | Figtree | 15 / 22 | 400 | notes |
| Label | Figtree | 13 / 18 | 600 | chips, captions |
| Micro | Figtree | 11 / 14 | 500 | axis labels |

Sentence case everywhere. No all-caps labels. Numbers use tabular figures so a changing percent never jitters.

## 4. Shape, spacing, elevation

- **Spacing** (4-pt grid): 4, 8, 12, 16, 20, 24, 32, 48. Screen side padding 20.
- **Radii:** capsule (fully round) for controls, 28 for cards, 36 for sheets, 22 for chips' container groups. The thumb and tab bar are capsules, cards are continuous-corner rounded rectangles (superellipse where the package supports it).
- **Elevation is light, not shadow:** glass gets a soft ambient shadow (`0 12 32 rgba(0,0,0,.28)` dark, `.12` light) plus a rim light. No stacked drop shadows on frost cards.

## 5. Material tiers

| Tier | Where used | Recipe | Cost |
|---|---|---|---|
| **Liquid** | Tab bar, "+" button, segmented control, scrubber thumb while dragging, sheets' grabber area | Refraction shader + blur + tint + rim + specular + interactive stretch | High. ≤ 3 on screen |
| **Frost** | Work cards, summary panel, chips, settings rows | `BackdropFilter` blur σ 14 + tint + rim; or pre-tinted fake glass in long lists | Medium |
| **Solid** | Fallback (Reduce Transparency, low-end, no Impeller) | Opaque tinted surface + rim | Low |

### Glass recipe (values are starting points; tune on device)

| Property | Liquid (dark) | Liquid (light) | Frost (dark) | Frost (light) |
|---|---|---|---|---|
| Backdrop blur σ | 18–22 | 18–22 | 14 | 14 |
| Tint | white @ 10 % | white @ 38 % | white @ 7 % | white @ 45 % |
| Refraction thickness | 14–20 | 12–16 | none | none |
| Refractive index | ≈ 1.2 | ≈ 1.2 | n/a | n/a |
| Rim light | 1 px gradient stroke, TL white @ 55 % → BR white @ 8 % | TL white @ 90 % → BR white @ 25 % | white @ 14 % uniform | white @ 60 % uniform |
| Specular gloss | linear gradient TL→center, white 22 % → 0 | white 45 % → 0 | 10 % → 0 | 30 % → 0 |
| Saturation boost behind glass | +20 % | +10 % | +10 % | +5 % |
| Content tint bleed | `tint` colour @ 12–18 % | @ 10–14 % | @ 8 % | @ 6 % |

Names of package parameters differ per version; the agent must read the pinned `liquid_glass_renderer` docs and map the recipe above onto them.

**Text on glass:** primary text is `foam` (dark) / `ink` (light) with a 0.5 dp shadow of the opposite polarity at 25 % for edge cases; never place `mist` text on liquid glass over a bright blob. Verify 4.5:1 against the worst-case background in goldens.

## 6. Components

### 6.1 `GlassTabBar` (Liquid)

- Floating capsule, height 64, horizontal margin 16, bottom margin 12 + safe area.
- 4 items: Tasks · Calendar · Insights · Settings (icon + label, label only on selected item).
- Selected item sits in a **glass lens** that slides between items with the `smooth` spring and stretches ~8 % along the direction of travel.
- A separate circular Liquid button "+" (56) sits to the right of the bar, 12 gap; the two glass shapes blend when close (shared glass layer).
- Hides on scroll down (translate + fade 180 ms), returns on scroll up or when the scroll view is at the top.

### 6.2 `GlassSegmentedControl` — Daily / Weekly / Monthly (Liquid)

- Full width minus 40, height 48, capsule.
- The thumb is a glass lens tinted with the **view accent**; on tap or drag it slides with a stretch, and the label colours cross-fade.
- Supports horizontal drag on the thumb with snapping to segments.
- Semantics: `SegmentedButton`-like with `selected` flag per segment.

### 6.3 `PeriodNavigator`

`‹  Mon, 21 Sep  ›` with a "Today" glass chip appearing when not on the current period. Weekly shows `14–20 Sep`, Monthly shows `September 2026`. Swiping the list area horizontally also changes period (optional, must not collide with the scrubber; scrubber wins inside its own bounds).

### 6.4 `PeriodSummaryPanel` (Frost, hero of the screen)

```
┌──────────────────────────────────────────┐
│  62%                     ◔ ring 62%      │  Display numeral + thin ring in view accent
│  of today                                │
│  ─────────────────────────────────────   │
│  Done 2/5   Left 3   Overdue 1   🔥 6d   │  four compact stats
│  Next due: Report draft · 5 pm           │
└──────────────────────────────────────────┘
```

Weekly adds the 7-dot **daily strip** under the stats; Monthly adds **weekly bars** (up to 5) and a link to the heatmap. Numbers animate with a 300 ms count tween when values change.

### 6.5 `WorkCard` (Frost)

```
┌──────────────────────────────────────────┐
│ ● Write methods section          Overdue │  colour dot · title · status chip
│   Thesis · due Fri                       │  category · schedule
│                                          │
│ ▓▓▓▓▓▓▓▓▓▓▓▓◉░░░░░░░░░░░░░░░░░░   45%   │  ProgressScrubber + percent
└──────────────────────────────────────────┘
```

- Card tinted 8 % with the work colour; the liquid inside the bar uses the full work colour.
- Tap card → detail (shared-element transition on the bar). Long-press → context menu (edit, archive, set 0 %, set 100 %).
- States: default, dragging (card lifts 2 dp, siblings dim to 92 %), done (bar full, check badge, title unstruck but muted), overdue (coral chip), disabled (archived).

### 6.6 `ProgressScrubber` — the signature element

**Anatomy**

```
 Track      capsule, height 14, frost-dark inset (inner shadow), hit area 48
 Liquid     fill in the work colour, top-lit gradient; leading edge has a
            meniscus: tiny sine wave, amplitude 2 dp, speed slows to 0 when idle
 Detents    4 tiny ticks at 25/50/75 % (and ends) — visible only while dragging
 Thumb      glass lens 40 × 28, Liquid tier, rim-lit; magnifies the liquid under it
 Bubble     percentage bubble (Frost) floats 36 dp above thumb while dragging, 1.2× text
```

**Behaviour**

| Aspect | Spec |
|---|---|
| Gesture | Horizontal drag anywhere on the track/thumb (slop 8 dp); wins over the parent list's vertical scroll once horizontal intent is detected |
| Snapping | Step from settings (default 5 %). Magnetic pull ±2 % around 0/25/50/75/100 |
| Precision scrub | While dragging, moving the finger vertically away from the bar slows the scrub: 0–40 dp = full speed, 40–100 dp = ½ speed (1 % steps), > 100 dp = ¼ speed. A small hint text appears ("Half-speed scrubbing") |
| Tap thumb twice | Sets 100 % |
| Tap on track | Does nothing (prevents accidental changes); the ± steppers on the detail screen handle fine tuning |
| Squash & stretch | Thumb scaleX = 1 + clamp(velocity/6000, 0, .12), scaleY inverse; springs back on release with `bouncy` |
| Reaching 100 % | Success haptic; liquid "brims over": a 400 ms overshoot of 3 dp with a foam highlight, card gets a check badge |
| Undo | On release, toast "Set to 60 % · Undo" for 4 s |
| Reduced motion | No meniscus wave, no stretch; thumb still moves; overshoot becomes a 150 ms fade |

**Accessibility**: `Semantics(slider: true, label: 'Progress, <work title>', value: '45 percent', increasedValue: '50 percent', decreasedValue: '40 percent')`, `onIncrease` / `onDecrease` move by one step; keyboard arrows on desktop/web. Visible thumb 40 × 28, hit target ≥ 48 × 48.

### 6.7 `GlassButton` (Liquid)

Sizes 44 / 56. Pressed: scale 0.96 + glow at the touch point (interactive glow from the package) + light impact haptic. Variants: primary (lagoon tint), neutral, destructive (coral tint).

### 6.8 `GlassSheet` (Liquid header, Frost body)

Bottom sheet with a 36 radius, glass grabber pill, detents at 55 % and 92 %. Used for the work editor, filters, date picker.

### 6.9 Chips, toggles, text fields

- **Chip** (Frost): height 32, selected = tinted with accent + rim brightening.
- **Toggle**: glass capsule with a liquid thumb that stretches while sliding.
- **Text field**: frost inset with a lagoon focus ring (2 dp, 60 % opacity); label above, never floating-inside.

### 6.10 Toast / Undo

Frost capsule above the tab bar, slides up 220 ms, auto-dismiss 4 s, action button in lagoon.

### 6.11 Charts (Insights)

Bars and lines drawn in view accents on frost panels; grid lines white @ 8 %; selected point shows a glass tooltip (Liquid, since only one at a time).

## 7. Motion

| Preset | Spring (stiffness / damping) | Use |
|---|---|---|
| `snappy` | 500 / 32 | Taps, chips, toggles |
| `smooth` | 300 / 28 | Segment thumb, tab lens, sheets |
| `bouncy` | 220 / 16 | Thumb release, brim overflow |

Durations: 120 / 180 / 280 / 420 ms. Curves for non-spring: `Curves.easeOutCubic` in, `easeInCubic` out.

Rules: motion answers a touch (no decorative entrance animations on every card). The one non-triggered motion is the slow aurora drift. Reduce Motion replaces springs with 150 ms fades and freezes the aurora.

## 8. Haptics

| Event | Haptic |
|---|---|
| Each scrub step | `selectionClick` (rate-limited to 1 per 40 ms) |
| Crossing 25/50/75 detent | `lightImpact` |
| Reaching 100 % | `mediumImpact` then `lightImpact` after 90 ms |
| Segment / tab change | `selectionClick` |
| Undo | `lightImpact` |
| Destructive confirm | `heavyImpact` |

Master toggle in Settings; respects system haptics setting.

## 9. Fallback and adaptation rules

`glassTierProvider` resolves in this order:

1. User setting **Glass intensity**: Full (liquid where budgeted) · Balanced (frost everywhere, liquid only on tab bar + thumb) · Off (solid).
2. Platform **Reduce Transparency / high contrast** → `solid`.
3. **Impeller unavailable** (web, some older devices) → `frost`.
4. **Performance guard**: if p95 frame time > 16 ms for 3 s while a liquid surface is active, drop one tier for the session and show a one-time hint in Settings.

Every screen must look correct and pass contrast in all three tiers.

## 10. Iconography

`phosphor_flutter`, regular weight for inactive, fill weight for active, 24 dp in tab bar, 20 dp inline. Icons on glass use `foam`/`ink`, never tinted below 4.5:1.

## 11. Do / don't

**Do**
- Keep the aurora visible behind every screen.
- Use the view accent (lagoon / saffron / orchid) to make period changes felt.
- Let the scrubber be the most tactile thing in the app.

**Don't**
- Stack glass on glass on glass (sheet over tab bar over card is the maximum).
- Put long paragraphs on liquid glass.
- Use pure black or pure white surfaces.
- Animate cards on entry or add hover-style effects everywhere.
- Rely on colour alone for state (always pair with an icon or text: "Overdue", check badge).

## 12. Design token skeleton (Dart)

```dart
// core/theme/tokens.dart
abstract final class Sp { static const s4=4.0, s8=8.0, s12=12.0, s16=16.0, s20=20.0, s24=24.0, s32=32.0, s48=48.0; }
abstract final class Rad { static const card=28.0, sheet=36.0, chip=22.0; /* capsule = 999 */ }
abstract final class Dur { static const fast=Duration(milliseconds:120), base=Duration(milliseconds:180),
  slow=Duration(milliseconds:280), hero=Duration(milliseconds:420); }

@immutable
class BrimColors extends ThemeExtension<BrimColors> {
  final Color bg, bgDeep, text, textSoft, lagoon, coral, saffron, orchid, kelp, rimLight, rimDark;
  const BrimColors({...});
  static const dark = BrimColors(bg: Color(0xFF0B1622), bgDeep: Color(0xFF10263A), text: Color(0xFFEAF7F6),
    textSoft: Color(0xFF9DB4BF), lagoon: Color(0xFF2EC4B6), coral: Color(0xFFFF6B81),
    saffron: Color(0xFFFFC24B), orchid: Color(0xFF9B8CFF), kelp: Color(0xFF5BD68A), ...);
  // light + lerp() ...
}
```
