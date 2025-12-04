class DailyNote {
  final int? id;
  final int calendarId;
  final DateTime date;
  final String memo;
  final List<String> photos; // 写真のパスリスト

  DailyNote({
    this.id,
    required this.calendarId,
    required this.date,
    this.memo = '',
    this.photos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'calendar_id': calendarId,
      'date': date.toIso8601String(),
      'memo': memo,
      'photos': photos.join('|||'), // 区切り文字でリストを保存
    };
  }

  factory DailyNote.fromMap(Map<String, dynamic> map) {
    final photosStr = map['photos'] as String? ?? '';
    return DailyNote(
      id: map['id'] as int?,
      calendarId: map['calendar_id'] as int,
      date: DateTime.parse(map['date'] as String),
      memo: map['memo'] as String? ?? '',
      photos: photosStr.isEmpty ? [] : photosStr.split('|||'),
    );
  }

  DailyNote copyWith({
    int? id,
    int? calendarId,
    DateTime? date,
    String? memo,
    List<String>? photos,
  }) {
    return DailyNote(
      id: id ?? this.id,
      calendarId: calendarId ?? this.calendarId,
      date: date ?? this.date,
      memo: memo ?? this.memo,
      photos: photos ?? this.photos,
    );
  }
}
