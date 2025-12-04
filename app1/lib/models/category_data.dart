class CategoryData {
  final int? id;
  final int categoryId;
  final DateTime date;
  final double? value;

  CategoryData({
    this.id,
    required this.categoryId,
    required this.date,
    this.value,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'date': date.toIso8601String(),
      'value': value,
    };
  }

  factory CategoryData.fromMap(Map<String, dynamic> map) {
    return CategoryData(
      id: map['id'] as int?,
      categoryId: map['category_id'] as int,
      date: DateTime.parse(map['date'] as String),
      value: map['value'] != null ? (map['value'] as num).toDouble() : null,
    );
  }

  CategoryData copyWith({
    int? id,
    int? categoryId,
    DateTime? date,
    double? value,
  }) {
    return CategoryData(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }
}
