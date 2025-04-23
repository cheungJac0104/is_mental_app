part of 'api_service.dart';

extension UserEventApi on ApiService {
  Future<Response> _userEventRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userProfile'; // Base endpoint for user event operations
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> getOrCreatePrivacySetting(String userId) async {
    return _userEventRequest(
      operation: 'getPrivacySetting',
      data: {'userId': userId},
    );
  }

  Future<Response> updatePrivacySetting(String dataSharingLevel) async {
    // Ensure userId is included from auth service if not provided
    final userId = authService.userIdGetter();

    return _userEventRequest(
      operation: 'updatePrivacySetting',
      data: {
        'sharingLV': dataSharingLevel,
        'userId': userId, // Ensure userId is always included
      },
    );
  }

  Future<Response> addUserChallenge(
    String userId, {
    String? challengeId,
    String? challengeType,
    Map<String, dynamic>? customChallenge,
  }) async {
    return _userEventRequest(
      operation: 'addUserChallenge',
      data: {
        'userId': userId,
        if (challengeId != null) 'challengeId': challengeId,
        if (challengeType != null) 'challengeType': challengeType,
        if (customChallenge != null) 'customChallenge': customChallenge,
      },
    );
  }
}
