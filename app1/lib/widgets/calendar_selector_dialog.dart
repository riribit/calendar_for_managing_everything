import 'package:flutter/material.dart';
import '../models/calendar_model.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';

class CalendarSelectorDialog extends StatefulWidget {
  final List<CalendarModel> calendars;
  final CalendarModel? selectedCalendar;
  final VoidCallback onCalendarsUpdated;

  const CalendarSelectorDialog({
    super.key,
    required this.calendars,
    required this.selectedCalendar,
    required this.onCalendarsUpdated,
  });

  @override
  State<CalendarSelectorDialog> createState() => _CalendarSelectorDialogState();
}

class _CalendarSelectorDialogState extends State<CalendarSelectorDialog> {
  late List<CalendarModel> _calendars;

  final List<String> _availableColors = [
    '#6366F1',
    '#EC4899',
    '#10B981',
    '#F59E0B',
    '#3B82F6',
  ];

  @override
  void initState() {
    super.initState();
    _calendars = List.from(widget.calendars);
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> _addCalendar() async {
    final result = await showDialog<CalendarModel>(
      context: context,
      builder: (context) => _CalendarEditDialog(
        availableColors: _availableColors,
        existingCalendars: _calendars,
      ),
    );

    if (result != null) {
      final newCalendar = await DatabaseService.instance.createCalendar(result);
      setState(() => _calendars.add(newCalendar));
      widget.onCalendarsUpdated();
      // 全画面にデータ更新を通知
      ThemeProvider.of(context)?.onDataUpdated();
    }
  }

  Future<void> _editCalendar(CalendarModel calendar) async {
    final result = await showDialog<CalendarModel>(
      context: context,
      builder: (context) => _CalendarEditDialog(
        calendar: calendar,
        availableColors: _availableColors,
        existingCalendars: _calendars,
      ),
    );

    if (result != null) {
      await DatabaseService.instance.updateCalendar(result);
      final index = _calendars.indexWhere((c) => c.id == result.id);
      if (index != -1) {
        setState(() => _calendars[index] = result);
      }
      widget.onCalendarsUpdated();
      // 全画面にデータ更新を通知
      ThemeProvider.of(context)?.onDataUpdated();
    }
  }

  Future<void> _deleteCalendar(CalendarModel calendar) async {
    final theme = ThemeProvider.of(context);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);

    if (_calendars.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('最低1つのカレンダーが必要です'),
          backgroundColor: _hexToColor('#EF4444'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('確認', style: TextStyle(color: textColor)),
        content: Text(
          '「${calendar.name}」を削除しますか？\n関連するすべてのデータも削除されます。',
          style: TextStyle(color: secondaryTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('キャンセル', style: TextStyle(color: secondaryTextColor)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('削除', style: TextStyle(color: _hexToColor('#EF4444'))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseService.instance.deleteCalendar(calendar.id!);
      setState(() => _calendars.removeWhere((c) => c.id == calendar.id));
      widget.onCalendarsUpdated();
      // 全画面にデータ更新を通知
      ThemeProvider.of(context)?.onDataUpdated();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final backgroundColor = isDarkMode
        ? const Color(0xFF16213E)
        : const Color(0xFFF0F0F5);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [cardColor, backgroundColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isDarkMode ? null : cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? accentColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'カレンダー選択',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: secondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _calendars.length,
                itemBuilder: (context, index) {
                  final calendar = _calendars[index];
                  final isSelected = widget.selectedCalendar?.id == calendar.id;
                  return _buildCalendarTile(calendar, isSelected);
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _addCalendar,
                icon: Icon(Icons.add, color: accentColor),
                label: Text(
                  '新しいカレンダーを追加',
                  style: TextStyle(color: accentColor),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: accentColor.withValues(alpha: 0.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTile(CalendarModel calendar, bool isSelected) {
    final theme = ThemeProvider.of(context);
    final isDarkMode = theme?.isDarkMode ?? true;
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF64748B);
    final tileColor = isDarkMode
        ? const Color(0xFF0F0F23)
        : const Color(0xFFF5F5F7);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? _hexToColor(calendar.color).withValues(alpha: 0.2)
            : tileColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: _hexToColor(calendar.color), width: 2)
            : null,
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context, calendar),
        leading: GestureDetector(
          onTap: () => _changeColor(calendar),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hexToColor(calendar.color),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : const Icon(Icons.palette, color: Colors.white70, size: 18),
          ),
        ),
        title: Text(
          calendar.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '色をタップで変更',
          style: TextStyle(color: secondaryTextColor, fontSize: 10),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editCalendar(calendar),
              icon: Icon(Icons.edit, color: secondaryTextColor, size: 18),
              tooltip: '名前を変更',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            IconButton(
              onPressed: () => _deleteCalendar(calendar),
              icon: Icon(Icons.delete, color: _hexToColor('#EF4444'), size: 18),
              tooltip: '削除',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeColor(CalendarModel calendar) async {
    final theme = ThemeProvider.of(context);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final backgroundColor = isDarkMode
        ? const Color(0xFF16213E)
        : const Color(0xFFF0F0F5);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? LinearGradient(
                    colors: [cardColor, backgroundColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isDarkMode ? null : cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _hexToColor(calendar.color),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'カラーを変更',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          calendar.name,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: secondaryTextColor),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: _availableColors.map((color) {
                  final isSelected = calendar.color == color;
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, color),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _hexToColor(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _hexToColor(
                                    color,
                                  ).withValues(alpha: 0.5),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 28,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (result != null && result != calendar.color) {
      final updatedCalendar = calendar.copyWith(color: result);
      await DatabaseService.instance.updateCalendar(updatedCalendar);
      final index = _calendars.indexWhere((c) => c.id == calendar.id);
      if (index != -1) {
        setState(() => _calendars[index] = updatedCalendar);
      }
      widget.onCalendarsUpdated();
      // 全画面にデータ更新を通知
      ThemeProvider.of(context)?.onDataUpdated();
    }
  }
}

class _CalendarEditDialog extends StatefulWidget {
  final CalendarModel? calendar;
  final List<String> availableColors;
  final List<CalendarModel> existingCalendars;

  const _CalendarEditDialog({
    this.calendar,
    required this.availableColors,
    required this.existingCalendars,
  });

  @override
  State<_CalendarEditDialog> createState() => _CalendarEditDialogState();
}

class _CalendarEditDialogState extends State<_CalendarEditDialog> {
  late TextEditingController _nameController;
  late String _selectedColor;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.calendar?.name ?? '');
    _selectedColor = widget.calendar?.color ?? widget.availableColors.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  bool _isDuplicateName(String name) {
    // 同じ名前のカレンダーが存在するかチェック（編集中のカレンダー自身は除く）
    return widget.existingCalendars.any(
      (c) =>
          c.name.trim().toLowerCase() == name.trim().toLowerCase() &&
          c.id != widget.calendar?.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final isDarkMode = theme?.isDarkMode ?? true;
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final backgroundColor = isDarkMode
        ? const Color(0xFF16213E)
        : const Color(0xFFF0F0F5);
    final inputFillColor = isDarkMode
        ? const Color(0xFF0F0F23)
        : const Color(0xFFF5F5F7);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [cardColor, backgroundColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isDarkMode ? null : cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _hexToColor(_selectedColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.calendar == null ? '新しいカレンダー' : 'カレンダーを編集',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: secondaryTextColor),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'カレンダー名',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(color: textColor),
              onChanged: (_) {
                // 入力時にエラーメッセージをクリア
                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'カレンダー名を入力',
                hintStyle: TextStyle(
                  color: secondaryTextColor.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hexToColor(_selectedColor),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hexToColor('#EF4444'),
                    width: 2,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _hexToColor('#EF4444'),
                    width: 2,
                  ),
                ),
                errorText: _errorMessage,
                errorStyle: TextStyle(color: _hexToColor('#EF4444')),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'カラー',
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.availableColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hexToColor(color),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _hexToColor(
                                  color,
                                ).withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: secondaryTextColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: Text(
                      'キャンセル',
                      style: TextStyle(color: secondaryTextColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();

                      // 空白チェック
                      if (name.isEmpty) {
                        setState(() => _errorMessage = 'カレンダー名を入力してください');
                        return;
                      }

                      // 重複チェック
                      if (_isDuplicateName(name)) {
                        setState(() => _errorMessage = 'この名前は既に使われています');
                        return;
                      }

                      final calendar = CalendarModel(
                        id: widget.calendar?.id,
                        name: name,
                        color: _selectedColor,
                      );
                      Navigator.pop(context, calendar);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hexToColor(_selectedColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.calendar == null ? '作成' : '保存',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
