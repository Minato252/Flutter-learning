import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:weitong/Model/messageHistoryModel.dart';

class DatabaseHelper {
  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  // DatabaseHelper.internal();

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'sqflite.db');
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  //创建数据库表
  void _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE message (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    userId TEXT NOT NULL, 
    targetId TEXT NOT NULL, 
    keyWords TEXT NOT NULL, 
    title TEXT NOT NULL,
    sendTime INTEGER NOT NULL
    htmlCode TEXT NOT NULL);
    ''');
    print("Table is created");
  }

  Future<int> insert(MessageHistoryModel message, String tableName) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", message.toMap());
    print(res.toString());
    return res;
  }

  Future<List> getTotalList(String sql) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(sql);
    return result.toList();
  }

  //查询总数
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(
        await dbClient.rawQuery("SELECT COUNT(*) FROM message"));
  }

  //按照发送方和接收方id查询
  Future<List> getItem(String userId, String targetId) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery(
        "SELECT * FROM message WHERE userId=${userId} AND targetId=${targetId}");
    if (result.length == 0) return null;
    return result.toList();
  }

  //关闭
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}
