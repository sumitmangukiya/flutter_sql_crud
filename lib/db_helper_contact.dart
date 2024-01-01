import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  // Create the 'contacts' table if it doesn't exist
  static Future<void> createContactTable(sql.Database database) async {
    await database.execute("""CREATE TABLE contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        image TEXT,
        number TEXT
    )""");
  }

  // Open or create the database
  static Future<sql.Database> db() async {
    return sql.openDatabase('database_crud.db', version: 1,
        onCreate: (sql.Database database, int version) async {
          await createContactTable(database);
        });
  }

  // Insert a new contact record
  static Future<int> createContact(String name, String? image, String number) async {
    final db = await SQLHelper.db();
    final contact = {'name': name, 'image': image, 'number': number};
    final id = await db.insert('contacts', contact,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Retrieve all contact records
  static Future<List<Map<String, dynamic>>> getAllContacts() async {
    final db = await SQLHelper.db();
    return db.query('contacts', orderBy: "id");
  }

  // Update a contact record by its ID
  static Future<int> updateContact(
      int id, String name, String? image, String number) async {
    final db = await SQLHelper.db();
    final contact = {'name': name, 'image': image, 'number': number};

    final result = await db.update('contacts', contact, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete a contact record by its ID
  static Future<void> deleteContact(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("contacts", where: "id = ?", whereArgs: [id]);
    } catch (e) {
      print(e);
    }
  }
}
