import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:restaurant_app/data/model/restaurant.dart';

class LocalLikeDatabaseService {
  static const String _databaseName = 'restaurant-app.db';
  static const String _tableName = 'favorites';
  static const int _version = 1;

  static Database? _database;

  Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE $_tableName(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        pictureId TEXT,
        city TEXT,
        rating REAL
      )
      """);
  }

  Future<Database> _initializeDb() async {
    final path = await getDatabasesPath();
    final databasePath = join(path, _databaseName);

    return openDatabase(
      databasePath,
      version: _version,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  Future<Database> get database async {
    _database ??= await _initializeDb();
    return _database!;
  }

  Future<void> insertFavorite(Restaurant restaurant) async {
    final db = await database;
    final data = {
      'id': restaurant.id,
      'name': restaurant.name,
      'description': restaurant.description,
      'pictureId': restaurant.pictureId,
      'city': restaurant.city,
      'rating': restaurant.rating,
    };

    await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Restaurant>> getFavorites() async {
    final db = await database;
    final results = await db.query(_tableName);

    return results
        .map(
          (res) => Restaurant(
            id: res['id'] as String,
            name: res['name'] as String,
            description: res['description'] as String,
            pictureId: res['pictureId'] as String,
            city: res['city'] as String,
            rating: (res['rating'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<Restaurant?> getFavoriteById(String id) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    if (results.isNotEmpty) {
      final res = results.first;
      return Restaurant(
        id: res['id'] as String,
        name: res['name'] as String,
        description: res['description'] as String,
        pictureId: res['pictureId'] as String,
        city: res['city'] as String,
        rating: (res['rating'] as num).toDouble(),
      );
    } else {
      return null;
    }
  }

  Future<void> removeFavorite(String id) async {
    final db = await database;
    await db.delete(_tableName, where: "id = ?", whereArgs: [id]);
  }

  Future<bool> isFavorite(String id) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );

    return results.isNotEmpty;
  }
}
