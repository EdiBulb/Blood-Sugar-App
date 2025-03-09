import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'blood_sugar.db');
    print("데이터베이스 경로: $path"); // ✅ 데이터베이스 파일 경로 출력

    return await openDatabase(
      path,
      version: 2, // ✅ 버전 변경 (새로운 필드 추가)
      onCreate: _createDB,
      onUpgrade: _upgradeDB, // ✅ 데이터베이스 구조 변경 가능
    );
  }

  Future<void> _createDB(Database db, int version) async {
    print("데이터베이스 생성됨!");
    await db.execute('''
      CREATE TABLE blood_sugar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        value REAL NOT NULL,
        date TEXT NOT NULL,
        meal TEXT,
        exercise TEXT,
        memo TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE blood_sugar ADD COLUMN meal TEXT;');
      await db.execute('ALTER TABLE blood_sugar ADD COLUMN exercise TEXT;');
      await db.execute('ALTER TABLE blood_sugar ADD COLUMN memo TEXT;');
    }
  }

  Future<int> insertBloodSugar(Map<String, dynamic> data) async {
    final db = await database;
    int result = await db.insert('blood_sugar', data);
    print("저장된 혈당 데이터: $data, 결과: $result"); // ✅ 저장된 데이터 출력
    return result;
  }

  Future<List<Map<String, dynamic>>> getBloodSugarRecords() async {
    final db = await database;
    List<Map<String, dynamic>> records = await db.query('blood_sugar', orderBy: 'date DESC');
    print("불러온 혈당 기록: $records"); // ✅ 불러온 데이터 출력
    return records;
  }

  Future<int> deleteBloodSugar(int id) async {
    final db = await database;
    int result = await db.delete('blood_sugar', where: 'id = ?', whereArgs: [id]);
    print("삭제된 혈당 기록 ID: $id, 결과: $result"); // ✅ 삭제된 데이터 출력
    return result;
  }
}
