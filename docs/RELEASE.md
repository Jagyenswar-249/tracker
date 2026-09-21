# Release & QA Verification Guide: Brim

## Build & Test Instructions

### Prerequisites
- Flutter SDK (stable channel, 3.19.0+)
- Android Studio / Android SDK (API 34+)
- Dart SDK (3.3.0+)

### Commands

```bash
# 1. Install dependencies
flutter pub get

# 2. Check code formatting
dart format --set-exit-if-changed .

# 3. Static Analysis
flutter analyze --fatal-infos

# 4. Execute Unit and Widget Test Suite
flutter test --coverage

# 5. Build Android Release APK / Bundle
flutter build apk --release
flutter build appbundle --release
```

---

## QA Checklist Sign-Off

### 1. Functional Verification
- [x] **Works CRUD**: Create, edit, archive, and delete works across Daily, Weekly, Monthly, and One-off cadences.
- [x] **Cadence Logic**: Daily works respect weekday mask; One-off works appear in their due period and show an overdue badge if uncompleted past due date.
- [x] **Rollup Math**: Weighted period rollup accurately calculated: $\Sigma(\text{effort} \times \text{percent}) / \Sigma(\text{effort})$.
- [x] **Date Math Integrity**: All period logic strictly uses local `'YYYY-MM-DD'` date-only strings and `DateTime(y, m, d)` constructors.
- [x] **Persistence & Reset**: Recurring works start fresh at 0% for new periods while preserving complete historical records.
- [x] **Undo System**: 4-second auto-dismiss undo toast allows reverting accidental progress changes.
- [x] **Streak Calculation**: Configurable threshold (default 80%) correctly computes consecutive successful days.

### 2. Gesture & Interaction Verification
- [x] **Scrubber Gesture Arena**: Horizontal drag recognizer with 8 dp slop takes precedence over vertical list scrolling.
- [x] **Snapping & Magnetic Detents**: Snaps to configured step (1%, 5%, 10%) with magnetic pull at 0%, 25%, 50%, 75%, and 100%.
- [x] **Precision Scrubbing**: Moving finger vertically away from bar scales speed ($1.0\times \le 40\text{ dp}$, $0.5\times \le 100\text{ dp}$, $0.25\times > 100\text{ dp}$) with accumulated delta so thumb never jumps.
- [x] **Brim Overflow**: 100% completion triggers spring overflow crest and success haptics.
- [x] **Accessibility**: Full `Semantics(slider: true)` support with `onIncrease` / `onDecrease` step adjustments.

### 3. Visual & Glass Material Verification
- [x] **Three Glass Tiers**: `liquid`, `frost`, and `solid` materials render with consistent specular rim lights.
- [x] **Aurora Field**: Hardware-accelerated 4-blob radial gradient background with view accent dynamic boost.
- [x] **Theme & Contrast**: Light and Dark palettes pass WCAG 4.5:1 contrast standards.
- [x] **Layout Scalability**: Responsive up to 200% font scale and 360 dp to 430 dp mobile widths.
