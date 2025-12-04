/// 日本の祝日を計算するユーティリティクラス
class JapaneseHolidays {
  /// 指定された年の祝日リストを取得
  static List<DateTime> getHolidays(int year) {
    final holidays = <DateTime>[];

    // 元日
    holidays.add(DateTime(year, 1, 1));

    // 成人の日（1月第2月曜日）
    holidays.add(_getNthWeekday(year, 1, DateTime.monday, 2));

    // 建国記念の日
    holidays.add(DateTime(year, 2, 11));

    // 天皇誕生日
    holidays.add(DateTime(year, 2, 23));

    // 春分の日（計算で求める）
    holidays.add(_getVernalEquinox(year));

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

    // 秋分の日（計算で求める）
    holidays.add(_getAutumnalEquinox(year));

    // スポーツの日（10月第2月曜日）
    holidays.add(_getNthWeekday(year, 10, DateTime.monday, 2));

    // 文化の日
    holidays.add(DateTime(year, 11, 3));

    // 勤労感謝の日
    holidays.add(DateTime(year, 11, 23));

    // 振替休日を追加
    _addSubstituteHolidays(holidays, year);

    return holidays;
  }

  /// 指定された月のn番目の特定曜日を取得
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

  /// 春分の日を計算
  static DateTime _getVernalEquinox(int year) {
    // 簡易計算式
    final day = (20.8431 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
        .floor();
    return DateTime(year, 3, day);
  }

  /// 秋分の日を計算
  static DateTime _getAutumnalEquinox(int year) {
    // 簡易計算式
    final day = (23.2488 + 0.242194 * (year - 1980) - ((year - 1980) ~/ 4))
        .floor();
    return DateTime(year, 9, day);
  }

  /// 振替休日を追加
  static void _addSubstituteHolidays(List<DateTime> holidays, int year) {
    final substituteHolidays = <DateTime>[];

    for (final holiday in holidays) {
      // 祝日が日曜日の場合、翌日（または翌々日以降）が振替休日
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

  /// 指定された日付が祝日かどうかを判定
  static bool isHoliday(DateTime date) {
    final holidays = getHolidays(date.year);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return holidays.any(
      (h) =>
          h.year == normalizedDate.year &&
          h.month == normalizedDate.month &&
          h.day == normalizedDate.day,
    );
  }

  /// 祝日の名前を取得（オプション）
  static String? getHolidayName(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final year = date.year;

    final holidayNames = {
      DateTime(year, 1, 1): '元日',
      _getNthWeekday(year, 1, DateTime.monday, 2): '成人の日',
      DateTime(year, 2, 11): '建国記念の日',
      DateTime(year, 2, 23): '天皇誕生日',
      _getVernalEquinox(year): '春分の日',
      DateTime(year, 4, 29): '昭和の日',
      DateTime(year, 5, 3): '憲法記念日',
      DateTime(year, 5, 4): 'みどりの日',
      DateTime(year, 5, 5): 'こどもの日',
      _getNthWeekday(year, 7, DateTime.monday, 3): '海の日',
      DateTime(year, 8, 11): '山の日',
      _getNthWeekday(year, 9, DateTime.monday, 3): '敬老の日',
      _getAutumnalEquinox(year): '秋分の日',
      _getNthWeekday(year, 10, DateTime.monday, 2): 'スポーツの日',
      DateTime(year, 11, 3): '文化の日',
      DateTime(year, 11, 23): '勤労感謝の日',
    };

    for (final entry in holidayNames.entries) {
      if (entry.key.year == normalizedDate.year &&
          entry.key.month == normalizedDate.month &&
          entry.key.day == normalizedDate.day) {
        return entry.value;
      }
    }

    // 振替休日チェック
    if (isHoliday(date) &&
        !holidayNames.keys.any(
          (h) =>
              h.year == normalizedDate.year &&
              h.month == normalizedDate.month &&
              h.day == normalizedDate.day,
        )) {
      return '振替休日';
    }

    return null;
  }
}
