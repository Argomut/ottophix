import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> getDatabase() async {
    if (_db != null) return _db!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'service_drafts.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE draft (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            car_id TEXT,
            service_type TEXT,
            service_description TEXT,
            service_cost TEXT,
            mechanic_ids TEXT
          )
        ''');
      },
    );

    return _db!;
  }

  static Future<void> saveDraft(Map<String, dynamic> data) async {
    final db = await getDatabase();
    await db.delete('draft');
    await db.insert('draft', data);
  }

  static Future<Map<String, dynamic>?> getDraft() async {
    final db = await getDatabase();
    final result = await db.query('draft');
    if (result.isNotEmpty) return result.first;
    return null;
  }

  static Future<void> clearDraft() async {
    final db = await getDatabase();
    await db.delete('draft');
  }
}