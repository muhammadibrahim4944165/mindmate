import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';
// ...existing code...
// ...existing code...

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
  // ...existing code...
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
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index)!;
              return Dismissible(
                key: ValueKey(task.key),
                background: Container(color: Colors.redAccent),
                onDismissed: (_) => _deleteTask(index),
                child: ListTile(
                  leading: Checkbox(
                    value: task.isDone,
                    onChanged: (_) => _toggleTask(task),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  title: GestureDetector(
                    onTap: () {
                      _controller.text = task.title;
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
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Save'),
                                onPressed: () async {
                                  final title = _controller.text.trim();
                                  if (title.isNotEmpty) {
                                    task.title = title;
                                    task.save();
                                    setState(() {});
                                    Navigator.pop(context);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Delete'),
                                onPressed: () {
                                  _deleteTask(index);
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone ? TextDecoration.lineThrough : null,
                        color: task.isDone ? colorScheme.outline : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.drag_handle),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final task = box.getAt(oldIndex);
              box.deleteAt(oldIndex);
              box.putAt(newIndex, task!);
              setState(() {});
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