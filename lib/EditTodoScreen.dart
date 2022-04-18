import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:todo_list_project/MainButton.dart';
import 'package:todo_list_project/TodoList.dart';

class EditTodoScreen extends StatefulWidget {
  static const String id = 'add_todo';
  String todoText = '';
  DateTime? deadline;
  String deadlineText = 'no deadline';
  Todo? todo;

  EditTodoScreen({Key? key, required Todo todo})
      : todo = todo,
        deadline = todo.time,
        deadlineText = todo.getTime(),
        todoText = todo.text,
        super(key: key);

  @override
  State<StatefulWidget> createState() => EditTodoScreenState(todoText);
}

class EditTodoScreenState extends State<EditTodoScreen> {
  var descriptionController = TextEditingController();

  void fillTodo() {
    widget.todo!.text = descriptionController.text;
    widget.todo!.time = widget.deadline;
  }

  EditTodoScreenState(String todoText) {
    descriptionController.text = todoText;
  }

  void apply(BuildContext context) {
    fillTodo();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    int datetimeLen = 16;
    return Scaffold(
      appBar: AppBar(title: Text('Edit Todo')),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Column(
          children: [
            const Text('Description:'),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              // onChanged: (String text) {
              // print(descriptionController.text);
              // widget.todoText = text;
              // },
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
            text: 'edit',
            onPressed: () {
              if (descriptionController.text.isNotEmpty) {
                // widget.todo.text = descriptionController.text;
                apply(context);
              }
            })
      ],
    );
  }
}
