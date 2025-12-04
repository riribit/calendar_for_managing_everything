class Category {
  final int? id;
  final int calendarId;
  final String name;
  final String color;
  final int orderIndex;

  Category({
    this.id,
    required this.calendarId,
    required this.name,
    this.color = '#6366F1',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calendar_id': calendarId,
      'name': name,
      'color': color,
      'order_index': orderIndex,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      calendarId: map['calendar_id'] as int,
      name: map['name'] as String,
      color: map['color'] as String? ?? '#6366F1',
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  Category copyWith({
    int? id,
    int? calendarId,
    String? name,
    String? color,
    int? orderIndex,
  }) {
    return Category(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      name: name ?? this.name,
      color: color ?? this.color,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
