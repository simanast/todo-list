import 'package:sqflite/sqflite.dart';
import 'package:todo_list_project/TodoList.dart';

class DbManager {
  static Database? db;
  static const String tableName = 'Todo';
  static const String timeCol = 'time';
  static const String textCol = 'task';
  static const String doneCol = 'isDone';
  static const String idCol = 'id';

  static const String dbName = 'todo.db';

  static const String createTableQueryTemplate =
      'CREATE TABLE IF NOT EXISTS $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, $textCol TEXT, $timeCol INTEGER, $doneCol BOOL)';

  static const String insertQueryTemplate =
      'INSERT INTO $tableName ($textCol, $doneCol) VALUES(?, ?)';
  static const String insertWithDatetimeQueryTemplate =
      'INSERT INTO $tableName ($textCol, $timeCol, $doneCol) VALUES(?, ?, ?)';

  bool dbInitialized() {
    return db != null;
  }

  Future<Map<int, Todo>> init() async {
    db ??= await openDatabase(
      dbName,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          createTableQueryTemplate,
        );
      },
    );
    List<Map> rawMaps = await db?.query(
      tableName,
      columns: [idCol, textCol, timeCol, doneCol],
    ) as List<Map>;
    Map<int, Todo> maps = {};
    for (var el in rawMaps) {
      maps[el[idCol]] = Todo(
          text: el[textCol],
          time: el[timeCol] != null
              ? DateTime.fromMillisecondsSinceEpoch(el[timeCol])
              : null,
          isDone: el[doneCol] == 0 ? false : true);
    }
    return maps;
  }

  Future<int> insert(String text, DateTime? datetime, bool isDone) async {
    int id1 = -1;
    var time = datetime?.millisecondsSinceEpoch;
    await db?.transaction((txn) async {
      if (time == null) {
        id1 = await txn.rawInsert(insertQueryTemplate, [text, isDone]);
      } else {
        id1 = await txn
            .rawInsert(insertWithDatetimeQueryTemplate, [text, time, isDone]);
      }
    });
    return id1;
  }

  Future<int> update(int id, Todo todo) async {
    Map<String, dynamic> todoMap = {
      idCol: id,
      textCol: todo.text,
      doneCol: todo.isDone,
    };
    if (todo.time != null) {
      todoMap[timeCol] = todo.time!.millisecondsSinceEpoch;
    }
    return await db!
        .update(tableName, todoMap, where: 'id = ?', whereArgs: [id]);
  }

  void delete(int id) async {
    int c = await db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}
