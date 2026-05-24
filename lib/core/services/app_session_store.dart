import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppSessionStore {
  const AppSessionStore();

  static const _databaseName = 'app_session.db';
  static const _tableName = 'session_store';
  static const _sessionKey = 'current_session';

  Future<Database> get _database async {
    final databasePath = await getDatabasesPath();
    return openDatabase(
      p.join(databasePath, _databaseName),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> save(Object session) async {
    final database = await _database;
    final json = jsonEncode((session as dynamic).toJson());
    await database.insert(
      _tableName,
      {
        'key': _sessionKey,
        'value': json,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> load() async {
    final database = await _database;
    final rows = await database.query(
      _tableName,
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_sessionKey],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return jsonDecode(rows.first['value']! as String) as Map<String, dynamic>;
  }
}
