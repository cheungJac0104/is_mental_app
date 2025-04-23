part of 'api_service.dart';

extension StatsApi on ApiService {
  Future<Response> _userStatsRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userStats';
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> initAnalytics(String userId) async {
    return _userStatsRequest(
      operation: 'initAnalytics',
      data: {'userId': userId},
    );
  }

  Future<Response> getUserAnalytics(
    String userId,
    String requesterId,
  ) async {
    return _userStatsRequest(
      operation: 'getUserAnalytics',
      data: {
        'userId': userId,
        'requesterId': requesterId, // For permission checking
      },
    );
  }

  Future<Response> getSentimentAnalysis(
    String userId,
    String requesterId, {
    String? timeRange,
    String? filter,
  }) async {
    return _userStatsRequest(
      operation: 'getSentimentAnalysis',
      data: {
        'userId': userId,
        'requesterId': requesterId,
        if (timeRange != null) 'timeRange': timeRange,
        if (filter != null) 'filter': filter,
      },
    );
  }
}
