import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Leap Year', () {
    test('2024 is a leap year (Feb has 29 days)', () {
      final feb29_2024 = DateTime(2024, 2, 29);
      expect(feb29_2024.month, 2);
      expect(feb29_2024.day, 29);
    });

    test('2025 is not a leap year (Feb has 28 days)', () {
      // DateTime(2025, 2, 29) will be adjusted to March 1
      final feb29_2025 = DateTime(2025, 2, 29);
      expect(feb29_2025.month, 3); // Auto-adjusted to March
      expect(feb29_2025.day, 1);
    });

    test('2028 is a leap year (Feb has 29 days)', () {
      final feb29_2028 = DateTime(2028, 2, 29);
      expect(feb29_2028.month, 2);
      expect(feb29_2028.day, 29);
    });

    test('Last day of February in leap year', () {
      // 2024年2月の最終日を取得
      final lastDayFeb2024 = DateTime(2024, 3, 0); // 翌月の0日 = 前月の最終日
      expect(lastDayFeb2024.day, 29);
    });

    test('Last day of February in non-leap year', () {
      // 2025年2月の最終日を取得
      final lastDayFeb2025 = DateTime(2025, 3, 0);
      expect(lastDayFeb2025.day, 28);
    });
  });
}
