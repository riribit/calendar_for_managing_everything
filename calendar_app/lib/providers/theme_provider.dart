import 'package:flutter/material.dart';
import '../models/calendar_model.dart';
import '../models/category.dart';

class ThemeProvider extends InheritedWidget {
  final Color accentColor;
  final int? selectedCalendarId;
  final bool isDarkMode;
  final Locale locale; // 言語設定
  final int dataVersion; // データ更新バージョン
  final List<CalendarModel> calendars; // カレンダーリスト
  final List<Category> categories; // カテゴリリスト（選択中カレンダーの）
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<int?> onCalendarChanged;
  final ValueChanged<bool> onThemeModeChanged;
  final ValueChanged<Locale> onLocaleChanged; // 言語変更コールバック
  final VoidCallback onDataUpdated; // データ更新通知

  const ThemeProvider({
    super.key,
    required this.accentColor,
    required this.selectedCalendarId,
    required this.isDarkMode,
    required this.locale,
    required this.dataVersion,
    required this.calendars,
    required this.categories,
    required this.onColorChanged,
    required this.onCalendarChanged,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
    required this.onDataUpdated,
    required super.child,
  });

  static ThemeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  // 選択されたカレンダーを取得
  CalendarModel? get selectedCalendar {
    if (selectedCalendarId == null || calendars.isEmpty) return null;
    try {
      return calendars.firstWhere((c) => c.id == selectedCalendarId);
    } catch (_) {
      return calendars.isNotEmpty ? calendars.first : null;
    }
  }

  // テーマに応じた色を取得するヘルパーメソッド
  Color get backgroundColor =>
      isDarkMode ? const Color(0xFF0F0F23) : const Color(0xFFF5F5F7);

  Color get surfaceColor => isDarkMode ? const Color(0xFF1A1A2E) : Colors.white;

  Color get cardColor => isDarkMode ? const Color(0xFF1A1A2E) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : const Color(0xFF1A1A2E);

  Color get secondaryTextColor =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  Color get borderColor => isDarkMode
      ? accentColor.withValues(alpha: 0.3)
      : accentColor.withValues(alpha: 0.2);

  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    return accentColor != oldWidget.accentColor ||
        selectedCalendarId != oldWidget.selectedCalendarId ||
        isDarkMode != oldWidget.isDarkMode ||
        locale != oldWidget.locale ||
        dataVersion != oldWidget.dataVersion ||
        calendars != oldWidget.calendars ||
        categories != oldWidget.categories;
  }
}
