class LedgerModel {
  final String id;
  final String name;
  final String type;
  final bool isDefault;
  final DateTime createdAt;

  const LedgerModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
    required this.createdAt,
  });

  LedgerModel copyWith({
    String? id,
    String? name,
    String? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return LedgerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}