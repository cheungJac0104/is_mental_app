import 'package:flutter/material.dart';
import 'package:is_mb_app/models/friend_extension.dart';

import '../api_routes/api_service.dart';
import '../models/friendship.dart';
import '../models/pending_friend.dart';
import 'tailwind.dart';

class FriendsFullScreen extends StatefulWidget {
  final List<Friendship> friends;
  final List<PendingFriendship> pendingFriends;
  final String userId;
  final ApiService apiService;

  const FriendsFullScreen({
    super.key,
    required this.friends,
    required this.pendingFriends,
    required this.userId,
    required this.apiService,
  });

  @override
  State<FriendsFullScreen> createState() => _FriendsFullScreenState();
}

class _FriendsFullScreenState extends State<FriendsFullScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Friendship> _filteredFriends = [];
  List<PendingFriendship> _filteredPending = [];
  bool _friendsExpanded = true;
  bool _pendingExpanded = false;

  @override
  void initState() {
    super.initState();
    _filteredFriends = widget.friends;
    _filteredPending = widget.pendingFriends;
    _searchController.addListener(_filterFriends);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = widget.friends
          .where(
              (friend) => friend.friend.username.toLowerCase().contains(query))
          .toList();
      _filteredPending = widget.pendingFriends
          .where((friend) =>
              friend.requester.username.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        children: [
          Text(
            'Friends',
            style: TwTextStyles.heading1(context),
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFriendsSection(),
                  const SizedBox(height: 16),
                  _buildPendingSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search friends...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Widget _buildFriendsSection() {
    return Card(
      child: ExpansionTile(
        title: Text(
          'Your Friends (${_filteredFriends.length})',
          style: TwTextStyles.body(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: _friendsExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _friendsExpanded = expanded);
        },
        children: [
          if (_filteredFriends.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No friends found',
                style: TwTextStyles.body(context),
              ),
            )
          else
            ..._filteredFriends.map((friend) => _buildFriendListItem(friend)),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    return Card(
      child: ExpansionTile(
        title: Text(
          'Pending Requests (${_filteredPending.length})',
          style: TwTextStyles.body(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        initiallyExpanded: _pendingExpanded,
        onExpansionChanged: (expanded) {
          setState(() => _pendingExpanded = expanded);
        },
        children: [
          if (_filteredPending.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No pending requests',
                style: TwTextStyles.body(context),
              ),
            )
          else
            ..._filteredPending
                .map((friend) => _buildPendingFriendListItem(friend)),
        ],
      ),
    );
  }

  Widget _buildFriendListItem(Friendship friend) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(friend.friend.username[0].toUpperCase()),
      ),
      title: Text(friend.friend.username),
      subtitle: friend.mood != null ? Text(friend.mood!) : null,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showFriendOptions(friend),
      ),
      onTap: () => _viewFriendProfile(friend),
    );
  }

  Widget _buildPendingFriendListItem(PendingFriendship friend) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(friend.requester.username[0].toUpperCase()),
      ),
      title: Text(friend.requester.username),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => _respondToRequest(friend, true),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => _respondToRequest(friend, false),
          ),
        ],
      ),
    );
  }

  void _viewFriendProfile(Friendship friend) {
    Navigator.pop(context);
    // TODO: Implement proper navigation to friend profile
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(friend.friend.username)),
          body: Center(child: Text('Profile of ${friend.friend.username}')),
        ),
      ),
    );
  }

  void _showFriendOptions(Friendship friend) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Send Message'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement message functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title:
                  const Text('Block User', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _blockFriend(friend);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.orange),
              title: const Text('Remove Friend',
                  style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                _removeFriend(friend);
              },
            ),
          ],
        );
      },
    );
  }

  void _respondToRequest(PendingFriendship friend, bool accept) async {
    accept
        ? await widget.apiService
            .updateFriendStatus(friend.friendshipId, widget.userId, "accepted")
        : await widget.apiService
            .deleteFriend(friend.friendshipId, widget.userId);

    setState(() {
      widget.pendingFriends.remove(friend);
      if (accept) widget.friends.add(friend.beFriend());
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(accept ? 'Request accepted' : 'Request declined')),
    );
  }

  void _blockFriend(Friendship friend) async {
    await widget.apiService
        .updateFriendStatus(friend.friendshipId, widget.userId, "blocked");
    setState(() {
      widget.friends.remove(friend);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blocked ${friend.friend.username}')),
    );
  }

  void _removeFriend(Friendship friend) async {
    await widget.apiService.deleteFriend(friend.friendshipId, widget.userId);
    setState(() {
      widget.friends.remove(friend);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed ${friend.friend.username}')),
    );
  }
}
