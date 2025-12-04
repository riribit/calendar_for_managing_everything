import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/calendar_model.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/calendar_selector_dialog.dart';
import '../widgets/category_settings_dialog.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // DBから取得したデータ
  List<CalendarModel> _calendars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromDB();
  }

  Future<void> _loadDataFromDB() async {
    setState(() => _isLoading = true);

    final calendars = await DatabaseService.instance.getAllCalendars();

    setState(() {
      _calendars = calendars;
      _isLoading = false;
    });
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> _showCalendarSettings() async {
    final themeProvider = ThemeProvider.of(context);
    await showDialog(
      context: context,
      builder: (context) => CalendarSelectorDialog(
        calendars: _calendars,
        selectedCalendar: _calendars.isNotEmpty ? _calendars.first : null,
        onCalendarsUpdated: () {
          // ダイアログ内での変更をThemeProviderに通知
          themeProvider?.onDataUpdated();
        },
      ),
    );
    // ThemeProviderに変更を通知（他の画面にも反映させるため）
    themeProvider?.onDataUpdated();
    // ダイアログを閉じた後、DBから再読み込み
    await _loadDataFromDB();
  }

  Future<void> _showCategorySettings(CalendarModel calendar) async {
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
    // カレンダーリストも再読み込み（カテゴリ名が変わった可能性）
    await _loadDataFromDB();
  }

  Future<void> _showLanguageSettings() async {
    final theme = ThemeProvider.of(context);
    final currentLocale = theme?.locale ?? const Locale('ja', 'JP');
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;

    final result = await showDialog<Locale>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: isDarkMode
                ? LinearGradient(
                    colors: [cardColor, const Color(0xFF16213E)],
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
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.language, color: accentColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)?.selectLanguage ??
                          'Select Language',
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
              ...AppLocalizations.supportedLocales.map((locale) {
                final isSelected =
                    locale.languageCode == currentLocale.languageCode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context, locale),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? accentColor.withValues(alpha: 0.2)
                            : (isDarkMode
                                  ? const Color(0xFF0F0F23)
                                  : const Color(0xFFF5F5F7)),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: accentColor, width: 2)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Text(
                            AppLocalizations.getLanguageName(locale),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(Icons.check_circle, color: accentColor),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.languageCode != currentLocale.languageCode) {
      theme?.onLocaleChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final backgroundColor = theme?.backgroundColor ?? const Color(0xFF0F0F23);
    final surfaceColor = theme?.surfaceColor ?? const Color(0xFF1A1A2E);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)?.menu ?? 'メニュー',
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDarkMode
                  ? [surfaceColor, Color.lerp(surfaceColor, accentColor, 0.1)!]
                  : [surfaceColor, surfaceColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSectionHeader(
                          AppLocalizations.of(context)?.themeSettings ??
                              'テーマ設定',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildThemeToggle(
                          isDarkMode,
                          accentColor,
                          cardColor,
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          AppLocalizations.of(context)?.languageSettings ??
                              '言語設定',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildLanguageTile(
                          accentColor,
                          cardColor,
                          textColor,
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          AppLocalizations.of(context)?.calendarManagement ??
                              'カレンダー管理',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuTile(
                          icon: Icons.calendar_month,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.calendarSettingsTitle ??
                              'カレンダー設定',
                          subtitle:
                              AppLocalizations.of(
                                context,
                              )?.calendarSettingsDesc ??
                              'カレンダーの追加・編集・削除',
                          color: '#6366F1',
                          cardColor: cardColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: _showCalendarSettings,
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          AppLocalizations.of(context)?.categorySettingsMenu ??
                              'カテゴリ設定',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        ..._calendars.map(
                          (calendar) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildMenuTile(
                              icon: Icons.category,
                              title: calendar.name,
                              subtitle:
                                  AppLocalizations.of(
                                    context,
                                  )?.categorySettingsDesc ??
                                  'カテゴリの設定',
                              color: calendar.color,
                              cardColor: cardColor,
                              textColor: textColor,
                              secondaryTextColor: secondaryTextColor,
                              onTap: () => _showCategorySettings(calendar),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildSectionHeader(
                          AppLocalizations.of(context)?.appInfo ?? 'アプリ情報',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 12),
                        _buildMenuTile(
                          icon: Icons.info_outline,
                          title:
                              AppLocalizations.of(context)?.version ?? 'バージョン',
                          subtitle: '1.0.0',
                          color: '#94A3B8',
                          cardColor: cardColor,
                          textColor: textColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLanguageTile(
    Color accentColor,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    final theme = ThemeProvider.of(context);
    final currentLocale = theme?.locale ?? const Locale('ja', 'JP');
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLanguageSettings,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.language, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.language ?? '言語',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.getLanguageName(currentLocale),
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: secondaryTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(
    bool isDarkMode,
    Color accentColor,
    Color cardColor,
    Color textColor,
    Color secondaryTextColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'テーマモード',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDarkMode ? 'ダークモード' : 'ライトモード',
                    style: TextStyle(color: secondaryTextColor, fontSize: 13),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ThemeProvider.of(context)?.onThemeModeChanged(!isDarkMode);
              },
              child: Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF0F0F23)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: isDarkMode ? 50 : 0,
                      child: Container(
                        width: 50,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.light_mode,
                              size: 18,
                              color: isDarkMode
                                  ? secondaryTextColor
                                  : Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Icon(
                              Icons.dark_mode,
                              size: 18,
                              color: isDarkMode
                                  ? Colors.white
                                  : secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String color,
    required Color cardColor,
    required Color textColor,
    required Color secondaryTextColor,
    required VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _hexToColor(color).withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _hexToColor(color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: _hexToColor(color), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right, color: secondaryTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
