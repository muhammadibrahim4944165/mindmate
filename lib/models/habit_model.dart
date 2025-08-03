import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 3)
class Habit extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  DateTime date;

  // New fields for streaks
  @HiveField(3)
  int streak;

  @HiveField(4)
  DateTime? lastCompleted;

  Habit({
    required this.title,
    this.isCompleted = false,
    required this.date,
    this.streak = 0,
    this.lastCompleted,
  });
}
