import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 4)
class Event extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime date;

  Event({
    required this.title,
    required this.description,
    required this.date,
  });
}
