import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_list_project/AddTodoScreen.dart';
import 'package:todo_list_project/DbManager.dart';
import 'package:todo_list_project/TodoList.dart';

// import 'package:todo_list_project/DbManager.dart';
import 'package:todo_list_project/MainButton.dart';
import 'package:todo_list_project/EditTodoScreen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart';

final FlutterLocalNotificationsPlugin notificationPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  initializeTimeZones();

  runApp(MaterialApp(
    title: "Blue Panther",
    home: MainScreen(),
  ));
}

class MainScreen extends StatefulWidget {
  static const String id = 'main';

  @override
  State<StatefulWidget> createState() => MainScreenState();
}

class MainScreenState extends State<StatefulWidget> {

  DbManager dbManager = DbManager();
  Map<int, Todo> map = {};
  static const String notificationTitle = 'Time is up!';

  String notificationBody(String text) {
    return 'Have you finished "$text..." todo?';
  }

  void addTodoMap(int id, String text, DateTime? time, {bool isDone = false}) {
    map[id] = Todo(text: text, time: time, isDone: isDone);
  }

  Future<String> initDb() async {

    if (map.isEmpty || !dbManager.dbInitialized()) {
      map = await dbManager.init();
    }
    return Future.value('Downloaded');
  }

  void scheduleNotification(int id) async {
    if (map[id]!.time == null) {
      return;
    }
    var notificationDetails = const NotificationDetails(
        android: AndroidNotificationDetails(
      'channel id',
      'todo channel',
      channelDescription: 'Description',
      channelShowBadge: true,
      priority: Priority.high,
      importance: Importance.max,
      icon: "new_icon",
    ));
    var year = map[id]!.time!.year;
    var month = map[id]!.time!.month;
    var day = map[id]!.time!.day;
    var hour = map[id]!.time!.hour;
    var minute = map[id]!.time!.minute;
    var second = map[id]!.time!.second;
    int n = 10 >= map[id]!.text.length ? map[id]!.text.length : 10;
    String text = map[id]!.text.substring(0, n);
    await notificationPlugin.zonedSchedule(
        0,
        notificationTitle,
        notificationBody(text),
        TZDateTime.local(year, month, day, hour, minute, second),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true);

    setState(() {});
  }

  void editTodo(int id, Todo? todo) async {
    var ets = EditTodoScreen(todo: todo!);

    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ets;
    }));
    if (ets.todo!.text.isNotEmpty) {
      dbManager.update(id, todo);
      map[id] = Todo(text: ets.todo!.text, time: ets.todo!.time, isDone: ets.todo!.isDone);
    }
    if (ets.deadline!.isAfter(DateTime.now())) {
      scheduleNotification(id);
    }
    setState(() {});
  }

  void completeTodo(int id) async {
    Todo upd = map[id]!;
    upd.isDone = true;
    map[id] = upd;
    dbManager.update(id, upd);
    setState(() {});
  }

  void deleteTodo(int id) async {
    dbManager.delete(id);
    map.remove(id);
    setState(() {});
  }

  void addTodo() async {
    var ats = AddTodoScreen();
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ats;
    }));
    if (ats.todoText.isNotEmpty) {
      int id1 = -1;
      id1 = await dbManager.insert(ats.todoText, ats.deadline, false);
      addTodoMap(id1, ats.todoText, ats.deadline, isDone: false);
      scheduleNotification(id1);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: initDb(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: Text('Please wait while data is loading...')));
          }
          if (snapshot.hasError) {
            return Scaffold(
                body: Center(child: Text('Error: ${snapshot.error}')));
          }
          List<int> idxs = map.keys.toList();
          return Scaffold(
            appBar: AppBar(title: Text('Todo List')),
            body: ListView.builder(
              itemCount: map.length,
              itemBuilder: (context, index) {
                double width = MediaQuery.of(context).size.width;
                double buttonWidth = width * 0.43;
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                      borderRadius:
                          const BorderRadius.all(Radius.circular(7.0))),
                  child: Column(children: [
                    Column(children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(map[idxs[index]]!.text),
                      ),
                      Row(
                        children: [
                          Text(map[idxs[index]]!.getCompleted()),
                          const Spacer(),
                          Text(map[idxs[index]]!.getTime()),
                        ],
                      ),
                    ]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MainButton(
                            buttonWidth: buttonWidth,
                            text: 'edit',
                            onPressed: () {
                              editTodo(idxs[index], map[idxs[index]]);
                            }),
                        MainButton(
                            buttonWidth: buttonWidth,
                            text: 'complete',
                            onPressed: () {
                              completeTodo(idxs[index]);
                            }),
                        MainButton(
                            buttonWidth: buttonWidth,
                            text: 'delete',
                            onPressed: () {
                              deleteTodo(idxs[index]);
                            }),
                      ],
                    )
                  ]),
                );
              },
            ),
            persistentFooterButtons: [
              MainButton(
                  buttonWidth: 100.0, text: 'new todo', onPressed: addTodo),
            ],
          );
        });
  }
}
