import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cards = [
      _HomeCardData(
        icon: Icons.note,
        label: 'Notes',
        color: colorScheme.primary,
        route: '/notes',
      ),
      _HomeCardData(
        icon: Icons.check_box,
        label: 'Tasks',
        color: Colors.green,
        route: '/tasks',
      ),
      _HomeCardData(
        icon: Icons.mic,
        label: 'Meetings',
        color: Colors.deepPurple,
        route: '/meetings',
      ),
      _HomeCardData(
        icon: Icons.favorite,
        label: 'Habits',
        color: Colors.pink,
        route: '/habits',
      ),
      _HomeCardData(
        icon: Icons.event,
        label: 'Device Calendar',
        color: Colors.teal,
        route: '/device_calendar',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MindMate'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your private productivity hub.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                children: cards
                    .map((card) => _HomeCard(
                          icon: card.icon,
                          label: card.label,
                          color: card.color,
                          onTap: () {
                            Navigator.pushNamed(context, card.route);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCardData {
  final IconData icon;
  final String label;
  final Color color;
  final String route;
  _HomeCardData({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

class _HomeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _HomeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}