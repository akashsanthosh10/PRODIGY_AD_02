import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Todo> todobox;

  @override
  void initState() {
    super.initState();
    todobox = Hive.box<Todo>('todo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Todo List',
          style: TextStyle(fontSize: 30),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: todobox.listenable(),
        builder: (context, Box<Todo> box, _) {
          return ListView.builder(
              itemCount: box.length,
              itemBuilder: (context, index) {
                Todo todo = box.getAt(index)!;
                return Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: todo.isCompleted ? Colors.white38 : Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Dismissible(
                    key: Key(todo.dateTime.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.redAccent,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        todo.delete();
                      });
                    },
                    child: ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            Text(DateFormat.yMMMd().format(todo.dateTime)),
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editTodoDialog(context, todo);
                                })
                          ],
                        ),
                      ),
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) {
                          setState(() {
                            todo.isCompleted = value!;
                            todo.save();
                          });
                        },
                      ),
                    ),
                  ),
                );
              });
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            _addTodoDialog(context);
          },
          child: const Icon(Icons.add)),
    );
  }

  void _addTodoDialog(BuildContext context) {
    TextEditingController _title = TextEditingController();
    TextEditingController _description = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Add Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Description'),
                  )
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () {
                      _addTodo(_title.text, _description.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Add'))
              ],
            ));
  }

  void _addTodo(String title, String description) {
    if (title.isNotEmpty) {
      todobox.add(Todo(
          title: title, description: description, dateTime: DateTime.now()));
    }
  }

  void _editTodoDialog(BuildContext context, Todo todo) {
    TextEditingController _title = TextEditingController(text: todo.title);
    TextEditingController _description =
        TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Description'),
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateTodo(todo, _title.text, _description.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updateTodo(Todo todo, String title, String description) {
    if (title.isNotEmpty) {
      todo.title = title;
      todo.description = description;
      todo.save();
    }
  }
}
