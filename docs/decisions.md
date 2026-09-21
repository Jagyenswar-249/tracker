# Architectural Decisions Log

## ADR 01: Three-Tier Glass Surface Rendering Architecture
- **Date**: 2026-09-21
- **Status**: Accepted
- **Context**: `liquid_glass_renderer` is experimental and requires Impeller shader support on iOS / newer Android devices. On web or low-end Android hardware, complex shaders may degrade frame rate below 60 fps.
- **Decision**: Wrap all glass surfaces with `GlassSurface`. Expose three tiers:
  1. `liquid`: Shader refraction + rim light + specular highlight + dynamic stretch.
  2. `frost`: BackdropFilter (blur $\sigma = 14$) + semi-transparent tint + rim stroke.
  3. `solid`: Opaque surface with identical rim stroke and tint (fallback for Reduce Transparency / low-end devices).
- **Consequences**: Zero rendering failures across any platform or device capability.

## ADR 02: Date-Only Period Keying
- **Date**: 2026-09-21
- **Status**: Accepted
- **Context**: Timestamps with timezones cause DST boundary shifts and off-by-one errors when grouping works by day, week, or month.
- **Decision**: All period keys and work dates are stored as `'YYYY-MM-DD'` date-only strings. Period math uses `DateTime(year, month, day)` constructors and never adds raw `Duration` intervals across midnight.
- **Consequences**: Reliable, 100% deterministic streak, rollup, and calendar calculations.

## ADR 03: Gesture Arena & Scrubber Precision
- **Date**: 2026-09-21
- **Status**: Accepted
- **Context**: Horizontal dragging on a work card inside a scrollable list can collide with vertical scroll gestures or Android back swipes.
- **Decision**: `ProgressScrubber` uses a custom `HorizontalDragGestureRecognizer` with 8 dp slop. Vertical distance from the bar scales scrub speed ($\le 40\text{ dp} = 1.0\times$, $40\text{--}100\text{ dp} = 0.5\times$, $>100\text{ dp} = 0.25\times$). Delta is accumulated incrementally so the thumb never jumps.
- **Consequences**: Silky smooth 60 fps dragging with precision fine-tuning.
