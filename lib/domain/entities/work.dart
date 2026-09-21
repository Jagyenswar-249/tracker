import 'cadence.dart';

class Work {
  final String id;
  final String title;
  final String notes;
  final String? categoryId;
  final int colorArgb;
  final Cadence cadence;
  final int weekdayMask; // bit0=Mon ... bit6=Sun; daily only (default 127 = all days)
  final String startDate; // 'YYYY-MM-DD'
  final String? dueDate; // 'YYYY-MM-DD' for once
  final int effort; // 1..3
  final int sortOrder;
  final DateTime? archivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Work({
    required this.id,
    required this.title,
    this.notes = '',
    this.categoryId,
    required this.colorArgb,
    required this.cadence,
    this.weekdayMask = 127,
    required this.startDate,
    this.dueDate,
    this.effort = 1,
    this.sortOrder = 0,
    this.archivedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  bool isWeekdayActive(int weekday) {
    // weekday in Dart is 1 (Mon) .. 7 (Sun)
    final bit = 1 << (weekday - 1);
    return (weekdayMask & bit) != 0;
  }

  bool get isArchived => archivedAt != null;
  bool get isDeleted => deletedAt != null;

  Work copyWith({
    String? id,
    String? title,
    String? notes,
    String? categoryId,
    int? colorArgb,
    Cadence? cadence,
    int? weekdayMask,
    String? startDate,
    String? dueDate,
    int? effort,
    int? sortOrder,
    DateTime? archivedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Work(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      colorArgb: colorArgb ?? this.colorArgb,
      cadence: cadence ?? this.cadence,
      weekdayMask: weekdayMask ?? this.weekdayMask,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      effort: effort ?? this.effort,
      sortOrder: sortOrder ?? this.sortOrder,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'categoryId': categoryId,
        'colorArgb': colorArgb,
        'cadence': cadence.name,
        'weekdayMask': weekdayMask,
        'startDate': startDate,
        'dueDate': dueDate,
        'effort': effort,
        'sortOrder': sortOrder,
        'archivedAt': archivedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Work.fromJson(Map<String, dynamic> json) => Work(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String? ?? '',
        categoryId: json['categoryId'] as String?,
        colorArgb: json['colorArgb'] as int,
        cadence: Cadence.values.byName(json['cadence'] as String),
        weekdayMask: json['weekdayMask'] as int? ?? 127,
        startDate: json['startDate'] as String,
        dueDate: json['dueDate'] as String?,
        effort: json['effort'] as int? ?? 1,
        sortOrder: json['sortOrder'] as int? ?? 0,
        archivedAt: json['archivedAt'] != null
            ? DateTime.parse(json['archivedAt'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );
}
