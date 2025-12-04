import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/calendar_model.dart';
import 'models/category.dart';
import 'providers/theme_provider.dart';
import 'services/database_service.dart';
import 'services/ad_service.dart';
import 'screens/home_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // AdMobを初期化
  await AdService.instance.initialize();
  runApp(const CalendarApp());
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  Color _accentColor = const Color(0xFF6366F1);
  int? _selectedCalendarId;
  bool _isDarkMode = true;
  Locale _locale = const Locale('ja', 'JP');
  bool _isInitialized = false;
  bool _isFirstLaunch = false;
  int _dataVersion = 0;
  List<CalendarModel> _calendars = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? true;
    final languageCode = prefs.getString('languageCode');
    final isFirstLaunch = languageCode == null;

    Locale locale;
    if (languageCode != null) {
      locale = Locale(languageCode);
    } else {
      locale = const Locale('ja', 'JP');
    }

    final calendars = await DatabaseService.instance.getAllCalendars();
    List<Category> categories = [];

    if (calendars.isNotEmpty) {
      categories = await DatabaseService.instance.getCategoriesForCalendar(
        calendars.first.id!,
      );
    }

    setState(() {
      _isDarkMode = isDarkMode;
      _locale = locale;
      _isFirstLaunch = isFirstLaunch;
      _calendars = calendars;
      _categories = categories;
      if (calendars.isNotEmpty) {
        _accentColor = _hexToColor(calendars.first.color);
        _selectedCalendarId = calendars.first.id;
      }
      _isInitialized = true;
    });
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  void _onColorChanged(Color color) {
    setState(() => _accentColor = color);
  }

  Future<void> _onCalendarChanged(int? calendarId) async {
    if (calendarId == null) return;

    // カテゴリも再読み込み
    final categories = await DatabaseService.instance.getCategoriesForCalendar(
      calendarId,
    );

    setState(() {
      _selectedCalendarId = calendarId;
      _categories = categories;
    });
  }

  Future<void> _onThemeModeChanged(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() => _isDarkMode = isDarkMode);
  }

  Future<void> _onLocaleChanged(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() {
      _locale = locale;
      _isFirstLaunch = false;
    });
  }

  Future<void> _onDataUpdated() async {
    // カレンダーリストとカテゴリリストを再読み込みして、全画面に更新を通知
    final calendars = await DatabaseService.instance.getAllCalendars();
    List<Category> categories = [];

    if (_selectedCalendarId != null) {
      categories = await DatabaseService.instance.getCategoriesForCalendar(
        _selectedCalendarId!,
      );
    } else if (calendars.isNotEmpty) {
      categories = await DatabaseService.instance.getCategoriesForCalendar(
        calendars.first.id!,
      );
    }

    setState(() {
      _calendars = calendars;
      _categories = categories;
      _dataVersion++;

      // 選択中のカレンダーの色も更新
      if (_selectedCalendarId != null) {
        final selectedCalendar = calendars
            .where((c) => c.id == _selectedCalendarId)
            .firstOrNull;
        if (selectedCalendar != null) {
          _accentColor = _hexToColor(selectedCalendar.color);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFF0F0F23),
          body: Center(child: CircularProgressIndicator(color: _accentColor)),
        ),
      );
    }

    return ThemeProvider(
      accentColor: _accentColor,
      selectedCalendarId: _selectedCalendarId,
      isDarkMode: _isDarkMode,
      locale: _locale,
      dataVersion: _dataVersion,
      calendars: _calendars,
      categories: _categories,
      onColorChanged: _onColorChanged,
      onCalendarChanged: _onCalendarChanged,
      onThemeModeChanged: _onThemeModeChanged,
      onLocaleChanged: _onLocaleChanged,
      onDataUpdated: _onDataUpdated,
      child: MaterialApp(
        title: 'Calendar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: _isDarkMode ? Brightness.dark : Brightness.light,
          primaryColor: _accentColor,
          scaffoldBackgroundColor: _isDarkMode
              ? const Color(0xFF0F0F23)
              : const Color(0xFFF5F5F7),
          fontFamily: 'Noto Sans JP',
          colorScheme: _isDarkMode
              ? ColorScheme.dark(
                  primary: _accentColor,
                  secondary: _accentColor.withValues(alpha: 0.7),
                  surface: const Color(0xFF1A1A2E),
                )
              : ColorScheme.light(
                  primary: _accentColor,
                  secondary: _accentColor.withValues(alpha: 0.7),
                  surface: Colors.white,
                ),
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: _locale,
        home: _isFirstLaunch
            ? _LanguageSelectionScreen(onLocaleSelected: _onLocaleChanged)
            : const HomeScreen(),
      ),
    );
  }
}

// 初回起動時の言語選択画面
class _LanguageSelectionScreen extends StatelessWidget {
  final ValueChanged<Locale> onLocaleSelected;

  const _LanguageSelectionScreen({required this.onLocaleSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ウェルカムアイコン
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF6366F1).withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 32),
                // タイトル（多言語）
                const Text(
                  'Welcome / ようこそ / 欢迎',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // 説明文
                Text(
                  'Select your language\n言語を選択してください\n请选择您的语言',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // 言語選択ボタン
                ...AppLocalizations.supportedLocales.map((locale) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onLocaleSelected(locale),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A2E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: const Color(
                                0xFF6366F1,
                              ).withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.getLanguageName(locale),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
