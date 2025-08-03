import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'calendar_sync_service.dart';
import '../models/synced_event_model.dart';

class GoogleCalendarService {
  static final _googleSignIn = GoogleSignIn(
    scopes: [gcal.CalendarApi.calendarReadonlyScope],
  );

  static Future<void> syncGoogleCalendar() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return; // User cancelled

    final authHeaders = await account.authHeaders;
    final client = GoogleHttpClient(authHeaders);

    final calendarApi = gcal.CalendarApi(client);
    final events = await calendarApi.events.list(
      "primary",
      maxResults: 20,
      singleEvents: true,
      orderBy: "startTime",
      timeMin: DateTime.now().subtract(const Duration(days: 30)).toUtc(),
    );

    final List<SyncedEvent> imported = [];
    for (final item in events.items ?? []) {
      if (item.start == null || item.start!.dateTime == null) continue;
      imported.add(
        SyncedEvent(
          title: item.summary ?? 'No Title',
          start: item.start!.dateTime!.toLocal(),
          end: item.end?.dateTime?.toLocal() ?? item.start!.dateTime!.toLocal(),
          location: item.location ?? '',
          link: _extractMeetingLink(item.description ?? ''),
          source: 'Google',
        ),
      );
    }
    CalendarSyncService.addEvents(imported);
  }

  static String _extractMeetingLink(String text) {
    final regex = RegExp(
      r'(https:\/\/(meet\.google\.com|zoom\.us|teams\.microsoft\.com)\/[^\s]+)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    return match?.group(0) ?? '';
  }
}

class GoogleHttpClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = IOClient();

  GoogleHttpClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}