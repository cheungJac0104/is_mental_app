part of 'api_service.dart';

extension FriendApi on ApiService {
  Future<Response> _friendRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/friendList';
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> getFriendList(String userId) async {
    return _friendRequest(
      operation: 'getFriendList',
      data: {'userId': userId},
    );
  }

  Future<Response> getPendingFriendList(String userId) async {
    return _friendRequest(
      operation: 'getPendingFriendList',
      data: {'userId': userId},
    );
  }

  Future<Response> getBlockedFriendList(String userId) async {
    return _friendRequest(
      operation: 'getBlockedFriendList',
      data: {'userId': userId},
    );
  }

  Future<Response> searchUsersToAdd(String userId, String searchTerm) async {
    return _friendRequest(
      operation: 'searchUsersToFrd',
      data: {
        'userId': userId,
        'searchTerm': searchTerm,
      },
    );
  }

  Future<Response> addFriend(String requesterId, String addresseeId) async {
    return _friendRequest(
      operation: 'addFriend',
      data: {
        'requesterId': requesterId,
        'addresseeId': addresseeId,
      },
    );
  }

  Future<Response> deleteFriend(String friendshipId, String userId) async {
    return _friendRequest(
      operation: 'removeFriend',
      data: {
        'friendshipId': friendshipId,
        'userId': userId, // For validation
      },
    );
  }

  Future<Response> updateFriendStatus(
    String friendshipId,
    String userId,
    String newStatus,
  ) async {
    return _friendRequest(
      operation: 'updateFriendStatus',
      data: {
        'friendshipId': friendshipId,
        'userId': userId,
        'newStatus': newStatus, // e.g., 'accepted', 'blocked', 'pending'
      },
    );
  }
}
