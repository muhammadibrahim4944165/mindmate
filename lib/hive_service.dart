import 'package:hive_flutter/hive_flutter.dart';
import 'models/note_model.dart';
import 'models/task_model.dart';
import 'models/meeting_model.dart';
import 'models/habit_model.dart';
import 'models/event_model.dart';
import 'models/synced_event_model.dart';

class HiveService {
  static Future<void> initBoxes() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(MeetingAdapter());
    Hive.registerAdapter(HabitAdapter());
    Hive.registerAdapter(EventAdapter());
    Hive.registerAdapter(SyncedEventAdapter());
    await Hive.openBox<Note>('notes');
    await Hive.openBox<Task>('tasks');
    await Hive.openBox<Meeting>('meetings');
    await Hive.openBox<Habit>('habits');
    await Hive.openBox<Event>('events');
    await Hive.openBox<SyncedEvent>('synced_events');
  // ...existing code...
  }

  static Box<Note> get notesBox => Hive.box<Note>('notes');
  static Box<Task> get tasksBox => Hive.box<Task>('tasks');
  static Box<Meeting> get meetingsBox => Hive.box<Meeting>('meetings');
  static Box<Habit> get habitsBox => Hive.box<Habit>('habits');
  static Box<Event> get eventsBox => Hive.box<Event>('events');
  static Box<SyncedEvent> get syncedEventsBox => Hive.box<SyncedEvent>('synced_events');
}
