import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_app/models/calendar_model.dart';
import 'package:calendar_app/models/category.dart';
import 'package:calendar_app/providers/theme_provider.dart';

void main() {
  final testCalendars = [
    CalendarModel(id: 1, name: 'カレンダー1', color: '#6366F1'),
    CalendarModel(id: 2, name: 'カレンダー2', color: '#EC4899'),
  ];

  final testCategories = [
    Category(
      id: 1,
      calendarId: 1,
      name: 'カテゴリ1',
      color: '#6366F1',
      orderIndex: 0,
    ),
    Category(
      id: 2,
      calendarId: 1,
      name: 'カテゴリ2',
      color: '#EC4899',
      orderIndex: 1,
    ),
  ];

  const testLocale = Locale('ja', 'JP');

  group('ThemeProvider', () {
    testWidgets('should provide accent color to descendants', (tester) async {
      const testColor = Color(0xFFEC4899);
      Color? receivedColor;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: testColor,
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedColor = ThemeProvider.of(context)?.accentColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedColor, testColor);
    });

    testWidgets('should provide isDarkMode to descendants', (tester) async {
      bool? receivedDarkMode;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: false,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedDarkMode = ThemeProvider.of(context)?.isDarkMode;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedDarkMode, false);
    });

    testWidgets('should provide correct backgroundColor for dark mode', (
      tester,
    ) async {
      Color? receivedColor;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedColor = ThemeProvider.of(context)?.backgroundColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedColor, const Color(0xFF0F0F23));
    });

    testWidgets('should provide calendars list', (tester) async {
      List<CalendarModel>? receivedCalendars;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedCalendars = ThemeProvider.of(context)?.calendars;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedCalendars?.length, 2);
      expect(receivedCalendars?[0].name, 'カレンダー1');
      expect(receivedCalendars?[1].name, 'カレンダー2');
    });

    testWidgets('should provide categories list', (tester) async {
      List<Category>? receivedCategories;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedCategories = ThemeProvider.of(context)?.categories;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedCategories?.length, 2);
      expect(receivedCategories?[0].name, 'カテゴリ1');
      expect(receivedCategories?[1].name, 'カテゴリ2');
    });

    testWidgets('should provide selected calendar', (tester) async {
      CalendarModel? receivedCalendar;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 2,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedCalendar = ThemeProvider.of(context)?.selectedCalendar;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedCalendar?.id, 2);
      expect(receivedCalendar?.name, 'カレンダー2');
    });

    testWidgets('should provide dataVersion', (tester) async {
      int? receivedVersion;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 5,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedVersion = ThemeProvider.of(context)?.dataVersion;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedVersion, 5);
    });

    testWidgets('should provide locale', (tester) async {
      Locale? receivedLocale;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: const Locale('en', 'US'),
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              receivedLocale = ThemeProvider.of(context)?.locale;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(receivedLocale?.languageCode, 'en');
    });

    testWidgets('should notify when dataVersion changes', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              ThemeProvider.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 1,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              ThemeProvider.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });

    testWidgets('should notify when categories change', (tester) async {
      int buildCount = 0;

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: testCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              ThemeProvider.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      final updatedCategories = [
        Category(
          id: 1,
          calendarId: 1,
          name: '運動',
          color: '#6366F1',
          orderIndex: 0,
        ),
        Category(
          id: 2,
          calendarId: 1,
          name: '食事',
          color: '#EC4899',
          orderIndex: 1,
        ),
      ];

      await tester.pumpWidget(
        ThemeProvider(
          accentColor: const Color(0xFF6366F1),
          selectedCalendarId: 1,
          isDarkMode: true,
          locale: testLocale,
          dataVersion: 0,
          calendars: testCalendars,
          categories: updatedCategories,
          onColorChanged: (_) {},
          onCalendarChanged: (_) {},
          onThemeModeChanged: (_) {},
          onLocaleChanged: (_) {},
          onDataUpdated: () {},
          child: Builder(
            builder: (context) {
              ThemeProvider.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 2);
    });
  });
}
