class ProgressEntry {
  final String id;
  final String workId;
  final String periodStart; // 'YYYY-MM-DD'
  final int percent; // 0..100
  final DateTime updatedAt;

  const ProgressEntry({
    required this.id,
    required this.workId,
    required this.periodStart,
    required this.percent,
    required this.updatedAt,
  });

  ProgressEntry copyWith({
    String? id,
    String? workId,
    String? periodStart,
    int? percent,
    DateTime? updatedAt,
  }) {
    return ProgressEntry(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      periodStart: periodStart ?? this.periodStart,
      percent: percent ?? this.percent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workId': workId,
        'periodStart': periodStart,
        'percent': percent,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ProgressEntry.fromJson(Map<String, dynamic> json) => ProgressEntry(
        id: json['id'] as String,
        workId: json['workId'] as String,
        periodStart: json['periodStart'] as String,
        percent: json['percent'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
