import 'package:flutter_test/flutter_test.dart';
import 'package:app1/utils/japanese_holidays.dart';

void main() {
  group('JapaneseHolidays', () {
    group('Fixed holidays', () {
      test('should recognize New Year Day (1/1)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 1, 1)), isTrue);
        expect(JapaneseHolidays.isHoliday(DateTime(2025, 1, 1)), isTrue);
      });

      test('should recognize Coming of Age Day (2nd Monday of January)', () {
        // 2024年の成人の日は1月8日（第2月曜日）
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 1, 8)), isTrue);
        // 2025年の成人の日は1月13日（第2月曜日）
        expect(JapaneseHolidays.isHoliday(DateTime(2025, 1, 13)), isTrue);
      });

      test('should recognize National Foundation Day (2/11)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 2, 11)), isTrue);
        expect(JapaneseHolidays.isHoliday(DateTime(2025, 2, 11)), isTrue);
      });

      test('should recognize Showa Day (4/29)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 4, 29)), isTrue);
      });

      test('should recognize Constitution Memorial Day (5/3)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 5, 3)), isTrue);
      });

      test('should recognize Greenery Day (5/4)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 5, 4)), isTrue);
      });

      test('should recognize Children\'s Day (5/5)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 5, 5)), isTrue);
      });

      test('should recognize Marine Day (3rd Monday of July)', () {
        // 2024年の海の日は7月15日（第3月曜日）
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 7, 15)), isTrue);
      });

      test('should recognize Mountain Day (8/11)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 8, 11)), isTrue);
      });

      test(
        'should recognize Respect for the Aged Day (3rd Monday of September)',
        () {
          // 2024年の敬老の日は9月16日（第3月曜日）
          expect(JapaneseHolidays.isHoliday(DateTime(2024, 9, 16)), isTrue);
        },
      );

      test('should recognize Sports Day (2nd Monday of October)', () {
        // 2024年のスポーツの日は10月14日（第2月曜日）
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 10, 14)), isTrue);
      });

      test('should recognize Culture Day (11/3)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 11, 3)), isTrue);
      });

      test('should recognize Labor Thanksgiving Day (11/23)', () {
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 11, 23)), isTrue);
      });
    });

    group('Non-holidays', () {
      test('should not recognize regular weekday as holiday', () {
        // 2024年12月2日は月曜日（祝日ではない）
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 12, 2)), isFalse);
      });

      test('should not recognize Saturday as holiday', () {
        // 2024年12月7日は土曜日
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 12, 7)), isFalse);
      });

      test('should not recognize Sunday as holiday (Sunday is separate)', () {
        // 日曜日は祝日ではなく、別途表示される
        expect(JapaneseHolidays.isHoliday(DateTime(2024, 12, 1)), isFalse);
      });
    });

    group('Vernal and Autumnal Equinox', () {
      test('should recognize Vernal Equinox Day (around 3/20-21)', () {
        // 春分の日は年によって変動（通常3/20か3/21）
        final date2024 = DateTime(2024, 3, 20);
        final date2025 = DateTime(2025, 3, 20);
        // 少なくとも近辺の日付で祝日になるはず
        expect(
          JapaneseHolidays.isHoliday(date2024) ||
              JapaneseHolidays.isHoliday(DateTime(2024, 3, 21)),
          isTrue,
        );
      });

      test('should recognize Autumnal Equinox Day (around 9/22-23)', () {
        // 秋分の日は年によって変動（通常9/22か9/23）
        final date2024 = DateTime(2024, 9, 22);
        expect(
          JapaneseHolidays.isHoliday(date2024) ||
              JapaneseHolidays.isHoliday(DateTime(2024, 9, 23)),
          isTrue,
        );
      });
    });
  });
}
