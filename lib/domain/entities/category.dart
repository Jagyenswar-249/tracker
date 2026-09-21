class Category {
  final String id;
  final String name;
  final int colorArgb;
  final String iconKey;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Category({
    required this.id,
    required this.name,
    required this.colorArgb,
    this.iconKey = 'folder',
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorArgb': colorArgb,
        'iconKey': iconKey,
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        colorArgb: json['colorArgb'] as int,
        iconKey: json['iconKey'] as String? ?? 'folder',
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );
}
