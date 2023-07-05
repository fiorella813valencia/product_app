import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/Product.dart';
import '../model/ProductResume.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    final path = join(await getDatabasesPath(), 'product_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            price INTEGER,
            stock INTEGER,
            thumbnail TEXT
          )
        ''');
      },
    );

  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return db.insert('products', product.toMap());
  }

  Future<int> deleteProduct(int productId) async {
    final db = await database;
    return db.delete('products', where: 'id = ?', whereArgs: [productId]);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final result = await db.query('products');
    return result.map((map) => Product.fromMap(map)).toList();
  }



  Future<ProductResume> getProductStats() async {
    final db = await database;
    final result = await db.query('products', columns: ['price', 'stock']);

    final totalPrice = result.fold(0.0, (previous, map) {
      if (map['price'] is double) {
        return previous + (map['price'] as double);
      } else if (map['price'] is int) {
        return previous + (map['price'] as int).toDouble();
      } else {
        return previous;
      }
    });

    final totalStock = result.fold(0, (previous, map) {
      if (map['stock'] is int) {
        return previous + (map['stock'] as int);
      } else {
        return previous;
      }
    });

    return ProductResume(totalPrice: totalPrice, totalStock: totalStock);
  }

}