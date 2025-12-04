import 'package:flutter/material.dart';

/// 国/地域に応じた祝日を管理するユーティリティクラス
class Holidays {
  /// ロケールに基づいて祝日かどうかを判定
  static bool isHoliday(DateTime date, Locale locale) {
    final holidays = getHolidays(date.year, locale);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return holidays.any(
      (h) =>
          h.year == normalizedDate.year &&
          h.month == normalizedDate.month &&
          h.day == normalizedDate.day,
    );
  }

  /// ロケールに基づいて指定された年の祝日リストを取得
  static List<DateTime> getHolidays(int year, Locale locale) {
    switch (locale.languageCode) {
      case 'ja':
        return _getJapaneseHolidays(year);
      case 'zh':
        return _getChineseHolidays(year);
      case 'en':
      default:
        // 英語の場合は国コードを確認
        if (locale.countryCode == 'GB' || locale.countryCode == 'UK') {
          return _getUKHolidays(year);
        }
        return _getUSHolidays(year);
    }
  }

  /// n番目の特定曜日を取得
  static DateTime _getNthWeekday(int year, int month, int weekday, int n) {
    var date = DateTime(year, month, 1);
    var count = 0;

    while (count < n) {
      if (date.weekday == weekday) {
        count++;
        if (count == n) break;
      }
      date = date.add(const Duration(days: 1));
    }

    return date;
  }

  /// 最後の特定曜日を取得
  static DateTime _getLastWeekday(int year, int month, int weekday) {
    var date = DateTime(year, month + 1, 0); // 月末
    while (date.weekday != weekday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }

  // ============ 日本の祝日 ============
  static List<DateTime> _getJapaneseHolidays(int year) {
    final holidays = <DateTime>[];

    // 元日
    holidays.add(DateTime(year, 1, 1));
    // 成人の日（1月第2月曜日）
    holidays.add(_getNthWeekday(year, 1, DateTime.monday, 2));
    // 建国記念の日
    holidays.add(DateTime(year, 2, 11));
    // 天皇誕生日
    holidays.add(DateTime(year, 2, 23));
    // 春分の日
    holidays.add(_getJapaneseVernalEquinox(year));
    // 昭和の日
    holidays.add(DateTime(year, 4, 29));
    // 憲法記念日
    holidays.add(DateTime(year, 5, 3));
    // みどりの日
    holidays.add(DateTime(year, 5, 4));
    // こどもの日
    holidays.add(DateTime(year, 5, 5));
    // 海の日（7月第3月曜日）
    holidays.add(_getNthWeekday(year, 7, DateTime.monday, 3));
    // 山の日
    holidays.add(DateTime(year, 8, 11));
    // 敬老の日（9月第3月曜日）
    holidays.add(_getNthWeekday(year, 9, DateTime.monday, 3));
    // 秋分の日
    holidays.add(_getJapaneseAutumnalEquinox(year));
    // スポーツの日（10月第2月曜日）
    holidays.add(_getNthWeekday(year, 10, DateTime.monday, 2));
    // 文化の日
    holidays.add(DateTime(year, 11, 3));
    // 勤労感謝の日
    holidays.add(DateTime(year, 11, 23));

    // 振替休日を追加
    _addJapaneseSubstituteHolidays(holidays, year);

    return holidays;
  }

  static DateTime _getJapaneseVernalEquinox(int year) {
    final day = (20.8431 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
        .floor();
    return DateTime(year, 3, day);
  }

  static DateTime _getJapaneseAutumnalEquinox(int year) {
    final day = (23.2488 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
        .floor();
    return DateTime(year, 9, day);
  }

  static void _addJapaneseSubstituteHolidays(
    List<DateTime> holidays,
    int year,
  ) {
    final substituteHolidays = <DateTime>[];

    for (final holiday in holidays) {
      if (holiday.weekday == DateTime.sunday) {
        var substitute = holiday.add(const Duration(days: 1));
        while (holidays.contains(substitute) ||
            substituteHolidays.contains(substitute)) {
          substitute = substitute.add(const Duration(days: 1));
        }
        substituteHolidays.add(substitute);
      }
    }

    holidays.addAll(substituteHolidays);
  }

  // ============ アメリカの祝日 ============
  static List<DateTime> _getUSHolidays(int year) {
    final holidays = <DateTime>[];

    // New Year's Day
    holidays.add(DateTime(year, 1, 1));
    // Martin Luther King Jr. Day（1月第3月曜日）
    holidays.add(_getNthWeekday(year, 1, DateTime.monday, 3));
    // Presidents' Day（2月第3月曜日）
    holidays.add(_getNthWeekday(year, 2, DateTime.monday, 3));
    // Memorial Day（5月最終月曜日）
    holidays.add(_getLastWeekday(year, 5, DateTime.monday));
    // Juneteenth
    holidays.add(DateTime(year, 6, 19));
    // Independence Day
    holidays.add(DateTime(year, 7, 4));
    // Labor Day（9月第1月曜日）
    holidays.add(_getNthWeekday(year, 9, DateTime.monday, 1));
    // Columbus Day（10月第2月曜日）
    holidays.add(_getNthWeekday(year, 10, DateTime.monday, 2));
    // Veterans Day
    holidays.add(DateTime(year, 11, 11));
    // Thanksgiving Day（11月第4木曜日）
    holidays.add(_getNthWeekday(year, 11, DateTime.thursday, 4));
    // Christmas Day
    holidays.add(DateTime(year, 12, 25));

    // 連邦の休日が週末に当たる場合の振替
    _addUSObservedHolidays(holidays, year);

    return holidays;
  }

  static void _addUSObservedHolidays(List<DateTime> holidays, int year) {
    final observedHolidays = <DateTime>[];
    final fixedHolidays = [
      DateTime(year, 1, 1),
      DateTime(year, 6, 19),
      DateTime(year, 7, 4),
      DateTime(year, 11, 11),
      DateTime(year, 12, 25),
    ];

    for (final holiday in fixedHolidays) {
      if (holiday.weekday == DateTime.saturday) {
        // 土曜日の場合は金曜日に振替
        observedHolidays.add(holiday.subtract(const Duration(days: 1)));
      } else if (holiday.weekday == DateTime.sunday) {
        // 日曜日の場合は月曜日に振替
        observedHolidays.add(holiday.add(const Duration(days: 1)));
      }
    }

    holidays.addAll(observedHolidays);
  }

  // ============ イギリスの祝日 ============
  static List<DateTime> _getUKHolidays(int year) {
    final holidays = <DateTime>[];

    // New Year's Day
    holidays.add(DateTime(year, 1, 1));
    // Good Friday（イースターの2日前）
    final easter = _getEasterSunday(year);
    holidays.add(easter.subtract(const Duration(days: 2)));
    // Easter Monday
    holidays.add(easter.add(const Duration(days: 1)));
    // Early May Bank Holiday（5月第1月曜日）
    holidays.add(_getNthWeekday(year, 5, DateTime.monday, 1));
    // Spring Bank Holiday（5月最終月曜日）
    holidays.add(_getLastWeekday(year, 5, DateTime.monday));
    // Summer Bank Holiday（8月最終月曜日）
    holidays.add(_getLastWeekday(year, 8, DateTime.monday));
    // Christmas Day
    holidays.add(DateTime(year, 12, 25));
    // Boxing Day
    holidays.add(DateTime(year, 12, 26));

    // 振替休日を追加
    _addUKSubstituteHolidays(holidays, year);

    return holidays;
  }

  static void _addUKSubstituteHolidays(List<DateTime> holidays, int year) {
    final christmas = DateTime(year, 12, 25);
    final boxingDay = DateTime(year, 12, 26);

    // クリスマスとボクシングデーの振替
    if (christmas.weekday == DateTime.saturday) {
      holidays.add(DateTime(year, 12, 27)); // 月曜日
      holidays.add(DateTime(year, 12, 28)); // 火曜日（ボクシングデー振替）
    } else if (christmas.weekday == DateTime.sunday) {
      holidays.add(DateTime(year, 12, 27)); // クリスマス振替
    } else if (boxingDay.weekday == DateTime.sunday) {
      holidays.add(DateTime(year, 12, 28)); // ボクシングデー振替
    }

    // 元日の振替
    final newYear = DateTime(year, 1, 1);
    if (newYear.weekday == DateTime.saturday) {
      holidays.add(DateTime(year, 1, 3));
    } else if (newYear.weekday == DateTime.sunday) {
      holidays.add(DateTime(year, 1, 2));
    }
  }

  // ============ 中国の祝日 ============
  static List<DateTime> _getChineseHolidays(int year) {
    final holidays = <DateTime>[];

    // 元旦 (New Year's Day)
    holidays.add(DateTime(year, 1, 1));

    // 春節 (Chinese New Year) - 旧暦1月1日〜7日
    // 簡略化のため、おおよその日付を使用（毎年変動）
    final chineseNewYear = _getChineseNewYear(year);
    for (int i = 0; i < 7; i++) {
      holidays.add(chineseNewYear.add(Duration(days: i)));
    }

    // 清明節 (Qingming Festival) - 4月4日または5日
    holidays.add(DateTime(year, 4, 4));
    holidays.add(DateTime(year, 4, 5));

    // 労働節 (Labor Day)
    holidays.add(DateTime(year, 5, 1));
    holidays.add(DateTime(year, 5, 2));
    holidays.add(DateTime(year, 5, 3));

    // 端午節 (Dragon Boat Festival) - 旧暦5月5日
    final dragonBoat = _getDragonBoatFestival(year);
    holidays.add(dragonBoat);

    // 中秋節 (Mid-Autumn Festival) - 旧暦8月15日
    final midAutumn = _getMidAutumnFestival(year);
    holidays.add(midAutumn);

    // 国慶節 (National Day) - 10月1日〜7日
    for (int i = 1; i <= 7; i++) {
      holidays.add(DateTime(year, 10, i));
    }

    return holidays;
  }

  /// 中国の旧正月を計算（簡略化版）
  static DateTime _getChineseNewYear(int year) {
    // 旧暦計算の簡略化版（実際にはより複雑な計算が必要）
    // 以下は2020年から2030年までの旧正月の日付
    final chineseNewYearDates = {
      2020: DateTime(2020, 1, 25),
      2021: DateTime(2021, 2, 12),
      2022: DateTime(2022, 2, 1),
      2023: DateTime(2023, 1, 22),
      2024: DateTime(2024, 2, 10),
      2025: DateTime(2025, 1, 29),
      2026: DateTime(2026, 2, 17),
      2027: DateTime(2027, 2, 6),
      2028: DateTime(2028, 1, 26),
      2029: DateTime(2029, 2, 13),
      2030: DateTime(2030, 2, 3),
    };

    return chineseNewYearDates[year] ?? DateTime(year, 2, 1);
  }

  /// 端午節を計算（簡略化版）
  static DateTime _getDragonBoatFestival(int year) {
    final dragonBoatDates = {
      2020: DateTime(2020, 6, 25),
      2021: DateTime(2021, 6, 14),
      2022: DateTime(2022, 6, 3),
      2023: DateTime(2023, 6, 22),
      2024: DateTime(2024, 6, 10),
      2025: DateTime(2025, 5, 31),
      2026: DateTime(2026, 6, 19),
      2027: DateTime(2027, 6, 9),
      2028: DateTime(2028, 5, 28),
      2029: DateTime(2029, 6, 16),
      2030: DateTime(2030, 6, 5),
    };

    return dragonBoatDates[year] ?? DateTime(year, 6, 1);
  }

  /// 中秋節を計算（簡略化版）
  static DateTime _getMidAutumnFestival(int year) {
    final midAutumnDates = {
      2020: DateTime(2020, 10, 1),
      2021: DateTime(2021, 9, 21),
      2022: DateTime(2022, 9, 10),
      2023: DateTime(2023, 9, 29),
      2024: DateTime(2024, 9, 17),
      2025: DateTime(2025, 10, 6),
      2026: DateTime(2026, 9, 25),
      2027: DateTime(2027, 9, 15),
      2028: DateTime(2028, 10, 3),
      2029: DateTime(2029, 9, 22),
      2030: DateTime(2030, 9, 12),
    };

    return midAutumnDates[year] ?? DateTime(year, 9, 15);
  }

  /// イースター日曜日を計算（Anonymous Gregorian algorithm）
  static DateTime _getEasterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;

    return DateTime(year, month, day);
  }
}
