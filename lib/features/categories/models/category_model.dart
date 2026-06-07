class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int color;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.createdAt,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}