import 'package:hive/hive.dart';

class TrialService {
  static const String _trialBox = 'trial_info';
  static const String _startKey = 'trial_start';
  static const String _actionsKey = 'trial_actions';
  static const int trialDays = 7;
  static const int trialActions = 20;

  static Future<void> startTrialIfNeeded() async {
    final box = await Hive.openBox(_trialBox);
    if (!box.containsKey(_startKey)) {
      box.put(_startKey, DateTime.now().millisecondsSinceEpoch);
      box.put(_actionsKey, 0);
    }
  }

  static Future<int> getTrialDaysLeft() async {
    final box = await Hive.openBox(_trialBox);
    final start = box.get(_startKey, defaultValue: DateTime.now().millisecondsSinceEpoch);
    final startDate = DateTime.fromMillisecondsSinceEpoch(start);
    final daysPassed = DateTime.now().difference(startDate).inDays;
    return trialDays - daysPassed;
  }

  static Future<int> getTrialActionsLeft() async {
    final box = await Hive.openBox(_trialBox);
    final actions = box.get(_actionsKey, defaultValue: 0);
    return trialActions - (actions is int ? actions : (actions as num).toInt());
  }

  static Future<void> incrementAction() async {
    final box = await Hive.openBox(_trialBox);
    int actions = box.get(_actionsKey, defaultValue: 0);
    box.put(_actionsKey, actions + 1);
  }

  static Future<bool> isTrialActive() async {
    final daysLeft = await getTrialDaysLeft();
    final actionsLeft = await getTrialActionsLeft();
    return daysLeft > 0 && actionsLeft > 0;
  }

  static Future<void> resetTrial() async {
    final box = await Hive.openBox(_trialBox);
    await box.delete(_startKey);
    await box.delete(_actionsKey);
  }
}
