import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:todo_list_project/TodoList.dart';
import 'package:todo_list_project/MainButton.dart';

class AddTodoScreen extends StatefulWidget {
  static const String id = 'add_todo';
  String todoText = '';
  DateTime? deadline;
  String deadlineText = 'no deadline';

  @override
  State<StatefulWidget> createState() => AddTodoScreenState();
}

class AddTodoScreenState extends State<AddTodoScreen> {
  final descriptionController = TextEditingController();

  void apply(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Todo')),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          children: [
            const Text('Description:'),
            TextField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 1,
              maxLines: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () {
                      DatePicker.showDateTimePicker(context,
                          showTitleActions: true, onConfirm: (date) {
                        widget.deadline = date;
                        widget.deadlineText = datetimeToString(date);
                        setState(() {});
                      }, currentTime: DateTime.now(), locale: LocaleType.ru);
                    },
                    child: const Text(
                      'Pick task deadline',
                      style: TextStyle(color: Colors.blue),
                    )),
                Text(widget.deadlineText),
              ],
            )
          ],
        ),
      ),
      persistentFooterButtons: [
        MainButton(
            buttonWidth: 100.0,
            text: 'add todo',
            onPressed: () {
              if (descriptionController.text.isNotEmpty) {
                widget.todoText = descriptionController.text;
                apply(context);
              }
            })
      ],
    );
  }
}
