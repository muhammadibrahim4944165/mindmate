import 'package:hive/hive.dart';
import '../models/meeting_model.dart';

class MeetingService {
  static final _box = Hive.box<Meeting>('meetings');

  static List<Meeting> getAllMeetings() => _box.values.toList();

  static void addMeeting(Meeting meeting) => _box.add(meeting);

  static void deleteMeeting(int index) => _box.deleteAt(index);
}
