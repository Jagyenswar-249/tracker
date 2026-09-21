import 'dart:async';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  AppSettings _settings;
  final _controller = StreamController<AppSettings>.broadcast();

  SettingsRepositoryImpl({AppSettings? initialSettings})
      : _settings = initialSettings ?? const AppSettings();

  @override
  Future<AppSettings> getSettings() async => _settings;

  @override
  Stream<AppSettings> watchSettings() => _controller.stream;

  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    _controller.add(_settings);
  }
}
