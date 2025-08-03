// File: lib/main.dart

import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';
import 'hive_service.dart'; // <-- Add this import
import 'screens/notes_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/meetings_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/calendar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initBoxes(); // <-- Add this line
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindMate',
      theme: mindMateTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/notes': (context) => NotesScreen(),
        '/tasks': (context) => TasksScreen(),
        '/meetings': (context) => MeetingsScreen(),
        '/habits': (context) => HabitsScreen(),
        '/calendar': (context) => CalendarScreen(),
        // Add more routes as needed
      },
    );
  }
}
