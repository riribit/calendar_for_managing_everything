import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/models/daily_note.dart';

void main() {
  group('DailyNote', () {
    final testDate = DateTime(2024, 12, 3);

    test('should create DailyNote with required fields', () {
      final note = DailyNote(calendarId: 1, date: testDate);

      expect(note.calendarId, 1);
      expect(note.date, testDate);
      expect(note.memo, '');
      expect(note.photos, isEmpty);
      expect(note.id, isNull);
    });

    test('should create DailyNote with all fields', () {
      final note = DailyNote(
        id: 10,
        calendarId: 1,
        date: testDate,
        memo: 'テストメモ',
        photos: ['/path/to/photo1.jpg', '/path/to/photo2.jpg'],
      );

      expect(note.id, 10);
      expect(note.calendarId, 1);
      expect(note.date, testDate);
      expect(note.memo, 'テストメモ');
      expect(note.photos.length, 2);
      expect(note.photos[0], '/path/to/photo1.jpg');
    });

    test('should convert to Map correctly', () {
      final note = DailyNote(
        id: 5,
        calendarId: 2,
        date: testDate,
        memo: 'メモ内容',
        photos: ['/photo1.jpg', '/photo2.jpg'],
      );

      final map = note.toMap();

      expect(map['id'], 5);
      expect(map['calendar_id'], 2);
      expect(map['date'], testDate.toIso8601String());
      expect(map['memo'], 'メモ内容');
      expect(map['photos'], '/photo1.jpg|||/photo2.jpg');
    });

    test('should create from Map correctly', () {
      final map = {
        'id': 3,
        'calendar_id': 1,
        'date': testDate.toIso8601String(),
        'memo': 'マップからのメモ',
        'photos': '/path1.jpg|||/path2.jpg|||/path3.jpg',
      };

      final note = DailyNote.fromMap(map);

      expect(note.id, 3);
      expect(note.calendarId, 1);
      expect(note.memo, 'マップからのメモ');
      expect(note.photos.length, 3);
      expect(note.photos[2], '/path3.jpg');
    });

    test('should handle empty photos in Map', () {
      final map = {
        'id': 3,
        'calendar_id': 1,
        'date': testDate.toIso8601String(),
        'memo': 'メモ',
        'photos': '',
      };

      final note = DailyNote.fromMap(map);

      expect(note.photos, isEmpty);
    });

    test('should handle null photos in Map', () {
      final map = {
        'id': 3,
        'calendar_id': 1,
        'date': testDate.toIso8601String(),
        'memo': 'メモ',
        'photos': null,
      };

      final note = DailyNote.fromMap(map);

      expect(note.photos, isEmpty);
    });

    test('should copyWith correctly', () {
      final note = DailyNote(
        id: 1,
        calendarId: 1,
        date: testDate,
        memo: '元のメモ',
        photos: ['/photo1.jpg'],
      );

      final copied = note.copyWith(
        memo: '新しいメモ',
        photos: ['/photo1.jpg', '/photo2.jpg'],
      );

      expect(copied.id, 1);
      expect(copied.calendarId, 1);
      expect(copied.date, testDate);
      expect(copied.memo, '新しいメモ');
      expect(copied.photos.length, 2);
    });
  });
}
