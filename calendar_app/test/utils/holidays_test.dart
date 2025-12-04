import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/utils/holidays.dart';

void main() {
  group('Holidays', () {
    group('Japanese holidays (ja)', () {
      const locale = Locale('ja', 'JP');

      test('should recognize New Year Day (1/1)', () {
        expect(Holidays.isHoliday(DateTime(2024, 1, 1), locale), isTrue);
        expect(Holidays.isHoliday(DateTime(2025, 1, 1), locale), isTrue);
      });

      test('should recognize Coming of Age Day (2nd Monday of January)', () {
        expect(Holidays.isHoliday(DateTime(2024, 1, 8), locale), isTrue);
        expect(Holidays.isHoliday(DateTime(2025, 1, 13), locale), isTrue);
      });

      test('should recognize Constitution Memorial Day (5/3)', () {
        expect(Holidays.isHoliday(DateTime(2024, 5, 3), locale), isTrue);
      });

      test('should not recognize regular weekday as holiday', () {
        expect(Holidays.isHoliday(DateTime(2024, 12, 2), locale), isFalse);
      });
    });

    group('US holidays (en-US)', () {
      const locale = Locale('en', 'US');

      test('should recognize New Year Day (1/1)', () {
        expect(Holidays.isHoliday(DateTime(2024, 1, 1), locale), isTrue);
      });

      test('should recognize Independence Day (7/4)', () {
        expect(Holidays.isHoliday(DateTime(2024, 7, 4), locale), isTrue);
        expect(Holidays.isHoliday(DateTime(2025, 7, 4), locale), isTrue);
      });

      test('should recognize Thanksgiving (4th Thursday of November)', () {
        // 2024年のThanksgivingは11月28日
        expect(Holidays.isHoliday(DateTime(2024, 11, 28), locale), isTrue);
      });

      test('should recognize Christmas (12/25)', () {
        expect(Holidays.isHoliday(DateTime(2024, 12, 25), locale), isTrue);
      });

      test(
        'should recognize Martin Luther King Jr. Day (3rd Monday of January)',
        () {
          // 2024年は1月15日
          expect(Holidays.isHoliday(DateTime(2024, 1, 15), locale), isTrue);
        },
      );

      test('should not recognize Japanese holiday', () {
        // 日本の建国記念日（2/11）はアメリカの祝日ではない
        expect(Holidays.isHoliday(DateTime(2024, 2, 11), locale), isFalse);
      });
    });

    group('UK holidays (en-GB)', () {
      const locale = Locale('en', 'GB');

      test('should recognize New Year Day (1/1)', () {
        expect(Holidays.isHoliday(DateTime(2024, 1, 1), locale), isTrue);
      });

      test('should recognize Christmas (12/25)', () {
        expect(Holidays.isHoliday(DateTime(2024, 12, 25), locale), isTrue);
      });

      test('should recognize Boxing Day (12/26)', () {
        expect(Holidays.isHoliday(DateTime(2024, 12, 26), locale), isTrue);
      });
    });

    group('Chinese holidays (zh)', () {
      const locale = Locale('zh', 'CN');

      test('should recognize New Year Day (1/1)', () {
        expect(Holidays.isHoliday(DateTime(2024, 1, 1), locale), isTrue);
      });

      test('should recognize National Day (10/1)', () {
        expect(Holidays.isHoliday(DateTime(2024, 10, 1), locale), isTrue);
      });

      test('should recognize Labor Day (5/1)', () {
        expect(Holidays.isHoliday(DateTime(2024, 5, 1), locale), isTrue);
      });

      test('should recognize Chinese New Year (approximately)', () {
        // 2024年の春節は2月10日
        expect(Holidays.isHoliday(DateTime(2024, 2, 10), locale), isTrue);
      });
    });

    group('Default to US for unknown locale', () {
      const locale = Locale('fr', 'FR');

      test('should recognize US Independence Day for unknown locale', () {
        expect(Holidays.isHoliday(DateTime(2024, 7, 4), locale), isTrue);
      });
    });
  });
}
