import 'journal.dart';

extension JournalExtensions on Journal {
  String get progressText => '${journalProgress?.toStringAsFixed(1)}% complete';

  bool get isShared => friendTag != null;

  String get remainingText {
    if (daysRemaining == 0) return 'Last day!';
    return '$daysRemaining ${daysRemaining == 1 ? 'day' : 'days'} left';
  }
}
