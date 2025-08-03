import 'package:hive/hive.dart';
import '../models/habit_model.dart';

class HabitService {
  static final _box = Hive.box<Habit>('habits');

  static List<Habit> getAllHabits() => _box.values.toList();

  static void addHabit(Habit habit) => _box.add(habit);

  static void toggleHabit(int index) {
    final habit = _box.getAt(index);
    if (habit != null) {
      habit.isCompleted = !habit.isCompleted;
      habit.save();
    }
  }

  static void deleteHabit(int index) => _box.deleteAt(index);
}
