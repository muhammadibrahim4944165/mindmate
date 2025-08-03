import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteService {
  static final _box = Hive.box<Note>('notes');

  static List<Note> getAllNotes() => _box.values.toList();

  static void addNote(Note note) => _box.add(note);

  static void updateNote(int index, Note note) => _box.putAt(index, note);

  static void deleteNote(int index) => _box.deleteAt(index);
}
