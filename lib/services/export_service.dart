import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';
import '../models/task_model.dart';

class ExportService {
  static Future<String> exportNotesToCSV() async {
    final box = Hive.box<Note>('notes');
    final buffer = StringBuffer('Title,Content,Created\n');
    for (final note in box.values) {
      buffer.writeln('"${note.title}","${note.content}","${note.createdAt}"');
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindmate_notes.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  static Future<String> exportTasksToCSV() async {
    final box = Hive.box<Task>('tasks');
    final buffer = StringBuffer('Title,Done,Created\n');
    for (final task in box.values) {
      buffer.writeln('"${task.title}",${task.isDone},"${task.createdAt}"');
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/mindmate_tasks.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }
}