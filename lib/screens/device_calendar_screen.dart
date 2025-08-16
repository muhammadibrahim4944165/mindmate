import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';

class DeviceCalendarScreen extends StatefulWidget {
  const DeviceCalendarScreen({super.key});

  @override
  State<DeviceCalendarScreen> createState() => _DeviceCalendarScreenState();
}

class _DeviceCalendarScreenState extends State<DeviceCalendarScreen> {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
  List<Calendar> _calendars = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _retrieveCalendars();
  }

  Future<void> _retrieveCalendars() async {
    final permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (!(permissionsGranted.data ?? false)) {
      await _deviceCalendarPlugin.requestPermissions();
    }
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    setState(() {
      _calendars = calendarsResult.data ?? [];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Calendar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _calendars.length,
              itemBuilder: (context, index) {
                final calendar = _calendars[index];
                return ListTile(
                  title: Text(calendar.name ?? 'Unnamed Calendar'),
                  subtitle: Text(calendar.id ?? ''),
                );
              },
            ),
    );
  }
}
