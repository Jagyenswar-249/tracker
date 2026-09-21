class ProgressEvent {
  final String id;
  final String workId;
  final String periodStart; // 'YYYY-MM-DD'
  final int fromPercent;
  final int toPercent;
  final DateTime at;

  const ProgressEvent({
    required this.id,
    required this.workId,
    required this.periodStart,
    required this.fromPercent,
    required this.toPercent,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'workId': workId,
        'periodStart': periodStart,
        'fromPercent': fromPercent,
        'toPercent': toPercent,
        'at': at.toIso8601String(),
      };

  factory ProgressEvent.fromJson(Map<String, dynamic> json) => ProgressEvent(
        id: json['id'] as String,
        workId: json['workId'] as String,
        periodStart: json['periodStart'] as String,
        fromPercent: json['fromPercent'] as int,
        toPercent: json['toPercent'] as int,
        at: DateTime.parse(json['at'] as String),
      );
}
