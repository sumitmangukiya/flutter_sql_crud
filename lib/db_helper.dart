import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  // Create the 'data' table if it doesn't exist
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE data(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        title TEXT,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  // Open or create the database
  static Future<sql.Database> db() async {
    return sql.openDatabase('database_crud.db', version: 1,
        onCreate: (sql.Database database, int version) async {
          await createTables(database);
        });
  }

  // Insert a new data record
  static Future<int> createData(String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': description};
    final id = await db.insert('data', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Retrieve all data records
  static Future<List<Map<String, dynamic>>> getAllDatas() async {
    final db = await SQLHelper.db();
    return db.query('data', orderBy: "id");
  }

  // Retrieve a single data record by its ID
  static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
    final db = await SQLHelper.db();
    return db.query('data', where: "id = ?", whereArgs: [id]);
  }

  // Update a data record by its ID
  static Future<int> updateData(
      int id, String title, String? description) async {
    final db = await SQLHelper.db();
    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result = await db.update('data', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete a data record by its ID
  static Future<void> deleteData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("data", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print(e);
    }
  }
}
