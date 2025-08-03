import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/event_model.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/calendar_sync_service.dart';
import '../services/google_calendar_service.dart';
import '../services/outlook_calendar_service.dart';
import '../services/ios_calendar_service.dart';
import '../services/pro_service.dart';
import '../services/trial_service.dart';
import 'paywall_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _eventController = TextEditingController();
  late Box<Event> _eventBox;
  DateTime _selectedDay = DateTime.now();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _eventBox = Hive.box<Event>('events');
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _addDemoEventIfEmpty();
    _animController.forward();
    // Start trial if needed
    Future.microtask(() => TrialService.startTrialIfNeeded());
  }

  void _addDemoEventIfEmpty() {
    if (_eventBox.isEmpty) {
      _eventBox.add(Event(
        title: "Try scheduling an event!",
        description: "Tap + to add your own event.",
        date: DateTime.now(),
      ));
    }
  }

  void _addEvent(String title) {
    if (title.trim().isEmpty) return;
    final newEvent = Event(
      title: title,
      description: '',
      date: _selectedDay,
    );
    _eventBox.add(newEvent);
    _eventController.clear();
    setState(() {});
  }

  void _deleteEvent(int index) {
    _eventBox.deleteAt(index);
    setState(() {});
  }

  void _showAddEventSheet() {
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
              controller: _eventController,
              decoration: const InputDecoration(labelText: 'Event Title'),
              autofocus: true,
              onSubmitted: (val) {
                _addEvent(val);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.event),
              label: const Text('Add Event'),
              onPressed: () {
                _addEvent(_eventController.text);
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

  List<Event> _getEventsForDay(DateTime day) {
    return _eventBox.values
        .where((event) =>
            event.date.year == day.year &&
            event.date.month == day.month &&
            event.date.day == day.day)
        .toList();
  }

  // Simulate a sync (replace with real Google/Outlook/iOS logic)
  Future<void> _syncCalendars() async {
    final isPremium = await ProService.isPremium();
    if (!isPremium) {
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
    await GoogleCalendarService.syncGoogleCalendar();
    await OutlookCalendarService.syncOutlookCalendar();
    await IOSCalendarService.syncIOSCalendar();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('iOS Calendar events imported!')),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final syncedEvents = CalendarSyncService.getAllEvents();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          FutureBuilder<bool>(
            future: ProService.isPremium(),
            builder: (context, snapshot) {
              final isPremium = snapshot.data ?? false;
              return IconButton(
                icon: Icon(isPremium ? Icons.sync : Icons.lock),
                tooltip: isPremium ? 'Sync Calendars' : 'Unlock Pro/Trial to Sync',
                onPressed: _syncCalendars,
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _eventBox.listenable(),
        builder: (context, Box<Event> box, _) {
          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) =>
                    day.year == _selectedDay.year &&
                    day.month == _selectedDay.month &&
                    day.day == _selectedDay.day,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                },
                eventLoader: _getEventsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._getEventsForDay(_selectedDay).map((event) {
                      final animation = Tween<double>(begin: 0, end: 1).animate(
                        CurvedAnimation(
                          parent: _animController,
                          curve: Curves.easeOut,
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
                              title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(event.description),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _deleteEvent(box.values.toList().indexOf(event)),
                                tooltip: 'Delete',
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    if (syncedEvents.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Synced Events', style: Theme.of(context).textTheme.titleMedium),
                      ),
                      ...syncedEvents.map(
                        (event) => Card(
                          color: Colors.teal.shade50,
                          child: ListTile(
                            leading: Icon(
                              event.source == 'Google'
                                  ? Icons.calendar_today
                                  : event.source == 'Outlook'
                                      ? Icons.email
                                      : Icons.phone_iphone,
                              color: Colors.teal,
                            ),
                            title: Text(event.title),
                            subtitle: Text(
                              '${event.start} • ${event.location}\n${event.link}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: event.link.isNotEmpty
                                ? Icon(Icons.link, color: Colors.teal)
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        icon: const Icon(Icons.event),
        label: const Text('New Event'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}