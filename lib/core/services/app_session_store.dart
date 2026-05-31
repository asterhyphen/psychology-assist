import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppSessionStore {
  const AppSessionStore();

  static const _databaseName = 'app_session.db';
  static const _tableName = 'session_store';
  static const _sessionKey = 'current_session';
  static const _activeUserKey = 'active_user_email';

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
    
    // Save to general current session key
    await database.insert(
      _tableName,
      {
        'key': _sessionKey,
        'value': json,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Save to user-specific email key
    final email = (session as dynamic).profile?.email;
    if (email != null && email.isNotEmpty) {
      await database.insert(
        _tableName,
        {
          'key': 'session_user_$email',
          'value': json,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Save active user email marker
      await database.insert(
        _tableName,
        {
          'key': _activeUserKey,
          'value': email,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<Map<String, dynamic>?> loadUserSession(String email) async {
    try {
      final database = await _database;
      final rows = await database.query(
        _tableName,
        columns: ['value'],
        where: 'key = ?',
        whereArgs: ['session_user_$email'],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      final decoded = jsonDecode(rows.first['value']! as String);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setActiveUser(String email) async {
    final database = await _database;
    await database.insert(
      _tableName,
      {
        'key': _activeUserKey,
        'value': email,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getActiveUser() async {
    try {
      final database = await _database;
      final rows = await database.query(
        _tableName,
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [_activeUserKey],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return rows.first['value'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> load() async {
    try {
      final database = await _database;
      final activeEmail = await getActiveUser();
      
      String keyToLoad = _sessionKey;
      if (activeEmail != null && activeEmail.isNotEmpty) {
        keyToLoad = 'session_user_$activeEmail';
      }

      final rows = await database.query(
        _tableName,
        columns: ['value'],
        where: 'key = ?',
        whereArgs: [keyToLoad],
        limit: 1,
      );

      if (rows.isEmpty) {
        // Fallback to current_session
        final fallbackRows = await database.query(
          _tableName,
          columns: ['value'],
          where: 'key = ?',
          whereArgs: [_sessionKey],
          limit: 1,
        );
        if (fallbackRows.isEmpty) {
          return null;
        }
        final decoded = jsonDecode(fallbackRows.first['value']! as String);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        return null;
      }

      final decoded = jsonDecode(rows.first['value']! as String);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final database = await _database;
    await database.delete(
      _tableName,
      where: 'key = ?',
      whereArgs: [_sessionKey],
    );
    final activeEmail = await getActiveUser();
    if (activeEmail != null && activeEmail.isNotEmpty) {
      await database.delete(
        _tableName,
        where: 'key = ?',
        whereArgs: ['session_user_$activeEmail'],
      );
      await database.delete(
        _tableName,
        where: 'key = ?',
        whereArgs: [_activeUserKey],
      );
    }
  }
}
