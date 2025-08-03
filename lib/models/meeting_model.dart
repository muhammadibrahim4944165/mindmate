import 'package:hive/hive.dart';

part 'meeting_model.g.dart';

@HiveType(typeId: 2)
class Meeting extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String audioPath;

  @HiveField(2)
  DateTime date;

  Meeting({
    required this.title,
    required this.audioPath,
    required this.date,
  });
}
