import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_model.dart';
import '../models/category.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../widgets/banner_ad_widget.dart';

enum GraphType { pie, line }

enum DateRange { day, week, month }

enum DataMode { dailyTotal, byCategory }

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  // DBから取得したデータ
  List<CalendarModel> _calendars = [];
  CalendarModel? _selectedCalendar;
  List<Category> _categories = [];

  GraphType _graphType = GraphType.pie;
  DateRange _dateRange = DateRange.day;
  DataMode _dataMode = DataMode.dailyTotal;
  DateTime _selectedDate = DateTime.now();

  Map<String, dynamic> _chartData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromDB();
  }

  Future<void> _loadDataFromDB() async {
    setState(() => _isLoading = true);

    // DBからカレンダーリストを取得
    final calendars = await DatabaseService.instance.getAllCalendars();

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

    await _loadChartData();
    setState(() => _isLoading = false);
  }

  Future<void> _loadChartData() async {
    if (_selectedCalendar == null) return;

    DateTime start, end;

    switch (_dateRange) {
      case DateRange.day:
        start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        end = start.add(const Duration(days: 1));
        break;
      case DateRange.week:
        final weekday = _selectedDate.weekday;
        start = _selectedDate.subtract(Duration(days: weekday % 7));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(const Duration(days: 7));
        break;
      case DateRange.month:
        start = DateTime(_selectedDate.year, _selectedDate.month, 1);
        end = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
        break;
    }

    final data = await DatabaseService.instance.getCategoryDataWithCategory(
      _selectedCalendar!.id!,
      start,
      end,
    );

    final List<Map<String, dynamic>> chartData = [];

    if (_dataMode == DataMode.dailyTotal) {
      double total = 0;
      for (final item in data) {
        total += (item['value'] as num?)?.toDouble() ?? 0;
      }
      if (total > 0) {
        chartData.add({
          'name': '合計',
          'value': total,
          'color': _selectedCalendar!.color,
        });
      }
    } else {
      final Map<int, double> categoryTotals = {};
      for (final item in data) {
        final categoryId = item['category_id'] as int;
        final value = (item['value'] as num?)?.toDouble() ?? 0;
        categoryTotals[categoryId] = (categoryTotals[categoryId] ?? 0) + value;
      }

      for (final category in _categories) {
        final total = categoryTotals[category.id] ?? 0;
        if (total > 0) {
          chartData.add({
            'name': category.name,
            'value': total,
            'color': category.color,
            'category_id': category.id,
          });
        }
      }
    }

    final processedData = <Map<String, dynamic>>[];
    for (final item in data) {
      final date = DateTime.parse(item['date'] as String);
      processedData.add({
        'date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'value': (item['value'] as num?)?.toDouble() ?? 0,
        'category_id': item['category_id'],
        'color': item['category_color'],
      });
    }

    setState(() {
      _chartData = {
        'data': chartData,
        'rawData': processedData,
        'start': start,
        'end': end,
      };
    });
  }

  void _previousPeriod() {
    setState(() {
      switch (_dateRange) {
        case DateRange.day:
          _selectedDate = _selectedDate.subtract(const Duration(days: 1));
          break;
        case DateRange.week:
          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
          break;
        case DateRange.month:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month - 1,
            1,
          );
          break;
      }
    });
    _loadChartData();
  }

  void _nextPeriod() {
    setState(() {
      switch (_dateRange) {
        case DateRange.day:
          _selectedDate = _selectedDate.add(const Duration(days: 1));
          break;
        case DateRange.week:
          _selectedDate = _selectedDate.add(const Duration(days: 7));
          break;
        case DateRange.month:
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month + 1,
            1,
          );
          break;
      }
    });
    _loadChartData();
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  String _getDateRangeLabel() {
    switch (_dateRange) {
      case DateRange.day:
        return '${_selectedDate.month}/${_selectedDate.day}';
      case DateRange.week:
        final weekday = _selectedDate.weekday;
        final start = _selectedDate.subtract(Duration(days: weekday % 7));
        final end = start.add(const Duration(days: 6));
        return '${start.month}/${start.day} - ${end.month}/${end.day}';
      case DateRange.month:
        return '${_selectedDate.year}年${_selectedDate.month}月';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final backgroundColor = theme?.backgroundColor ?? const Color(0xFF0F0F23);
    final surfaceColor = theme?.surfaceColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.graph ?? 'グラフ',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildCalendarSelector(),
                          const SizedBox(height: 16),
                          _buildControlButtons(),
                          const SizedBox(height: 16),
                          _buildDateNavigation(),
                          const SizedBox(height: 24),
                          _buildChart(),
                          const SizedBox(height: 16),
                          if (_dataMode == DataMode.byCategory) _buildLegend(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendarSelector() {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final calendars = _calendars;
    final selectedCalendar = _selectedCalendar;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        value: selectedCalendar?.id,
        isExpanded: true,
        dropdownColor: cardColor,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: accentColor),
        items: calendars.map((calendar) {
          return DropdownMenuItem(
            value: calendar.id,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _hexToColor(calendar.color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(calendar.name, style: TextStyle(color: textColor)),
              ],
            ),
          );
        }).toList(),
        onChanged: (calendarId) async {
          if (calendarId != null) {
            final calendar = calendars.firstWhere((c) => c.id == calendarId);
            final themeProvider = ThemeProvider.of(context);
            themeProvider?.onColorChanged(_hexToColor(calendar.color));
            themeProvider?.onCalendarChanged(calendar.id);

            // カテゴリを再読み込み
            final categories = await DatabaseService.instance
                .getCategoriesForCalendar(calendarId);
            setState(() {
              _selectedCalendar = calendar;
              _categories = categories;
            });
            await _loadChartData();
          }
        },
      ),
    );
  }

  Widget _buildControlButtons() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                l10n?.pieChart ?? '円グラフ',
                Icons.pie_chart,
                _graphType == GraphType.pie,
                () {
                  setState(() => _graphType = GraphType.pie);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToggleButton(
                l10n?.lineChart ?? '折れ線',
                Icons.show_chart,
                _graphType == GraphType.line,
                () {
                  setState(() => _graphType = GraphType.line);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                l10n?.day ?? '日',
                Icons.today,
                _dateRange == DateRange.day,
                () {
                  setState(() => _dateRange = DateRange.day);
                  _loadChartData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToggleButton(
                l10n?.week ?? '週',
                Icons.date_range,
                _dateRange == DateRange.week,
                () {
                  setState(() => _dateRange = DateRange.week);
                  _loadChartData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToggleButton(
                l10n?.month ?? '月',
                Icons.calendar_month,
                _dateRange == DateRange.month,
                () {
                  setState(() => _dateRange = DateRange.month);
                  _loadChartData();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                l10n?.dailyTotal ?? '1日の合計',
                Icons.functions,
                _dataMode == DataMode.dailyTotal,
                () {
                  setState(() => _dataMode = DataMode.dailyTotal);
                  _loadChartData();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToggleButton(
                l10n?.byCategory ?? 'カテゴリごと',
                Icons.category,
                _dataMode == DataMode.byCategory,
                () {
                  setState(() => _dataMode = DataMode.byCategory);
                  _loadChartData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF64748B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.3) : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: accentColor, width: 2) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : secondaryTextColor,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : secondaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateNavigation() {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _previousPeriod,
            icon: Icon(Icons.chevron_left, color: accentColor),
          ),
          Text(
            _getDateRangeLabel(),
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _nextPeriod,
            icon: Icon(Icons.chevron_right, color: accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final theme = ThemeProvider.of(context);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final data = _chartData['data'] as List<Map<String, dynamic>>? ?? [];

    if (data.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bar_chart,
                size: 64,
                color: secondaryTextColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.noData ?? 'データがありません',
                style: TextStyle(color: secondaryTextColor, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16),
      child: _graphType == GraphType.pie
          ? _buildPieChart(data)
          : _buildLineChart(),
    );
  }

  Widget _buildPieChart(List<Map<String, dynamic>> data) {
    final theme = ThemeProvider.of(context);
    final textColor = theme?.textColor ?? Colors.white;

    return PieChart(
      PieChartData(
        sections: data.map((item) {
          final value = item['value'] as double? ?? 0;
          final color = _hexToColor(item['color'] as String? ?? '#6366F1');
          return PieChartSectionData(
            value: value,
            color: color,
            radius: 100,
            title: value.toStringAsFixed(1),
            titleStyle: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        }).toList(),
        centerSpaceRadius: 0,
      ),
    );
  }

  Widget _buildLineChart() {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final rawData = _chartData['rawData'] as List<Map<String, dynamic>>? ?? [];
    final allDates = _generateAllDatesInRange();

    if (_dataMode == DataMode.dailyTotal) {
      final Map<String, double> dateValues = {};
      for (final item in rawData) {
        final date = item['date'] as String? ?? '';
        final value = item['value'] as double? ?? 0;
        dateValues[date] = (dateValues[date] ?? 0) + value;
      }

      final spots = <FlSpot>[];
      for (int i = 0; i < allDates.length; i++) {
        final value = dateValues[allDates[i]] ?? 0;
        spots.add(FlSpot(i.toDouble(), value));
      }

      return LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: secondaryTextColor.withValues(alpha: 0.2),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: TextStyle(color: secondaryTextColor, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getBottomTitleInterval(allDates.length),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < allDates.length) {
                    final parts = allDates[index].split('-');
                    if (parts.length >= 3) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${int.parse(parts[1])}/${int.parse(parts[2])}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                          ),
                        ),
                      );
                    }
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: accentColor,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: accentColor.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      );
    }

    // カテゴリごとのライン
    final Map<int, List<FlSpot>> categorySpots = {};
    final Map<int, Color> categoryColors = {};

    for (final category in _categories) {
      categorySpots[category.id!] = [];
      categoryColors[category.id!] = _hexToColor(category.color);

      for (int i = 0; i < allDates.length; i++) {
        final dateStr = allDates[i];
        final matchingData = rawData
            .where(
              (d) => d['category_id'] == category.id && d['date'] == dateStr,
            )
            .toList();
        final value = matchingData.isNotEmpty
            ? (matchingData.first['value'] as double? ?? 0)
            : 0.0;
        categorySpots[category.id!]!.add(FlSpot(i.toDouble(), value));
      }
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: secondaryTextColor.withValues(alpha: 0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(color: secondaryTextColor, fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: _getBottomTitleInterval(allDates.length),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < allDates.length) {
                  final parts = allDates[index].split('-');
                  if (parts.length >= 3) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${int.parse(parts[1])}/${int.parse(parts[2])}',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: categorySpots.entries.map((entry) {
          return LineChartBarData(
            spots: entry.value,
            isCurved: false,
            color: categoryColors[entry.key],
            barWidth: 2,
            dotData: const FlDotData(show: true),
          );
        }).toList(),
      ),
    );
  }

  double _getBottomTitleInterval(int dataLength) {
    if (dataLength <= 7) return 1;
    if (dataLength <= 14) return 2;
    return (dataLength / 7).ceil().toDouble();
  }

  List<String> _generateAllDatesInRange() {
    final List<String> dates = [];
    DateTime start, end;

    switch (_dateRange) {
      case DateRange.day:
        start = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
        end = start;
        break;
      case DateRange.week:
        final weekday = _selectedDate.weekday;
        start = _selectedDate.subtract(Duration(days: weekday % 7));
        start = DateTime(start.year, start.month, start.day);
        end = start.add(const Duration(days: 6));
        break;
      case DateRange.month:
        start = DateTime(_selectedDate.year, _selectedDate.month, 1);
        end = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
        break;
    }

    DateTime current = start;
    while (!current.isAfter(end)) {
      dates.add(
        '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}',
      );
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  Widget _buildLegend() {
    final theme = ThemeProvider.of(context);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    // ThemeProviderから最新のカテゴリを直接取得
    final categories = theme?.categories ?? [];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: categories.map((category) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _hexToColor(category.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                category.name,
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
