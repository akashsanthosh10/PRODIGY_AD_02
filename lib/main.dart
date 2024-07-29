import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/home_screen.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TodoAdaptor());
  await Hive.openBox<Todo>("todo");
  runApp(MyApp());
}

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String description;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late DateTime dateTime;

  Todo({
    required this.title,
    required this.description,
    required this.dateTime,
    this.isCompleted = false,
  });
}

class TodoAdaptor extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      title: reader.readString(),
      description: reader.readString(),
      dateTime: DateTime.parse(reader.readString()),
      isCompleted: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.dateTime.toIso8601String());
    writer.writeBool(obj.isCompleted);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(primaryColorDark: Colors.white12),
      home: HomeScreen(),
    );
  }
}
