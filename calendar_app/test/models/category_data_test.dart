import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/models/category_data.dart';

void main() {
  group('CategoryData', () {
    final testDate = DateTime(2024, 12, 3);

    test('should create CategoryData with required fields', () {
      final data = CategoryData(categoryId: 1, date: testDate);

      expect(data.categoryId, 1);
      expect(data.date, testDate);
      expect(data.value, isNull);
      expect(data.id, isNull);
    });

    test('should create CategoryData with all fields', () {
      final data = CategoryData(
        id: 10,
        categoryId: 1,
        date: testDate,
        value: 42.5,
      );

      expect(data.id, 10);
      expect(data.categoryId, 1);
      expect(data.date, testDate);
      expect(data.value, 42.5);
    });

    test('should convert to Map correctly', () {
      final data = CategoryData(
        id: 5,
        categoryId: 2,
        date: testDate,
        value: 100.0,
      );

      final map = data.toMap();

      expect(map['id'], 5);
      expect(map['category_id'], 2);
      expect(map['date'], testDate.toIso8601String());
      expect(map['value'], 100.0);
    });

    test('should create from Map correctly', () {
      final map = {
        'id': 3,
        'category_id': 1,
        'date': testDate.toIso8601String(),
        'value': 75.5,
      };

      final data = CategoryData.fromMap(map);

      expect(data.id, 3);
      expect(data.categoryId, 1);
      expect(data.date.year, testDate.year);
      expect(data.date.month, testDate.month);
      expect(data.date.day, testDate.day);
      expect(data.value, 75.5);
    });

    test('should handle null value in Map', () {
      final map = {
        'id': 3,
        'category_id': 1,
        'date': testDate.toIso8601String(),
        'value': null,
      };

      final data = CategoryData.fromMap(map);

      expect(data.value, isNull);
    });

    test('should copyWith correctly', () {
      final data = CategoryData(
        id: 1,
        categoryId: 1,
        date: testDate,
        value: 50.0,
      );

      final copied = data.copyWith(value: 100.0);

      expect(copied.id, 1);
      expect(copied.categoryId, 1);
      expect(copied.date, testDate);
      expect(copied.value, 100.0);
    });

    test('should copyWith new date correctly', () {
      final data = CategoryData(
        id: 1,
        categoryId: 1,
        date: testDate,
        value: 50.0,
      );

      final newDate = DateTime(2024, 12, 25);
      final copied = data.copyWith(date: newDate);

      expect(copied.date, newDate);
    });
  });
}
