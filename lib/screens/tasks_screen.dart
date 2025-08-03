import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
import '../widgets/mindmate_card.dart';
import '../services/pro_service.dart';
import '../services/trial_service.dart';
import 'paywall_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late Box<Task> _taskBox;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _taskBox = Hive.box<Task>('tasks');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _addDemoTaskIfEmpty();
    _animController.forward();
    // Start trial if needed
    Future.microtask(() => TrialService.startTrialIfNeeded());
  }

  void _addDemoTaskIfEmpty() {
    if (_taskBox.isEmpty) {
      _taskBox.add(Task(
        title: "Try MindMate Tasks!",
        isDone: false,
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) return;
    // Check if user is Pro or trial is active
    final isPremium = await ProService.isPremium();
    if (!isPremium) {
      // If trial is over, block and show paywall
      final trialActive = await TrialService.isTrialActive();
      if (!trialActive) {
        final unlocked = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        );
        if (unlocked == true) {
          ProService.unlockPro();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trial ended. Please subscribe to continue.')),
          );
          return;
        }
      }
    }
    // Limit free/trial users to 10 tasks
    if (!ProService.isPro && _taskBox.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task limit reached. Upgrade to Pro for unlimited tasks.')),
      );
      return;
    }
    // Increment trial action if not Pro
    if (!ProService.isPro) {
      await TrialService.incrementAction();
    }
    final task = Task(
      title: title,
      isDone: false,
      createdAt: DateTime.now(),
    );
    _taskBox.add(task);
    _controller.clear();
    setState(() {});
  }

  void _toggleTask(Task task) {
    task.isDone = !task.isDone;
    task.save();
    setState(() {});
  }

  void _deleteTask(int index) {
    _taskBox.deleteAt(index);
    setState(() {});
  }

  void _showAddTaskSheet() {
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
              controller: _controller,
              decoration: const InputDecoration(labelText: 'Task'),
              autofocus: true,
              onSubmitted: (val) async {
                await _addTask(val);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_task),
              label: const Text('Add Task'),
              onPressed: () async {
                await _addTask(_controller.text);
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

  @override
  void dispose() {
    _controller.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Add Task',
            onPressed: _showAddTaskSheet,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No tasks yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index)!;
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
                  child: MindMateCard(
                    child: ListTile(
                      leading: Checkbox(
                        value: task.isDone,
                        onChanged: (_) => _toggleTask(task),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isDone ? TextDecoration.lineThrough : null,
                          color: task.isDone ? colorScheme.outline : colorScheme.onSurface,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTask(index),
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
        onPressed: _showAddTaskSheet,
        icon: const Icon(Icons.add_task),
        label: const Text('New Task'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}