import 'dart:core';

import 'package:flutter/material.dart';
import 'package:is_mb_app/models/friend_extension.dart';
import 'package:is_mb_app/partical_layouts/loading_screen.dart';
import 'package:is_mb_app/partical_layouts/wave_background.dart';
import 'package:provider/provider.dart';

import '../api_routes/api_service.dart';
import '../models/api_response.dart';
import '../models/pending_friend.dart';
import '../models/post.dart';
import '../partical_layouts/bottom_loading_bar.dart';
import '../partical_layouts/pending_notifications.dart';
import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import 'community_challenge.dart';
import 'community_friends.dart';
import 'community_privacy.dart';
import 'tailwind.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  CommunityScreenState createState() => CommunityScreenState();
}

class CommunityScreenState extends State<CommunityScreen> {
  late ApiService apiService;
  late AuthService authService;
  late NavigationService navService;
  bool _isLoading = true;
  final double _uploadProgress = 0.95;
  ChallengeResponse? _challengeResponse;
  PostResponse? _postResponse;
  FriendResponse? _friendResponse;
  PendingFriendResponse? _pendingFriendResponse;
  BlockedListResponse? _blockedListResponse;
  Set<String> _joinedChallenges = {};
  late String userId;
  Map<String, int> _participates = {};
  Map<String, bool> _postLikes = {};
  Map<String, int> _postCounts = {};
  late String privacy;

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    navService = Provider.of<NavigationService>(context, listen: false);
    userId = authService.userIdGetter();
    privacy = authService.privacyGetter();
    fetchData();
  }

  bool _isResponseValid(Map<String, dynamic>? response) {
    return response != null && response['success'] == true;
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Make parallel API calls for better performance
      final results = await Future.wait([
        apiService.getFriendList(userId),
        apiService.getPendingFriendList(userId),
        apiService.getBlockedFriendList(userId),
        apiService.getCommunityPosts(userId),
        apiService.getPublicChallenges(userId),
        apiService.getJoinedPublicChallenges(userId)
      ]);

      // Process each response
      final friendsResponse = apiService.getResBodyJson(results[0]);
      final pendingResponse = apiService.getResBodyJson(results[1]);
      final blockedResponse = apiService.getResBodyJson(results[2]);
      final postsResponse = apiService.getResBodyJson(results[3]);
      final challengesResponse = apiService.getResBodyJson(results[4]);
      final joinedChallengesResponse = apiService.getResBodyJson(results[5]);

      // Usage:
      if (!_isResponseValid(friendsResponse) ||
          !_isResponseValid(pendingResponse) ||
          !_isResponseValid(blockedResponse) ||
          !_isResponseValid(postsResponse) ||
          !_isResponseValid(challengesResponse) ||
          !_isResponseValid(joinedChallengesResponse)) {
        throw Exception('Failed to fetch community data');
      }

      _friendResponse = FriendResponse.fromJson(friendsResponse);
      _pendingFriendResponse = PendingFriendResponse.fromJson(pendingResponse);
      _blockedListResponse = BlockedListResponse.fromJson(blockedResponse);
      _postResponse = PostResponse.fromJson(postsResponse);
      _challengeResponse = ChallengeResponse.fromJson(challengesResponse);
      _joinedChallenges = (joinedChallengesResponse['data'] as List)
          .map((item) => item.toString())
          .toSet();

      _participates = Map.fromEntries(
        _challengeResponse!.data.map(
          (item) => MapEntry(
            item.challengeId ?? "",
            int.parse(item.participantCount ?? "0"),
          ),
        ),
      );

      _postLikes = Map.fromEntries(_postResponse!.data.map(
        (e) => MapEntry(e.postId ?? "", e.isLiked ?? false),
      ));

      _postCounts = Map.fromEntries(_postResponse!.data.map(
        (e) => MapEntry(e.postId ?? "", e.likeCount ?? 0),
      ));

      // For now, we'll just print the data counts
      debugPrint('''
      Fetched community data:
      - Friends: ${friendsResponse['count']}
      - Pending: ${pendingResponse['count']}
      - Blocked: ${blockedResponse['count']}
      - Posts: ${postsResponse['count']}
      - Challenges: ${challengesResponse['count']}
    ''');
    } catch (e) {
      debugPrint('Error fetching community data: $e');
      // Optionally show an error to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load community data: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mainCanvas();
  }

  Widget _mainCanvas() {
    if (_isLoading) {
      return const LoadingScreen();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Community',
              style: TwTextStyles.heading1(context).copyWith(
                fontFamily: 'Pacifico',
                color: TwColors.text(context),
                fontStyle: FontStyle.italic,
              )),
          centerTitle: true,
          actions: [
            PendingNotifications(
              pendingFriends: _pendingFriendResponse?.data ?? [],
              onRespondToRequest: _respondToRequest,
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => navService.toScreen(
                  screen: PrivacySettingPage(
                      userId: userId,
                      apiService: apiService,
                      blockedFriends: _blockedListResponse?.data ?? [],
                      privacy: privacy),
                  clearStack: false),
            ),
          ],
        ),
        body: RefreshIndicator(
            onRefresh: fetchData, // This will trigger when pulled down
            child: _contentField()));
  }

  Widget _contentField() {
    return Stack(
      children: [
        const WaveBackground(
          colors: [Colors.blue, Colors.purple],
          numberOfWaves: 3,
          amplitude: 80.0,
          animationDuration: Duration(seconds: 8),
        ),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPublicChallenges(),
              _buildFriendsList(),
              _buildCommunityPosts(_postResponse!.data),
            ],
          ),
        ),
        if (_isLoading)
          Positioned(
            bottom: 34, // Match your padding
            left: 24, // Match your padding
            right: 24, // Match your padding
            child: BottomLoadingBar(
              progress: _uploadProgress,
              statusText: "we almost there...",
            ),
          ),
      ],
    );
  }

  Future<void> _respondToRequest(PendingFriendship friend, bool accept) async {
    try {
      // TODO: Implement API call to respond to request
      // await apiService.respondToFriendRequest(friend.id, accept);

      // Update local state
      setState(() {
        _pendingFriendResponse?.data.remove(friend);
        if (accept) {
          final newFriend = friend.beFriend();
          _friendResponse?.data.add(newFriend);
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(accept ? 'Request accepted' : 'Request declined')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Widget _buildPublicChallenges() {
    return CommunityChallenges(
      challenges: _challengeResponse?.data ?? [],
      joinedChallenges: _joinedChallenges,
      participates: _participates,
      onChallengeToggle: (challengeId, isJoined) async {
        final result = await challengeJoin(challengeId, isJoined);
        if (!mounted) return;
        setState(() {
          if (_participates.containsKey(challengeId)) {
            _participates[challengeId] = result
                ? _participates[challengeId]! + 1
                : _participates[challengeId]! - 1;
          }
        });
      },
      userId: userId,
      apiService: apiService,
      friends: _friendResponse!.data,
    );
  }

  Future<bool> challengeJoin(String challengeId, bool isJoin) async {
    try {
      if (!isJoin) {
        _joinedChallenges.add(challengeId);

        await apiService.joinPublicChallenge(userId, challengeId);
      } else {
        _joinedChallenges.remove(challengeId);
        await apiService.leavePublicChallenge(userId, challengeId);
      }

      return !isJoin;
    } catch (e) {
      return isJoin;
    }
  }

  Widget _buildFriendsList() {
    return CommunityFriends(
      friends: _friendResponse?.data ?? [],
      pendingFriends: _pendingFriendResponse?.data ?? [],
      userId: userId,
      apiService: apiService,
    );
  }

  Widget _buildCommunityPosts(List<Post> posts) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posts',
            style: TwTextStyles.body(context).copyWith(
              fontFamily: 'Pacifico',
              color: TwColors.text(context),
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          if (posts.isEmpty)
            _buildEmptyPostsState()
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) =>
                  _buildPostItem(posts[index], index),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPostsState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.forum_outlined,
            size: 60,
            color: TwColors.text(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TwTextStyles.body(context).copyWith(
              color: TwColors.text(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: TwTextStyles.body(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post, int index) {
    final timeAgo = _getTimeAgo(post.createdAt);
    final postId = post.postId ?? "";
    bool isLiked = _postLikes[postId] ?? false;
    int likeCount = _postCounts[postId] ?? 0;
    final authorName = post.author?.username ?? 'Anonymous';
    final privacyMode =
        post.privacyMode ?? 'public'; // Default to public if null

    // Map privacy modes to icons
    final privacyIcons = {
      'public': Icons.public,
      'friends': Icons.people,
      'private': Icons.lock,
    };
    final privacyIcon = privacyIcons[privacyMode] ?? Icons.public;

    void likeClick() async {
      final rtn = await _toggleLike(post.postId ?? '', isLiked);
      if (!mounted) return;
      setState(() {
        _postCounts[postId] = rtn ? likeCount + 1 : likeCount - 1;
        if (likeCount < 0) _postCounts[postId] = 0;
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: _getAvatarColor(authorName),
            child: Text(
              authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                authorName,
                style: TwTextStyles.body(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                privacyIcon,
                size: 16,
                color: TwColors.text(context).withOpacity(0.6),
              ),
            ],
          ),
          subtitle: Text(timeAgo),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showPostOptions(post),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            post.content ?? '',
            style: TwTextStyles.body(context),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? Colors.red : TwColors.text(context),
                ),
                onPressed: () => likeClick(),
              ),
              Text(
                likeCount.toString(),
                style: TwTextStyles.body(context),
              ),
              const SizedBox(width: 16),
              // Optional: Add text label for privacy mode
              if (privacyMode != 'public') ...[
                const SizedBox(width: 8),
                Text(
                  privacyMode,
                  style: TwTextStyles.body(context).copyWith(
                    color: TwColors.text(context).withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

// Helper functions
  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFF44336), // Red
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
    ];
    final hash = name.hashCode;
    return colors[hash % colors.length];
  }

// Action handlers
  Future<bool> _toggleLike(String postId, bool isLiked) async {
    try {
      final rtn = !isLiked;
      _postLikes[postId] = rtn;
      await apiService.togglePostLike(userId, postId);
      return isLiked = rtn;
    } catch (e) {
      return isLiked;
    }
  }

  void _navigateToComments(String postId) {
    // Navigate to comments screen
  }

  void _sharePost(Post post) {
    // Implement share functionality
  }

  void _showPostOptions(Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Save post'),
              onTap: () {
                Navigator.pop(context);
                // Save post
              },
            ),
            if (post.userId == authService.userIdGetter()) ...[
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit post'),
                onTap: () {
                  Navigator.pop(context);
                  // Edit post
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete post',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(post.postId ?? '');
                },
              ),
            ],
          ],
        );
      },
    );
  }

  void _showDeleteDialog(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePost(postId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      setState(() => _isLoading = true);

      final success = apiService
          .getResBodyJson(await apiService.deleteCommunityPost(userId, postId));

      if (_isResponseValid(success) && mounted) {
        // Remove from local list
        setState(() {
          _postResponse!.data.removeWhere((post) => post.postId == postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete post: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
