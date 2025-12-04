import 'package:flutter_test/flutter_test.dart';
import 'package:app1/models/calendar_model.dart';

void main() {
  group('CalendarModel', () {
    test('should create CalendarModel with required fields', () {
      final calendar = CalendarModel(name: 'テストカレンダー');

      expect(calendar.name, 'テストカレンダー');
      expect(calendar.color, '#6366F1'); // デフォルト色
      expect(calendar.id, isNull);
    });

    test('should create CalendarModel with all fields', () {
      final calendar = CalendarModel(id: 1, name: 'カレンダー1', color: '#EC4899');

      expect(calendar.id, 1);
      expect(calendar.name, 'カレンダー1');
      expect(calendar.color, '#EC4899');
    });

    test('should convert to Map correctly', () {
      final calendar = CalendarModel(id: 1, name: 'テスト', color: '#10B981');

      final map = calendar.toMap();

      expect(map['id'], 1);
      expect(map['name'], 'テスト');
      expect(map['color'], '#10B981');
    });

    test('should create from Map correctly', () {
      final map = {'id': 2, 'name': 'マップから作成', 'color': '#F59E0B'};

      final calendar = CalendarModel.fromMap(map);

      expect(calendar.id, 2);
      expect(calendar.name, 'マップから作成');
      expect(calendar.color, '#F59E0B');
    });

    test('should copyWith correctly', () {
      final calendar = CalendarModel(id: 1, name: '元の名前', color: '#6366F1');

      final copied = calendar.copyWith(name: '新しい名前');

      expect(copied.id, 1);
      expect(copied.name, '新しい名前');
      expect(copied.color, '#6366F1');
    });

    test('should compare equality by id', () {
      final calendar1 = CalendarModel(id: 1, name: 'カレンダー1');
      final calendar2 = CalendarModel(id: 1, name: '別の名前');
      final calendar3 = CalendarModel(id: 2, name: 'カレンダー1');

      expect(calendar1 == calendar2, isTrue);
      expect(calendar1 == calendar3, isFalse);
    });

    test('should have consistent hashCode', () {
      final calendar1 = CalendarModel(id: 1, name: 'カレンダー1');
      final calendar2 = CalendarModel(id: 1, name: '別の名前');

      expect(calendar1.hashCode, calendar2.hashCode);
    });
  });
}
