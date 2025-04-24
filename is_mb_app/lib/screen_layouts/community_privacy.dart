import 'package:flutter/material.dart';

import '../api_routes/api_service.dart';
import '../models/blocked_user.dart';

class PrivacySettingPage extends StatefulWidget {
  final String userId;
  final ApiService apiService;
  final List<BlockedRelationship> blockedFriends;
  final String privacy; // Added privacy parameter

  const PrivacySettingPage({
    super.key,
    required this.blockedFriends,
    required this.userId,
    required this.apiService,
    required this.privacy, // Added to constructor
  });

  @override
  State<PrivacySettingPage> createState() => _PrivacySettingPageState();
}

class _PrivacySettingPageState extends State<PrivacySettingPage> {
  late String _currentPrivacy;
  late bool _allowFriendRequests;
  late bool _showActivityStatus;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize with widget.privacy
    _currentPrivacy = widget.privacy;
    _allowFriendRequests = true; // Default values, load from API if needed
    _showActivityStatus = true;
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    try {
      await widget.apiService.updatePrivacySetting(_currentPrivacy);
      setState(() {
        _hasChanges = false;
        _isLoading = false;
      });
      _showSnackbar('Settings saved successfully', isError: false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackbar('Failed to save: ${e.toString()}');
    }
  }

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveSettings,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('SAVE', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: _isLoading && !_hasChanges
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Privacy Mode Selection
                ListTile(
                  title: const Text('Post Visibility'),
                  trailing: DropdownButton<String>(
                    value: _currentPrivacy,
                    items: const {
                      'Public': 'public',
                      'Friends': 'friends',
                      'Only me': 'private'
                    }
                        .entries
                        .map((entry) => DropdownMenuItem<String>(
                              value: entry
                                  .value, // This will be 'public', 'friends', or 'private'
                              child: Text(entry
                                  .key), // This will be 'Public', 'Friends', or 'Only me'
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && value != _currentPrivacy) {
                        setState(() {
                          _currentPrivacy = value;
                          _hasChanges = true;
                        });
                      }
                    },
                  ),
                ),
                const Divider(),

                // Friend Requests
                SwitchListTile(
                  title: const Text('Allow Friend Requests'),
                  value: _allowFriendRequests,
                  onChanged: (value) {
                    setState(() {
                      _allowFriendRequests = value;
                      _hasChanges = true;
                    });
                  },
                ),
                const Divider(),

                // Activity Status
                SwitchListTile(
                  title: const Text('Show Activity Status'),
                  value: _showActivityStatus,
                  onChanged: (value) {
                    setState(() {
                      _showActivityStatus = value;
                      _hasChanges = true;
                    });
                  },
                ),
                const Divider(),

                // Blocked Users
                ListTile(
                  title: const Text('Blocked Users'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.blockedFriends.isNotEmpty)
                        Text('${widget.blockedFriends.length}'),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _navigateToBlockedUsers(),
                ),
              ],
            ),
    );
  }

  void _navigateToBlockedUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlockedUsersScreen(
          blockedUsers: widget.blockedFriends,
          onUnblock: (unblockedId, friendshipId) async {
            await widget.apiService
                .updateFriendStatus(friendshipId, unblockedId, "accepted");
            setState(() {
              widget.blockedFriends.removeWhere(
                  (user) => user.blockedUser.userId == unblockedId);
            });
          },
        ),
      ),
    );
  }
}

// Example blocked users screen
class BlockedUsersScreen extends StatelessWidget {
  final List<BlockedRelationship> blockedUsers;
  final Function(String, String) onUnblock;

  const BlockedUsersScreen({
    super.key,
    required this.blockedUsers,
    required this.onUnblock,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: ListView.builder(
        itemCount: blockedUsers.length,
        itemBuilder: (context, index) {
          final user = blockedUsers[index];
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(user.blockedUser.username),
            trailing: TextButton(
              onPressed: () => _confirmUnblock(
                  context, user.blockedUser.userId, user.friendshipId),
              child: const Text('Unblock', style: TextStyle(color: Colors.red)),
            ),
          );
        },
      ),
    );
  }

  void _confirmUnblock(
      BuildContext context, String userId, String friendshipId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: const Text('Are you sure you want to unblock this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onUnblock(userId, friendshipId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User unblocked successfully')),
              );
            },
            child: const Text('Unblock', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
