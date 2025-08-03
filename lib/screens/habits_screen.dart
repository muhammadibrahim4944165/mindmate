import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit_model.dart';
// ...existing code...
// ...existing code...

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});
  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> with SingleTickerProviderStateMixin {

  Future<void> _addHabit(String title) async {
    if (title.trim().isEmpty) return;
    final habit = Habit(
      title: title,
      isCompleted: false,
      date: DateTime.now(),
    );
    _habitBox.add(habit);
    _habitController.clear();
    setState(() {});
  }
  bool _isCompletedToday(Habit habit) {
    final today = DateTime.now();
    return habit.isCompleted &&
        habit.date.year == today.year &&
        habit.date.month == today.month &&
        habit.date.day == today.day;
  }

  void _toggleCompletion(Habit habit, int index) {
    final today = DateTime.now();
    if (!_isCompletedToday(habit)) {
      habit.isCompleted = true;
      habit.date = today;
      if (habit.lastCompleted != null) {
        final last = habit.lastCompleted!;
        final diff = today.difference(DateTime(last.year, last.month, last.day)).inDays;
        if (diff == 1) {
          habit.streak += 1;
        } else if (diff > 1) {
          habit.streak = 1;
        }
      } else {
        habit.streak = 1;
      }
      habit.lastCompleted = today;
    } else {
      habit.isCompleted = false;
    }
    habit.save();
    setState(() {});
  }

  void _deleteHabit(int index) {
    _habitBox.deleteAt(index);
    setState(() {});
  }

  void _showAddHabitSheet() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _habitController,
              decoration: const InputDecoration(labelText: 'Habit'),
              autofocus: true,
              onSubmitted: (val) async {
                await _addHabit(val);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Habit'),
              onPressed: () async {
                await _addHabit(_habitController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  final TextEditingController _habitController = TextEditingController();
  late Box<Habit> _habitBox;
  late AnimationController _animController;

  void _addDemoHabitIfEmpty() {
    if (_habitBox.isEmpty) {
      _habitBox.add(Habit(
        title: "Try tracking a habit!",
        isCompleted: false,
        date: DateTime.now(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _habitBox.listenable(),
        builder: (context, Box<Habit> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No habits yet!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final habit = box.getAt(index)!;
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animController,
                  curve: Interval(index / box.length, 1, curve: Curves.easeOut),
                ),
              );
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: Checkbox(
                        value: _isCompletedToday(habit),
                        onChanged: (_) => _toggleCompletion(habit, index),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      title: Text(
                        habit.title,
                        style: TextStyle(
                          decoration: _isCompletedToday(habit) ? TextDecoration.lineThrough : null,
                          color: _isCompletedToday(habit) ? colorScheme.outline : colorScheme.onSurface,
                        ),
                      ),
                      subtitle: habit.streak > 0
                          ? Text('🔥 Streak: ${habit.streak} day${habit.streak == 1 ? '' : 's'}', style: const TextStyle(color: Colors.orange))
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteHabit(index),
                        tooltip: 'Delete',
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHabitSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _habitBox = Hive.box<Habit>('habits');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _addDemoHabitIfEmpty();
    _animController.forward();
  }
}