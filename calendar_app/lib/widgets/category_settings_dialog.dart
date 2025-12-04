import 'package:flutter/material.dart';
import '../models/calendar_model.dart';
import '../models/category.dart';
import '../providers/theme_provider.dart';
import '../services/database_service.dart';

class CategorySettingsDialog extends StatefulWidget {
  final CalendarModel calendar;
  final VoidCallback onCategoriesUpdated;

  const CategorySettingsDialog({
    super.key,
    required this.calendar,
    required this.onCategoriesUpdated,
  });

  @override
  State<CategorySettingsDialog> createState() => _CategorySettingsDialogState();
}

class _CategorySettingsDialogState extends State<CategorySettingsDialog> {
  List<Category> _categories = [];
  bool _isLoading = true;

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
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    final categories = await DatabaseService.instance.getCategoriesForCalendar(
      widget.calendar.id!,
    );
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  Future<void> _addCategory() async {
    if (_categories.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('カテゴリは最大3つまでです'),
          backgroundColor: _hexToColor('#EF4444'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    final result = await showDialog<Category>(
      context: context,
      builder: (context) => _CategoryEditDialog(
        calendarId: widget.calendar.id!,
        availableColors: _availableColors,
        orderIndex: _categories.length,
        existingCategories: _categories,
      ),
    );

    if (result != null) {
      await DatabaseService.instance.createCategory(result);
      await _loadCategories();
      widget.onCategoriesUpdated();
      // 全画面にデータ更新を通知
      ThemeProvider.of(context)?.onDataUpdated();
    }
  }

  Future<void> _editCategory(Category category) async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => _CategoryEditDialog(
        category: category,
        calendarId: widget.calendar.id!,
        availableColors: _availableColors,
        orderIndex: category.orderIndex,
        existingCategories: _categories,
      ),
    );

    if (result != null) {
      await DatabaseService.instance.updateCategory(result);
      await _loadCategories();
      widget.onCategoriesUpdated();
      // 全画面にデータ更新を通知
      ThemeProvider.of(context)?.onDataUpdated();
    }
  }

  Future<void> _deleteCategory(Category category) async {
    final theme = ThemeProvider.of(context);
    final cardColor = theme?.cardColor ?? const Color(0xFF1A1A2E);
    final textColor = theme?.textColor ?? Colors.white;
    final secondaryTextColor =
        theme?.secondaryTextColor ?? const Color(0xFF94A3B8);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('確認', style: TextStyle(color: textColor)),
        content: Text(
          '「${category.name}」を削除しますか？\n関連するすべてのデータも削除されます。',
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
      await DatabaseService.instance.deleteCategory(category.id!);
      await _loadCategories();
      widget.onCategoriesUpdated();
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
                    color: _hexToColor(widget.calendar.color),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.category,
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
                        'カテゴリ設定',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.calendar.name,
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
            const SizedBox(height: 8),
            Text(
              '最大3つのカテゴリを設定できます (${_categories.length}/3)',
              style: TextStyle(color: secondaryTextColor, fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: CircularProgressIndicator(color: accentColor),
                ),
              )
            else if (_categories.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'カテゴリがありません\n追加してください',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryTile(category);
                  },
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _categories.length < 3 ? _addCategory : null,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'カテゴリを追加',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: accentColor,
                  disabledBackgroundColor: accentColor.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(Category category) {
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
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _hexToColor(category.color),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '数値入力',
          style: TextStyle(color: secondaryTextColor, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _editCategory(category),
              icon: Icon(Icons.edit, color: secondaryTextColor, size: 20),
            ),
            IconButton(
              onPressed: () => _deleteCategory(category),
              icon: Icon(Icons.delete, color: _hexToColor('#EF4444'), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryEditDialog extends StatefulWidget {
  final Category? category;
  final int calendarId;
  final List<String> availableColors;
  final int orderIndex;
  final List<Category> existingCategories;

  const _CategoryEditDialog({
    this.category,
    required this.calendarId,
    required this.availableColors,
    required this.orderIndex,
    required this.existingCategories,
  });

  @override
  State<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<_CategoryEditDialog> {
  late TextEditingController _nameController;
  late String _selectedColor;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? widget.availableColors.first;
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
    // 同じカレンダー内で同じ名前のカテゴリが存在するかチェック（編集中のカテゴリ自身は除く）
    return widget.existingCategories.any(
      (c) =>
          c.name.trim().toLowerCase() == name.trim().toLowerCase() &&
          c.id != widget.category?.id,
    );
  }

  void _submit() {
    final name = _nameController.text.trim();

    // 空白チェック
    if (name.isEmpty) {
      setState(() => _errorMessage = 'カテゴリ名を入力してください');
      return;
    }

    // 重複チェック
    if (_isDuplicateName(name)) {
      setState(() => _errorMessage = 'この名前は既に使われています');
      return;
    }

    final category = Category(
      id: widget.category?.id,
      calendarId: widget.calendarId,
      name: name,
      color: _selectedColor,
      orderIndex: widget.orderIndex,
    );

    Navigator.pop(context, category);
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
            Text(
              widget.category == null ? '新しいカテゴリ' : 'カテゴリを編集',
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'カテゴリ名',
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
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
                hintText: 'カテゴリ名を入力',
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
                  borderSide: BorderSide(color: accentColor, width: 2),
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
            const SizedBox(height: 20),
            Text(
              'カラー',
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _hexToColor(_selectedColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      '保存',
                      style: TextStyle(
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
