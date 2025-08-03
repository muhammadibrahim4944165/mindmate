import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/meeting_model.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../services/pro_service.dart';
// ...existing code...
import 'paywall_screen.dart';

class MeetingsScreen extends StatefulWidget {
  const MeetingsScreen({super.key});

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  late Box<Meeting> _meetingBox;
  FlutterSoundRecorder? _recorder;
  bool _isRecording = false;
  String? _recordedPath;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _meetingBox = Hive.box<Meeting>('meetings');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
    _initRecorder();
    _addDemoMeetingIfEmpty();
  }

  Future<void> _initRecorder() async {
    _recorder = FlutterSoundRecorder();
    await _recorder!.openRecorder();
    await Permission.microphone.request();
  }

  void _addDemoMeetingIfEmpty() {
    if (_meetingBox.isEmpty) {
      _meetingBox.add(Meeting(
        title: "Try recording a meeting!",
        audioPath: "",
        date: DateTime.now(),
      ));
    }
  }

  Future<void> _startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/meeting_${DateTime.now().millisecondsSinceEpoch}.aac';
    await _recorder!.startRecorder(toFile: filePath, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
      _recordedPath = filePath;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _saveMeeting(String title) async {
    if (_recordedPath == null || title.trim().isEmpty) return;
    // Limit free users to 3 meetings
    if (!ProService.isPro && _meetingBox.length >= 3) {
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
    final meeting = Meeting(
      title: title,
      audioPath: _recordedPath!,
      date: DateTime.now(),
    );
    _meetingBox.add(meeting);
    _titleController.clear();
    _recordedPath = null;
    setState(() {});
  }

  void _deleteMeeting(int index) {
    final meeting = _meetingBox.getAt(index);
    if (meeting != null && meeting.audioPath.isNotEmpty) {
      final file = File(meeting.audioPath);
      if (file.existsSync()) file.deleteSync();
    }
    _meetingBox.deleteAt(index);
    setState(() {});
  }

  @override
  void dispose() {
    _recorder?.closeRecorder();
    _animController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showAddMeetingSheet() {
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
              decoration: const InputDecoration(labelText: 'Meeting Title'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Recording' : 'Record'),
                  onPressed: () async {
                    if (_isRecording) {
                      await _stopRecording();
                    } else {
                      await _startRecording();
                    }
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                if (_recordedPath != null && !_isRecording)
                  Icon(Icons.check_circle, color: Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Meeting'),
              onPressed: () async {
                await _saveMeeting(_titleController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
        title: const Text('Meetings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Record Meeting',
            onPressed: _showAddMeetingSheet,
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _meetingBox.listenable(),
        builder: (context, Box<Meeting> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No meetings yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final meeting = box.getAt(index)!;
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
                      title: Text(meeting.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        meeting.audioPath.isEmpty
                          ? "No recording"
                          : "Recorded: ${meeting.date.toLocal().toString().split('.')[0]}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteMeeting(index),
                        tooltip: 'Delete',
                      ),
                      onTap: meeting.audioPath.isNotEmpty
                        ? () async {
                            final player = FlutterSoundPlayer();
                            await player.openPlayer();
                            await player.startPlayer(fromURI: meeting.audioPath);
                            await Future.delayed(const Duration(seconds: 2));
                            await player.stopPlayer();
                            await player.closePlayer();
                          }
                        : null,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeetingSheet,
        icon: const Icon(Icons.mic),
        label: const Text('Record'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}