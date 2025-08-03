import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TaskService {
  static final _box = Hive.box<Task>('tasks');

  static List<Task> getAllTasks() => _box.values.toList();

  static void addTask(Task task) => _box.add(task);

  static void updateTask(int index, Task task) => _box.putAt(index, task);

  static void deleteTask(int index) => _box.deleteAt(index);
}
