import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  Future<bool> requestPermissions() async {
    debugPrint('Notification permission requested');
    return true;
  }

  Future<void> scheduleWorkReminder({
    required String workId,
    required String title,
    required int minutesOfDay,
    required int weekdayMask,
  }) async {
    debugPrint('Scheduled reminder for $title at $minutesOfDay min');
  }

  Future<void> cancelWorkReminder(String workId) async {
    debugPrint('Cancelled reminder for $workId');
  }
}
