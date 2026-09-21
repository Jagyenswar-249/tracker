import '../entities/cadence.dart';

enum ThemeModeSetting { system, light, dark }
enum GlassIntensitySetting { full, balanced, off }

class AppSettings {
  final ThemeModeSetting themeMode;
  final GlassIntensitySetting glassIntensity;
  final int weekStart; // 1 = Mon, 7 = Sun, 6 = Sat
  final int snapStep; // 1, 5, 10
  final double streakThreshold; // e.g. 80.0
  final bool hapticsEnabled;
  final Cadence selectedView;
  final bool hasCompletedOnboarding;

  const AppSettings({
    this.themeMode = ThemeModeSetting.dark,
    this.glassIntensity = GlassIntensitySetting.full,
    this.weekStart = 1,
    this.snapStep = 5,
    this.streakThreshold = 80.0,
    this.hapticsEnabled = true,
    this.selectedView = Cadence.daily,
    this.hasCompletedOnboarding = false,
  });

  AppSettings copyWith({
    ThemeModeSetting? themeMode,
    GlassIntensitySetting? glassIntensity,
    int? weekStart,
    int? snapStep,
    double? streakThreshold,
    bool? hapticsEnabled,
    Cadence? selectedView,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      glassIntensity: glassIntensity ?? this.glassIntensity,
      weekStart: weekStart ?? this.weekStart,
      snapStep: snapStep ?? this.snapStep,
      streakThreshold: streakThreshold ?? this.streakThreshold,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      selectedView: selectedView ?? this.selectedView,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Stream<AppSettings> watchSettings();
  Future<void> updateSettings(AppSettings settings);
}
