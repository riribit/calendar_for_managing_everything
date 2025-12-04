import 'package:flutter_test/flutter_test.dart';
import 'package:app1/models/category.dart';

void main() {
  group('Category', () {
    test('should create Category with required fields', () {
      final category = Category(
        calendarId: 1,
        name: 'テストカテゴリ',
        color: '#6366F1',
        orderIndex: 0,
      );

      expect(category.calendarId, 1);
      expect(category.name, 'テストカテゴリ');
      expect(category.color, '#6366F1');
      expect(category.orderIndex, 0);
      expect(category.id, isNull);
    });

    test('should create Category with all fields', () {
      final category = Category(
        id: 10,
        calendarId: 1,
        name: 'カテゴリ1',
        color: '#EC4899',
        orderIndex: 2,
      );

      expect(category.id, 10);
      expect(category.calendarId, 1);
      expect(category.name, 'カテゴリ1');
      expect(category.color, '#EC4899');
      expect(category.orderIndex, 2);
    });

    test('should convert to Map correctly', () {
      final category = Category(
        id: 5,
        calendarId: 2,
        name: 'テスト',
        color: '#10B981',
        orderIndex: 1,
      );

      final map = category.toMap();

      expect(map['id'], 5);
      expect(map['calendar_id'], 2);
      expect(map['name'], 'テスト');
      expect(map['color'], '#10B981');
      expect(map['order_index'], 1);
    });

    test('should create from Map correctly', () {
      final map = {
        'id': 3,
        'calendar_id': 1,
        'name': 'マップから作成',
        'color': '#F59E0B',
        'order_index': 0,
      };

      final category = Category.fromMap(map);

      expect(category.id, 3);
      expect(category.calendarId, 1);
      expect(category.name, 'マップから作成');
      expect(category.color, '#F59E0B');
      expect(category.orderIndex, 0);
    });

    test('should copyWith correctly', () {
      final category = Category(
        id: 1,
        calendarId: 1,
        name: '元の名前',
        color: '#6366F1',
        orderIndex: 0,
      );

      final copied = category.copyWith(name: '新しい名前', color: '#EC4899');

      expect(copied.id, 1);
      expect(copied.calendarId, 1);
      expect(copied.name, '新しい名前');
      expect(copied.color, '#EC4899');
      expect(copied.orderIndex, 0);
    });
  });
}
