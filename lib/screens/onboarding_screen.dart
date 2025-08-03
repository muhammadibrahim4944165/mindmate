import 'package:flutter/material.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to MindMate',
      'desc': 'Your all-in-one productivity and self-organization app.',
    },
    {
      'title': 'Stay Organized',
      'desc': 'Manage notes, tasks, meetings, habits, and events in one place.',
    },
    {
      'title': 'Private & Secure',
      'desc': 'All your data stays on your device. 100% offline.',
    },
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      setState(() => _page++);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.psychology, size: 80, color: colorScheme.primary),
            const SizedBox(height: 32),
            Text(
              _pages[_page]['title']!,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _pages[_page]['desc']!,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_page == _pages.length - 1 ? 'Get Started' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}