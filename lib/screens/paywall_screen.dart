import 'package:flutter/material.dart';
import '../services/pro_service.dart';
import '../services/trial_service.dart';

class PaywallScreen extends StatelessWidget {
  final VoidCallback? onUnlock;

  const PaywallScreen({super.key, this.onUnlock});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder(
      future: Future.wait([
        ProService.isPremium(),
        TrialService.getTrialDaysLeft(),
        TrialService.getTrialActionsLeft(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final isPremium = snapshot.data![0] as bool;
        final daysLeft = snapshot.data![1] as int;
        final actionsLeft = snapshot.data![2] as int;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Go Premium'),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock, size: 80, color: colorScheme.primary),
                const SizedBox(height: 24),
                const Text(
                  'Unlock MindMate Pro',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  '• Multi-calendar sync\n'
                  '• Data export\n'
                  '• Recurring tasks/events\n'
                  '• Custom themes\n'
                  '• Unlimited usage\n'
                  '• Priority support',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!isPremium && (daysLeft > 0 && actionsLeft > 0)) ...[
                  Text(
                    'Trial active: $daysLeft days, $actionsLeft premium actions left',
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Continue Trial'),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.star),
                    label: const Text('Upgrade for \$4.99'),
                    onPressed: () async {
                      await ProService.buyPro();
                      if (ProService.isPro) {
                        if (onUnlock != null) {
                          onUnlock!();
                        }
                        Navigator.pop(context, true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Maybe later'),
                  ),
                ],
                // Debug-only unlock button
                if (!bool.fromEnvironment('dart.vm.product'))
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.bug_report),
                      label: const Text('Unlock Pro (Debug)'),
                      onPressed: () {
                        ProService.unlockPro();
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

bool isPremium = false; // Replace with your own logic
