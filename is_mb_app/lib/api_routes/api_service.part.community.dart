part of 'api_service.dart';

extension CommunityApi on ApiService {
  Future<Response> _userCommuRequest({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    const path = '/userCommu';
    return _requestPattern(operation: operation, data: data, path: path);
  }

  Future<Response> createCommunityPost(
    String userId,
    String content, {
    String privacyMode = 'public',
  }) async {
    return _userCommuRequest(
      operation: 'createCommunityPost',
      data: {
        'userId': userId,
        'content': content,
        'privacyMode': privacyMode, // e.g., 'public', 'friends', 'private'
      },
    );
  }

  Future<Response> getCommunityPosts(
    String userId, {
    int limit = 20,
    int offset = 0,
  }) async {
    return _userCommuRequest(
      operation: 'getCommunityPosts',
      data: {
        'userId': userId,
        'limit': limit,
        'offset': offset,
      },
    );
  }

  Future<Response> togglePostLike(String userId, String postId) async {
    return _userCommuRequest(
      operation: 'togglePostLike',
      data: {
        'userId': userId,
        'postId': postId,
      },
    );
  }

  Future<Response> deleteCommunityPost(String userId, String postId) async {
    return _userCommuRequest(
      operation: 'deleteCommunityPost',
      data: {
        'userId': userId,
        'postId': postId,
      },
    );
  }
}
