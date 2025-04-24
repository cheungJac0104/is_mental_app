part of 'api_service.dart';

extension PubChallengeApi on ApiService {
  Future<Response> _pubChallengeRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/pubChallenges';
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> createPublicChallenge(
    String challengeTitle,
    DateTime completionDate,
  ) async {
    String userId = authService.userIdGetter();
    return _pubChallengeRequest(
      operation: 'addPublicChallenge',
      data: {
        'userId': userId,
        'challengeTitle': challengeTitle,
        'completionDate': completionDate.toIso8601String(),
      },
    );
  }

  Future<Response> joinPublicChallenge(String userId, String publicId) async {
    return _pubChallengeRequest(
      operation: 'userJoinPublicChallenge',
      data: {
        'userId': userId,
        'publicId': publicId,
      },
    );
  }

  Future<Response> leavePublicChallenge(String userId, String publicId) async {
    return _pubChallengeRequest(
      operation: 'userDropPublicChallenge',
      data: {
        'userId': userId,
        'publicId': publicId,
      },
    );
  }

  Future<Response> getPublicChallenges(
    String userId, {
    int limit = 10,
    int offset = 0,
  }) async {
    return _pubChallengeRequest(
      operation: 'getPublicChallenge',
      data: {
        'userId': userId,
        'limit': limit,
        'offset': offset,
      },
    );
  }

  Future<Response> getChallengeProgress(String userId, String publicId) async {
    return _pubChallengeRequest(
      operation: 'getChallengeProgress',
      data: {
        'userId': userId,
        'publicId': publicId,
      },
    );
  }

  Future<Response> addChallengeJournal(
    String userId,
    String publicId,
    Map<String, dynamic> entryData,
  ) async {
    return _pubChallengeRequest(
      operation: 'addChallengeJournal',
      data: {
        'userId': userId,
        'publicId': publicId,
        'entryData': entryData,
      },
    );
  }

  Future<Response> updateChallengeProgress(
      String userId,
      String publicId,
      String entryId,
      int progressData,
      String? shareUserId,
      bool isShared) async {
    return _pubChallengeRequest(
      operation: 'updateChallengeProgress',
      data: {
        'userId': userId,
        'publicId': publicId,
        'entryId': entryId,
        'progressData': progressData,
        'shareUserId': shareUserId,
        'isShared': isShared
      },
    );
  }

  Future<Response> deleteChallengeJournal(String userId, String entryId) async {
    return _pubChallengeRequest(
      operation: 'deleteChallengeJournal',
      data: {
        'userId': userId,
        'entryId': entryId,
      },
    );
  }

  Future<Response> getJoinedPublicChallenges(String userId) async {
    return _pubChallengeRequest(
      operation: 'getJoinedPublicChallenges',
      data: {'userId': userId},
    );
  }
}
