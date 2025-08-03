import 'package:hive/hive.dart';
import '../models/event_model.dart';

class CalendarService {
  static final _box = Hive.box<Event>('events');

  static List<Event> getAllEvents() => _box.values.toList();

  static void addEvent(Event event) => _box.add(event);

  static void deleteEvent(int index) => _box.deleteAt(index);
}
