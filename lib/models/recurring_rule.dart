enum RecurrenceFrequency { daily, weekly, monthly }

class RecurringRule {
  final RecurrenceFrequency frequency;
  final int interval; // e.g. every 2 days/weeks/months

  RecurringRule({required this.frequency, this.interval = 1});
}