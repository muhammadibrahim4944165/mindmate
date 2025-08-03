import 'package:flutter/material.dart';
import '../services/pro_service.dart';
import 'paywall_screen.dart';
import '../services/outlook_calendar_service.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  Future<void> _syncCalendars(BuildContext context) async {
    try {
      await OutlookCalendarService.syncOutlookCalendar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outlook calendar synced!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(ProService.isPro ? Icons.sync : Icons.lock),
            tooltip:
                ProService.isPro ? 'Sync Calendars' : 'Unlock Pro to Sync',
            onPressed: () async {
              if (!ProService.isPro) {
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
              _syncCalendars(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _syncCalendars(BuildContext context) async {
    try {
      await OutlookCalendarService.syncOutlookCalendar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outlook calendar synced!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sync failed: \$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: Icon(ProService.isPro ? Icons.sync : Icons.lock),
            tooltip: ProService.isPro ? 'Sync Calendars' : 'Unlock Pro to Sync',
            onPressed: () async {
              if (!ProService.isPro) {
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
              _syncCalendars(context);
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Settings go here!'),
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      title: 'Pro Feature Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    ),
  );
}