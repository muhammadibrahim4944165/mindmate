import 'package:hive/hive.dart';

part 'synced_event_model.g.dart';

@HiveType(typeId: 10)
class SyncedEvent extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  DateTime start;
  @HiveField(2)
  DateTime end;
  @HiveField(3)
  String location;
  @HiveField(4)
  String link; // Zoom/Meet/Teams
  @HiveField(5)
  String source; // 'Google', 'Outlook', 'iOS'

  SyncedEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    required this.link,
    required this.source,
  });
}