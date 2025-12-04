import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/calendar_model.dart';
import '../models/category.dart';
import '../models/category_data.dart';
import '../models/daily_note.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calendar_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // カレンダーテーブル
    await db.execute('''
      CREATE TABLE calendars (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT NOT NULL
      )
    ''');

    // カテゴリテーブル
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calendar_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color TEXT NOT NULL,
        order_index INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (calendar_id) REFERENCES calendars (id) ON DELETE CASCADE
      )
    ''');

    // カテゴリデータテーブル
    await db.execute('''
      CREATE TABLE category_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        value REAL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // デイリーノートテーブル（メモと写真）
    await db.execute('''
      CREATE TABLE daily_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        calendar_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        memo TEXT,
        photos TEXT,
        FOREIGN KEY (calendar_id) REFERENCES calendars (id) ON DELETE CASCADE
      )
    ''');

    // デフォルトカレンダーを作成
    await db.insert('calendars', {'name': 'カレンダー1', 'color': '#6366F1'});
    await db.insert('calendars', {'name': 'カレンダー2', 'color': '#EC4899'});
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 新しいテーブルを作成
      await db.execute('''
        CREATE TABLE IF NOT EXISTS calendars (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          color TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          calendar_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          color TEXT NOT NULL,
          order_index INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (calendar_id) REFERENCES calendars (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS category_data (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          value REAL,
          FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
        )
      ''');

      // デフォルトカレンダーを確認して追加
      final calendars = await db.query('calendars');
      if (calendars.isEmpty) {
        await db.insert('calendars', {'name': 'カレンダー1', 'color': '#6366F1'});
        await db.insert('calendars', {'name': 'カレンダー2', 'color': '#EC4899'});
      }
    }

    if (oldVersion < 3) {
      // デイリーノートテーブルを追加
      await db.execute('''
        CREATE TABLE IF NOT EXISTS daily_notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          calendar_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          memo TEXT,
          photos TEXT,
          FOREIGN KEY (calendar_id) REFERENCES calendars (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // ========== カレンダー操作 ==========

  Future<CalendarModel> createCalendar(CalendarModel calendar) async {
    final db = await instance.database;
    final id = await db.insert('calendars', calendar.toMap());
    return calendar.copyWith(id: id);
  }

  Future<List<CalendarModel>> getAllCalendars() async {
    final db = await instance.database;
    final result = await db.query('calendars');
    return result.map((map) => CalendarModel.fromMap(map)).toList();
  }

  Future<int> updateCalendar(CalendarModel calendar) async {
    final db = await instance.database;
    return db.update(
      'calendars',
      calendar.toMap(),
      where: 'id = ?',
      whereArgs: [calendar.id],
    );
  }

  Future<int> deleteCalendar(int id) async {
    final db = await instance.database;
    return db.delete('calendars', where: 'id = ?', whereArgs: [id]);
  }

  // ========== カテゴリ操作 ==========

  Future<Category> createCategory(Category category) async {
    final db = await instance.database;
    final id = await db.insert('categories', category.toMap());
    return category.copyWith(id: id);
  }

  Future<List<Category>> getCategoriesForCalendar(int calendarId) async {
    final db = await instance.database;
    final result = await db.query(
      'categories',
      where: 'calendar_id = ?',
      whereArgs: [calendarId],
      orderBy: 'order_index ASC',
    );
    return result.map((map) => Category.fromMap(map)).toList();
  }

  Future<int> updateCategory(Category category) async {
    final db = await instance.database;
    return db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // ========== カテゴリデータ操作 ==========

  Future<CategoryData> createOrUpdateCategoryData(CategoryData data) async {
    final db = await instance.database;
    final startOfDay = DateTime(data.date.year, data.date.month, data.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await db.query(
      'category_data',
      where: 'category_id = ? AND date >= ? AND date < ?',
      whereArgs: [
        data.categoryId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );

    if (existing.isNotEmpty) {
      final existingData = CategoryData.fromMap(existing.first);
      final updated = data.copyWith(id: existingData.id);
      await db.update(
        'category_data',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existingData.id],
      );
      return updated;
    } else {
      final id = await db.insert('category_data', data.toMap());
      return data.copyWith(id: id);
    }
  }

  Future<List<CategoryData>> getCategoryDataForDay(
    int calendarId,
    DateTime day,
  ) async {
    final db = await instance.database;
    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.rawQuery(
      '''
      SELECT cd.* FROM category_data cd
      INNER JOIN categories c ON cd.category_id = c.id
      WHERE c.calendar_id = ? AND cd.date >= ? AND cd.date < ?
      ORDER BY c.order_index ASC
    ''',
      [calendarId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return result.map((map) => CategoryData.fromMap(map)).toList();
  }

  Future<List<CategoryData>> getCategoryDataForRange(
    int calendarId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT cd.* FROM category_data cd
      INNER JOIN categories c ON cd.category_id = c.id
      WHERE c.calendar_id = ? AND cd.date >= ? AND cd.date < ?
      ORDER BY cd.date ASC, c.order_index ASC
    ''',
      [calendarId, start.toIso8601String(), end.toIso8601String()],
    );

    return result.map((map) => CategoryData.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getCategoryDataWithCategory(
    int calendarId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT cd.*, c.name as category_name, c.color as category_color
      FROM category_data cd
      INNER JOIN categories c ON cd.category_id = c.id
      WHERE c.calendar_id = ? AND cd.date >= ? AND cd.date < ?
      ORDER BY cd.date ASC, c.order_index ASC
    ''',
      [calendarId, start.toIso8601String(), end.toIso8601String()],
    );

    return result;
  }

  Future<int> deleteCategoryData(int id) async {
    final db = await instance.database;
    return db.delete('category_data', where: 'id = ?', whereArgs: [id]);
  }

  // ========== デイリーノート操作 ==========

  Future<DailyNote?> getDailyNote(int calendarId, DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await db.query(
      'daily_notes',
      where: 'calendar_id = ? AND date >= ? AND date < ?',
      whereArgs: [
        calendarId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );

    if (result.isEmpty) return null;
    return DailyNote.fromMap(result.first);
  }

  Future<DailyNote> createOrUpdateDailyNote(DailyNote note) async {
    final db = await instance.database;
    final startOfDay = DateTime(note.date.year, note.date.month, note.date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final existing = await db.query(
      'daily_notes',
      where: 'calendar_id = ? AND date >= ? AND date < ?',
      whereArgs: [
        note.calendarId,
        startOfDay.toIso8601String(),
        endOfDay.toIso8601String(),
      ],
    );

    if (existing.isNotEmpty) {
      final existingNote = DailyNote.fromMap(existing.first);
      final updated = note.copyWith(id: existingNote.id);
      await db.update(
        'daily_notes',
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existingNote.id],
      );
      return updated;
    } else {
      final id = await db.insert('daily_notes', note.toMap());
      return note.copyWith(id: id);
    }
  }

  Future<int> deleteDailyNote(int id) async {
    final db = await instance.database;
    return db.delete('daily_notes', where: 'id = ?', whereArgs: [id]);
  }

  // データベースのリセット（開発用）
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calendar_app.db');
    await deleteDatabase(path);
    _database = null;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
