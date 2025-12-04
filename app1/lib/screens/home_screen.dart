import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'calendar_screen.dart';
import 'graph_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _buildCurrentScreen() {
    // ThemeProviderのdataVersionをキーに含めることで、
    // データ変更時に画面を強制的に再構築
    final dataVersion = ThemeProvider.of(context)?.dataVersion ?? 0;

    switch (_currentIndex) {
      case 0:
        return CalendarScreen(key: ValueKey('calendar_$dataVersion'));
      case 1:
        return GraphScreen(key: ValueKey('graph_$dataVersion'));
      case 2:
        return MenuScreen(key: ValueKey('menu_$dataVersion'));
      default:
        return CalendarScreen(key: ValueKey('calendar_$dataVersion'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final surfaceColor = isDarkMode
        ? Color.lerp(const Color(0xFF1A1A2E), accentColor, 0.1)!
        : Colors.white;

    return Scaffold(
      body: _buildCurrentScreen(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? accentColor.withValues(alpha: 0.3)
                  : accentColor.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      0,
                      Icons.calendar_month,
                      l10n?.calendar ?? 'カレンダー',
                    ),
                    _buildNavItem(1, Icons.bar_chart, l10n?.graph ?? 'グラフ'),
                    _buildNavItem(2, Icons.menu, l10n?.menu ?? 'メニュー'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final theme = ThemeProvider.of(context);
    final accentColor = theme?.accentColor ?? const Color(0xFF6366F1);
    final isDarkMode = theme?.isDarkMode ?? true;
    final isSelected = _currentIndex == index;

    final inactiveColor = isDarkMode
        ? const Color(0xFF64748B)
        : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () => _onTabChanged(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : inactiveColor,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? accentColor : inactiveColor,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
