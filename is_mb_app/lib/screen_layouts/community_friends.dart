import 'package:flutter/material.dart';
import 'package:is_mb_app/models/friend_extension.dart';
import 'package:is_mb_app/models/friendship.dart';
import 'package:is_mb_app/models/pending_friend.dart';
import 'package:is_mb_app/models/user.dart';
import '../api_routes/api_service.dart';
import '../models/api_response.dart';
import 'friend_full_screen.dart';
import 'tailwind.dart';

class CommunityFriends extends StatefulWidget {
  final List<Friendship> friends;
  final List<PendingFriendship> pendingFriends;
  final String userId;
  final ApiService apiService;

  const CommunityFriends({
    super.key,
    required this.friends,
    required this.pendingFriends,
    required this.userId,
    required this.apiService,
  });

  @override
  State<CommunityFriends> createState() => _CommunityFriendsState();
}

class _CommunityFriendsState extends State<CommunityFriends> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isLoadingSearch = true;
      _isSearching = true;
    });

    try {
      final results =
          await widget.apiService.searchUsersToAdd(widget.userId, query);

      final response = widget.apiService.getResBodyJson(results);

      final searchResponse = SearchListResponse.fromJson(response);

      if (!mounted) return;
      setState(() {
        _searchResults = searchResponse.data.map((e) => e.toUser()).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingSearch = false);
      }
    }
  }

  Future<void> _sendFriendRequest(String userId) async {
    try {
      await widget.apiService.addFriend(widget.userId, userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Friends',
                style: TwTextStyles.body(context).copyWith(
                  fontFamily: 'Pacifico',
                  color: TwColors.text(context),
                ),
              ),
              TextButton(
                onPressed: () => _showAllFriends(context),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSearchField(),
          const SizedBox(height: 8),
          if (_isSearching) _buildSearchResults(),
          if (!_isSearching) _buildFriendsList(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search for friends...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  _searchUsers('');
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: _searchUsers,
    );
  }

  Widget _buildSearchResults() {
    if (_isLoadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults.isEmpty) {
      return const Center(child: Text('No users found'));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final user = _searchResults[index];
          final isAlreadyFriend = widget.friends
              .any((friendship) => friendship.friend.userId == user.id);
          final hasPendingRequest = widget.pendingFriends
              .any((friendship) => friendship.requester.userId == user.id);

          return ListTile(
            leading: CircleAvatar(
              child: Text(user.username[0].toUpperCase()),
            ),
            title: Text(user.username),
            trailing: isAlreadyFriend
                ? const Text('Already friends',
                    style: TextStyle(color: Colors.grey))
                : hasPendingRequest
                    ? const Text('Request sent',
                        style: TextStyle(color: Colors.grey))
                    : TextButton(
                        child: const Text('Add Friend'),
                        onPressed: () => _sendFriendRequest(user.id),
                      ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.friends.length,
        itemBuilder: (context, index) {
          return FriendItem(
            friend: widget.friends[index],
            onPressed: () => _viewFriendProfile(widget.friends[index], context),
          );
        },
      ),
    );
  }

  void _showAllFriends(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FriendsFullScreen(
          friends: widget.friends,
          pendingFriends: widget.pendingFriends,
          userId: widget.userId,
          apiService: widget.apiService,
        );
      },
    );
  }

  void _viewFriendProfile(Friendship friend, BuildContext context) {
    // TODO: Implement friend profile navigation
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(friend.friend.username)),
          body: Center(child: Text('Profile of ${friend.friend.username}')),
        ),
      ),
    );
  }
}

class FriendItem extends StatelessWidget {
  final Friendship friend;
  final VoidCallback onPressed;

  const FriendItem({
    super.key,
    required this.friend,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(255, 251, 207, 187),
                  child: Icon(Icons.face, size: 45),
                ),
                if (friend.mood != null && friend.mood!.isNotEmpty)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              friend.friend.username,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (friend.mood != null && friend.mood!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  friend.mood!,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: Colors.grey[800],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
