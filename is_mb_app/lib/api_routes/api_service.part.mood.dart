part of 'api_service.dart';

extension MoodApi on ApiService {
  Future<Response> _userMoodRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userMood';
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> createMoodRecord(Map<String, dynamic> moodEntry) async {
    String userId = authService.userIdGetter();
    return _userMoodRequest(
      operation: 'createMoodRecord',
      data: {
        'mood': moodEntry['mood'],
        'intensity': moodEntry['intensity'],
        'keywords': moodEntry['keywords'],
        'notes': moodEntry['notes'],
        'timestamp': moodEntry['timestamp'].toIso8601String(),
        'userId': userId,
        'tip': moodEntry['tip'],
      },
    );
  }

  Future<Response> getMoodHistory(String userId,
      {Map<String, dynamic> options = const {}}) async {
    return _userMoodRequest(
      operation: 'getMoodHistory',
      data: {
        'userId': userId,
        'options':
            options, // Can include filters like date range, mood types, etc.
      },
    );
  }

  Future<Response> deleteMoodRecord(String moodId) async {
    String userId = authService.userIdGetter();
    return _userMoodRequest(
      operation: 'deleteMoodRecord',
      data: {
        'moodId': moodId,
        'userId': userId, // Often needed for validation on the backend
      },
    );
  }

  Future<Response> updateFeedback(Map<String, dynamic> feedbackData) async {
    String userId = authService.userIdGetter();
    return _userMoodRequest(
      operation: 'updateFeedback',
      data: {
        'interactionId': feedbackData['interactionId'],
        'feedback': feedbackData['feedback'],
        'feedbackText': feedbackData['feedbackText'],
        'userId': userId, // Include user ID for validation
      },
    );
  }
}
