class TodoListMap {
  Map<int, Todo> map = {};

  get keys => map.keys;

  void addTodo(int id, String text, DateTime? time, {bool isDone = false}) {
    map[id] = Todo(text: text, time: time, isDone: isDone);
  }

  Todo? getTodo(int id) {
    return map[id];
  }

  int count() => map.length;
}

const int datetimeLen = 16;

String datetimeToString(DateTime dt) {
  return dt.toString().substring(0, datetimeLen);
}

class Todo {
  String text;
  DateTime? time;
  bool isDone = false;

  String getCompleted() {
    return isDone ? 'Completed' : 'Not completed';
  }

  String getTime() {
    return time != null ? datetimeToString(time!) : 'no deadline';
  }

  Todo({required this.text, this.time, this.isDone = false});
}
