class CalendarModel {
  final int? id;
  final String name;
  final String color;

  CalendarModel({this.id, required this.name, this.color = '#6366F1'});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'color': color};
  }

  factory CalendarModel.fromMap(Map<String, dynamic> map) {
    return CalendarModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as String? ?? '#6366F1',
    );
  }

  CalendarModel copyWith({int? id, String? name, String? color}) {
    return CalendarModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
