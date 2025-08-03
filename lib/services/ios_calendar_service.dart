import 'package:device_calendar/device_calendar.dart';
import 'calendar_sync_service.dart';
import '../models/synced_event_model.dart';

class IOSCalendarService {
  static final DeviceCalendarPlugin _calendarPlugin = DeviceCalendarPlugin();

  static Future<void> syncIOSCalendar() async {
    final permissionsGranted = await _calendarPlugin.hasPermissions();
    if (!(permissionsGranted.data ?? false)) {
      final result = await _calendarPlugin.requestPermissions();
      if (!(result.data ?? false)) return;
    }

    final calendarsResult = await _calendarPlugin.retrieveCalendars();
    final calendars = calendarsResult.data ?? [];
    if (calendars.isEmpty) return;

    final List<SyncedEvent> imported = [];
    for (final calendar in calendars) {
      final eventsResult = await _calendarPlugin.retrieveEvents(
        calendar.id!,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 90)),
        ),
      );
      final events = eventsResult.data ?? [];
      for (final event in events) {
        imported.add(
          SyncedEvent(
            title: event.title ?? 'No Title',
            start: event.start ?? DateTime.now(),
            end: event.end ?? event.start ?? DateTime.now(),
            location: event.location ?? '',
            link: _extractMeetingLink(event.description ?? ''),
            source: 'iOS',
          ),
        );
      }
    }
    CalendarSyncService.addEvents(imported);
  }

  static String _extractMeetingLink(String text) {
    final regex = RegExp(
      r'(https:\/\/(zoom\.us|meet\.google\.com|teams\.microsoft\.com)\/[^\s]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    return match?.group(0) ?? '';
  }
}