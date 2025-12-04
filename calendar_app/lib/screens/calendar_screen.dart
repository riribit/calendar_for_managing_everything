import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_model.dart';
import '../models/category.dart';
import '../models/category_data.dart';
import '../models/daily_note.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../utils/holidays.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/calendar_selector_dialog.dart';
import '../widgets/category_settings_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // DBから取得したデータ
  List<CalendarModel> _calendars = [];
  CalendarModel? _selectedCalendar;
  List<Category> _categories = [];

  Map<int, double?> _categoryValues = {};
  Map<DateTime, bool> _daysWithData = {};
  bool _isLoading = true;

  // メモと写真
  DailyNote? _dailyNote;
  final TextEditingController _memoController = TextEditingController();
  final FocusNode _memoFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _memoFocusNode.addListener(_onMemoFocusChange);
    _loadDataFromDB();
  }

  @override
  void dispose() {
    _memoController.dispose();
    _memoFocusNode.removeListener(_onMemoFocusChange);
    _memoFocusNode.dispose();
    super.dispose();
  }

  void _onMemoFocusChange() {
    if (!_memoFocusNode.hasFocus) {
      _saveMemo();
    }
  }

  Future<void> _loadDataFromDB() async {
    setState(() => _isLoading = true);

    // DBからカレンダーリストを取得
    var calendars = await DatabaseService.instance.getAllCalendars();

    // カレンダーがない場合はデフォルトを作成
    if (calendars.isEmpty) {
      await DatabaseService.instance.createCalendar(
        CalendarModel(name: 'カレンダー1', color: '#6366F1'),
      );
      calendars = await DatabaseService.instance.getAllCalendars();
    }

    // ThemeProviderから選択中のカレンダーIDを取得
    final themeProvider = ThemeProvider.of(context);
    final selectedId = themeProvider?.selectedCalendarId;

    CalendarModel? selectedCalendar;
    if (calendars.isNotEmpty) {
      if (selectedId != null) {
        selectedCalendar = calendars.firstWhere(
          (c) => c.id == selectedId,
          orElse: () => calendars.first,
        );
      } else {
        selectedCalendar = calendars.first;
        // ThemeProviderに選択を通知
        themeProvider?.onCalendarChanged(selectedCalendar.id);
        themeProvider?.onColorChanged(_hexToColor(selectedCalendar.color));
      }
    }

    // 選択中カレンダーのカテゴリを取得
    List<Category> categories = [];
    if (selectedCalendar != null) {
      categories = await DatabaseService.instance.getCategoriesForCalendar(
        selectedCalendar.id!,
      );
    }

    setState(() {
      _calendars = calendars;
      _selectedCalendar = selectedCalendar;
      _categories = categories;
    });

    await _loadCategoryDataForDay();
    await _loadDailyNoteData();

    setState(() => _isLoading = false);
  }

  Future<void> _loadCategoryDataForDay() async {
    final calendar = _selectedCalendar;
    if (calendar == null) return;

    final dayData = await DatabaseService.instance.getCategoryDataForDay(
      calendar.id!,
      _selectedDay,
    );

    final values = <int, double?>{};
    for (final category in _categories) {
      final data = dayData
          .where((d) => d.categoryId == category.id)
          .firstOrNull;
      values[category.id!] = data?.value;
    }

    // 月のデータがある日を取得
    final startOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final endOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    final monthData = await DatabaseService.instance.getCategoryDataForRange(
      calendar.id!,
      startOfMonth,
      endOfMonth,
    );

    final daysWithData = <DateTime, bool>{};
    for (final data in monthData) {
      if (data.value != null) {
        final day = DateTime(data.date.year, data.date.month, data.date.day);
        daysWithData[day] = true;
      }
    }

    setState(() {
      _categoryValues = values;
      _daysWithData = daysWithData;
    });
  }

  Future<void> _loadDailyNoteData() async {
    final calendar = _selectedCalendar;
    if (calendar == null) return;

    final dailyNote = await DatabaseService.instance.getDailyNote(
      calendar.id!,
      _selectedDay,
    );

    setState(() {
      _dailyNote = dailyNote;
      _memoController.text = dailyNote?.memo ?? '';
    });
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _loadCategoryDataForDay();
      _loadDailyNoteData();
    }
  }

  Future<void> _showCalendarSelector() async {
    final themeProvider = ThemeProvider.of(context);

    final result = await showDialog<CalendarModel>(
      context: context,
      builder: (context) => CalendarSelectorDialog(
        calendars: _calendars,
        selectedCalendar: _selectedCalendar,
        onCalendarsUpdated: () {
          // ダイアログ内での変更をThemeProviderに通知
          themeProvider?.onDataUpdated();
        },
      ),
    );

    // ThemeProviderに変更を通知（他の画面にも反映させるため）
    themeProvider?.onDataUpdated();

    // ダイアログを閉じた後、常にDBから最新データを取得
    final calendars = await DatabaseService.instance.getAllCalendars();

    setState(() => _calendars = calendars);

    if (result != null && result.id != _selectedCalendar?.id) {
      // カレンダーを切り替えた場合
      themeProvider?.onColorChanged(_hexToColor(result.color));
      themeProvider?.onCalendarChanged(result.id);

      // 最新のカレンダー情報を取得
      final updatedCalendar = calendars.firstWhere(
        (c) => c.id == result.id,
        orElse: () => result,
      );
      final categories = await DatabaseService.instance
          .getCategoriesForCalendar(result.id!);
      setState(() {
        _selectedCalendar = updatedCalendar;
        _categories = categories;
      });
      await _loadCategoryDataForDay();
      await _loadDailyNoteData();
    } else {
      // カレンダーを切り替えなかった場合も、名前が変わった可能性があるので更新
      if (_selectedCalendar != null) {
        final updated = calendars.firstWhere(
          (c) => c.id == _selectedCalendar!.id,
          orElse: () => _selectedCalendar!,
        );
        // カテゴリも再読み込み（名前が変わっている可能性）
        final categories = await DatabaseService.instance
            .getCategoriesForCalendar(updated.id!);
        setState(() {
          _selectedCalendar = updated;
          _categories = categories;
        });
      }
    }
  }

  Future<void> _showCategorySettings() async {
    final calendar = _selectedCalendar;
    if (calendar == null) return;

    final themeProvider = ThemeProvider.of(context);

    await showDialog(
      context: context,
      builder: (context) => CategorySettingsDialog(
        calendar: calendar,
        onCategoriesUpdated: () {
          // ダイアログ内での変更をThemeProviderに通知
          themeProvider?.onDataUpdated();
        },
      ),
    );

    // ThemeProviderに変更を通知（他の画面にも反映させるため）
    themeProvider?.onDataUpdated();

    // カテゴリを再読み込み
    final categories = await DatabaseService.instance.getCategoriesForCalendar(
      calendar.id!,
    );
    setState(() => _categories = categories);
    await _loadCategoryDataForDay();
  }

  Future<void> _saveCategoryValue(Category category, double? value) async {
    final data = CategoryData(
      categoryId: category.id!,
      date: _selectedDay,
      value: value,
    );
    await DatabaseService.instance.createOrUpdateCategoryData(data);
    await _loadCategoryDataForDay();
  }

  Future<void> _saveMemo() async {
    final calendar = _selectedCalendar;
    if (calendar == null) return;

    final note = DailyNote(
      id: _dailyNote?.id,
      calendarId: calendar.id!,
      date: _selectedDay,
      memo: _memoController.text,
      photos: _dailyNote?.photos ?? [],
    );

    final saved = await DatabaseService.instance.createOrUpdateDailyNote(note);
    setState(() => _dailyNote = saved);
  }

  Future<void> _addPhoto() async {
    final calendar = _selectedCalendar;
    if (calendar == null) return;

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('写真を追加', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
              title: const Text(
                'カメラで撮影',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF6366F1),
              ),
              title: const Text(
                'ライブラリから選択',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final photosDir = Directory('${appDir.path}/photos');
        if (!await photosDir.exists()) {
          await photosDir.create(recursive: true);
        }

        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
        final savedPath = '${photosDir.path}/$fileName';
        await File(image.path).copy(savedPath);

        final photos = List<String>.from(_dailyNote?.photos ?? []);
        photos.add(savedPath);

        final note = DailyNote(
          id: _dailyNote?.id,
          calendarId: calendar.id!,
          date: _selectedDay,
          memo: _memoController.text,
          photos: photos,
        );

        final saved = await DatabaseService.instance.createOrUpdateDailyNote(
          note,
        );
        setState(() => _dailyNote = saved);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('写真の追加に失敗しました: $e')));
      }
    }
  }

  Future<void> _deletePhoto(String path) async {
    final calendar = _selectedCalendar;
    if (calendar == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('写真を削除', style: TextStyle(color: Colors.white)),
        content: const Text(
          'この写真を削除しますか？',
          style: TextStyle(color: Color(0xFF94A3B8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }

        final photos = List<String>.from(_dailyNote?.photos ?? []);
        photos.remove(path);

        final note = DailyNote(
          id: _dailyNote?.id,
          calendarId: calendar.id!,
          date: _selectedDay,
          memo: _memoController.text,
          photos: photos,
        );

        final saved = await DatabaseService.instance.createOrUpdateDailyNote(
          note,
        );
        setState(() => _dailyNote = saved);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('写真の削除に失敗しました: $e')));
        }
      }
    }
  }

  void _showPhotoViewer(String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoViewerScreen(imagePath: path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final backgroundColor = theme?.backgroundColor ?? const Color(0xFF0F0F23);
    final surfaceColor = theme?.surfaceColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: GestureDetector(
          onTap: _showCalendarSelector,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedCalendar != null) ...[
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _hexToColor(_selectedCalendar?.color ?? '#6366F1'),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  _selectedCalendar?.name ?? 'カレンダー',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_drop_down, color: textColor),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showCategorySettings,
            icon: Icon(Icons.settings, color: secondaryTextColor),
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? LinearGradient(
                    colors: [
                      surfaceColor,
                      Color.lerp(surfaceColor, accentColor, 0.1)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isDarkMode ? null : surfaceColor,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : Column(
              children: [
                // バナー広告
                const BannerAdWidget(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [backgroundColor, surfaceColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildCalendar(),
                          const SizedBox(height: 8),
                          _buildSelectedDateHeader(),
                          _buildCategoryInputSection(),
                          _buildMemoSection(),
                          _buildPhotoSection(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? accentColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TableCalendar<void>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _loadCategoryDataForDay();
        },
        calendarBuilders: CalendarBuilders(
          dowBuilder: (context, day) {
            final l10n = AppLocalizations.of(context);
            final weekDays = [
              l10n?.sunday ?? '日',
              l10n?.monday ?? '月',
              l10n?.tuesday ?? '火',
              l10n?.wednesday ?? '水',
              l10n?.thursday ?? '木',
              l10n?.friday ?? '金',
              l10n?.saturday ?? '土',
            ];
            final text = weekDays[day.weekday % 7];
            Color color;
            if (day.weekday == DateTime.sunday) {
              color = const Color(0xFFEF4444);
            } else if (day.weekday == DateTime.saturday) {
              color = const Color(0xFF3B82F6);
            } else {
              color = isDarkMode
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B);
            }
            return Center(
              child: Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            );
          },
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              accentColor,
              isDarkMode,
              isSelected: false,
              isToday: false,
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              accentColor,
              isDarkMode,
              isSelected: false,
              isToday: true,
            );
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(
              day,
              accentColor,
              isDarkMode,
              isSelected: true,
              isToday: false,
            );
          },
          markerBuilder: (context, day, events) {
            final normalizedDay = DateTime(day.year, day.month, day.day);
            if (_daysWithData[normalizedDay] == true) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _selectedCalendar != null
                        ? _hexToColor(_selectedCalendar?.color ?? '#6366F1')
                        : const Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor),
          ),
          formatButtonTextStyle: TextStyle(
            color: accentColor,
            fontWeight: FontWeight.bold,
          ),
          titleTextStyle: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          leftChevronIcon: Icon(Icons.chevron_left, color: accentColor),
          rightChevronIcon: Icon(Icons.chevron_right, color: accentColor),
        ),
        daysOfWeekHeight: 30,
        weekendDays: const [DateTime.sunday],
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day,
    Color accentColor,
    bool isDarkMode, {
    required bool isSelected,
    required bool isToday,
  }) {
    final theme = ThemeProvider.of(context);
    final locale = theme?.locale ?? const Locale('ja', 'JP');
    final isHoliday = Holidays.isHoliday(day, locale);
    final isSunday = day.weekday == DateTime.sunday;
    final isSaturday = day.weekday == DateTime.saturday;

    Color textColor;
    if (isSunday || isHoliday) {
      textColor = const Color(0xFFEF4444);
    } else if (isSaturday) {
      textColor = const Color(0xFF3B82F6);
    } else {
      textColor = isDarkMode ? Colors.white : const Color(0xFF1A1A2E);
    }

    if (isSelected) {
      textColor = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isSelected
            ? LinearGradient(
                colors: [accentColor, accentColor.withValues(alpha: 0.7)],
              )
            : null,
        color: isToday && !isSelected
            ? accentColor.withValues(alpha: isDarkMode ? 0.5 : 0.3)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: (isHoliday || isSunday || isSaturday)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDateHeader() {
    final theme = ThemeProvider.of(context);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final l10n = AppLocalizations.of(context);
    final weekDays = [
      l10n?.sunday ?? '日',
      l10n?.monday ?? '月',
      l10n?.tuesday ?? '火',
      l10n?.wednesday ?? '水',
      l10n?.thursday ?? '木',
      l10n?.friday ?? '金',
      l10n?.saturday ?? '土',
    ];
    final dayOfWeekSuffix = l10n?.dayOfWeek ?? '曜日';

    // 日付フォーマット（言語に応じて変更）
    final locale = theme?.locale ?? const Locale('ja', 'JP');
    String dateText;
    String weekDayText;
    if (locale.languageCode == 'ja') {
      dateText = '${_selectedDay.year}年${_selectedDay.month}月';
      weekDayText = '${weekDays[_selectedDay.weekday % 7]}$dayOfWeekSuffix';
    } else if (locale.languageCode == 'zh') {
      dateText = '${_selectedDay.year}年${_selectedDay.month}月';
      weekDayText = '星期${weekDays[_selectedDay.weekday % 7]}';
    } else {
      dateText = '${_selectedDay.year}/${_selectedDay.month}';
      weekDayText = weekDays[_selectedDay.weekday % 7];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _selectedCalendar != null
                    ? [
                        _hexToColor(_selectedCalendar?.color ?? '#6366F1'),
                        _hexToColor(
                          _selectedCalendar?.color ?? '#6366F1',
                        ).withValues(alpha: 0.7),
                      ]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedDay.day}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateText,
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              Text(
                weekDayText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInputSection() {
    final accentColor =
        ThemeProvider.of(context)?.accentColor ?? const Color(0xFF6366F1);
    final l10n = AppLocalizations.of(context);
    if (_categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 60,
              color: accentColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.noCategories ?? 'カテゴリがありません',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _showCategorySettings,
              icon: Icon(Icons.add, color: accentColor),
              label: Text(
                l10n?.addCategory ?? 'カテゴリを追加',
                style: TextStyle(color: accentColor),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _categories.map((category) {
          return _CategoryInputTile(
            key: ValueKey(
              '${category.id}_${_selectedDay.year}_${_selectedDay.month}_${_selectedDay.day}',
            ),
            category: category,
            value: _categoryValues[category.id],
            onValueChanged: (value) => _saveCategoryValue(category, value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMemoSection() {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: isDarkMode ? 0.3 : 0.2),
          ),
          boxShadow: isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Icon(Icons.note_alt, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.memo ?? 'メモ',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _memoController,
              focusNode: _memoFocusNode,
              maxLines: 4,
              minLines: 2,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: l10n?.memoPlaceholder ?? 'メモを入力...',
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.3)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onEditingComplete: _saveMemo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final photos = _dailyNote?.photos ?? [];
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withValues(alpha: isDarkMode ? 0.3 : 0.2),
          ),
          boxShadow: isDarkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.photo_library, color: accentColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.photos ?? '写真',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_a_photo, color: accentColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.addPhoto ?? '追加',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (photos.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  l10n?.noPhotos ?? '写真がありません',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final path = photos[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => _showPhotoViewer(path),
                        onLongPress: () => _deletePhoto(path),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: const Color(0xFF0F0F23),
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _deletePhoto(path),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final String imagePath;

  const _PhotoViewerScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.white, size: 64),
                    SizedBox(height: 16),
                    Text(
                      '画像を読み込めませんでした',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CategoryInputTile extends StatefulWidget {
  final Category category;
  final double? value;
  final ValueChanged<double?> onValueChanged;

  const _CategoryInputTile({
    super.key,
    required this.category,
    required this.value,
    required this.onValueChanged,
  });

  @override
  State<_CategoryInputTile> createState() => _CategoryInputTileState();
}

class _CategoryInputTileState extends State<_CategoryInputTile> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;
  String _lastSavedText = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _lastSavedText = _controller.text;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _saveValue();
    }
    setState(() => _isEditing = _focusNode.hasFocus);
  }

  @override
  void didUpdateWidget(_CategoryInputTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value?.toString() ?? '';
      _lastSavedText = _controller.text;
    }
  }

  @override
  void dispose() {
    if (_controller.text != _lastSavedText) {
      final text = _controller.text.trim();
      final value = text.isEmpty ? null : double.tryParse(text);
      widget.onValueChanged(value);
    }
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  void _saveValue() {
    final text = _controller.text.trim();
    if (text != _lastSavedText) {
      final value = text.isEmpty ? null : double.tryParse(text);
      widget.onValueChanged(value);
      _lastSavedText = text;
    }
  }

  void _onSubmit() {
    _saveValue();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final categoryColor = _hexToColor(widget.category.color);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? categoryColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 70,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.category.name,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: categoryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '-',
                hintStyle: TextStyle(
                  color: (theme?.secondaryTextColor ?? const Color(0xFF94A3B8))
                      .withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF0F0F23)
                    : const Color(0xFFF5F5F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: categoryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _onSubmit(),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
