import 'package:hive/hive.dart';
import '../models/synced_event_model.dart';

class CalendarSyncService {
  static final Box<SyncedEvent> _box = Hive.box<SyncedEvent>('synced_events');

  static List<SyncedEvent> getAllEvents() => _box.values.toList();

  static void addEvents(List<SyncedEvent> events) {
    for (final event in events) {
      // Avoid duplicates by title+start+source
      if (!_box.values.any((e) =>
          e.title == event.title &&
          e.start == event.start &&
          e.source == event.source)) {
        _box.add(event);
      }
    }
  }

  static void clearEvents() => _box.clear();
}