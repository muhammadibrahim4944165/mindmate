import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../services/pro_service.dart';
// ...existing code...
import '../services/trial_service.dart';
import 'paywall_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  List<Note> _notes = [];
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
    // Start trial if needed
    Future.microtask(() => TrialService.startTrialIfNeeded());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadNotes() {
    setState(() {
      _notes = NoteService.getAllNotes();
      // Example data for demo
      if (_notes.isEmpty) {
        final demo = Note(
          title: "Welcome to MindMate!",
          content: "Tap + to add your first note. All your notes are private and stored on your device.",
          createdAt: DateTime.now(),
        );
        NoteService.addNote(demo);
        _notes = NoteService.getAllNotes();
      }
    });
  }

  Future<void> _addNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isNotEmpty && content.isNotEmpty) {
      // Limit free users to 5 notes
      final isPremium = await ProService.isPremium();
      if (!isPremium && _notes.length >= 5) {
        final unlocked = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaywallScreen()),
        );
        if (unlocked == true) {
          ProService.unlockPro();
        } else {
          return;
        }
      }
      // Increment trial action if not Pro
      if (!ProService.isPro) {
        await TrialService.incrementAction();
      }
      final note = Note(
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );
      NoteService.addNote(note);
      _titleController.clear();
      _contentController.clear();
      _loadNotes();
    }
  }

  void _deleteNote(Note note) {
    final index = _notes.indexOf(note);
    if (index != -1) {
      NoteService.deleteNote(index);
      _loadNotes();
    }
  }

  void _showAddNoteSheet() {
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
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              autofocus: true,
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              minLines: 2,
              maxLines: 5,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Note'),
              onPressed: () async {
                await _addNote();
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Note',
            onPressed: _showAddNoteSheet,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _notes.length,
            itemBuilder: (context, index) {
              final note = _notes[index];
              final animation = Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animController,
                  curve: Interval(index / _notes.length, 1, curve: Curves.easeOut),
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
                      title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(note.content),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteNote(note),
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
        onPressed: _showAddNoteSheet,
        icon: const Icon(Icons.add),
        label: const Text('New Note'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}