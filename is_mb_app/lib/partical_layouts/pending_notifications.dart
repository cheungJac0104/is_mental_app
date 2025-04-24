import 'package:flutter/material.dart';

import '../models/pending_friend.dart';
import 'notification_badge.dart';

class PendingNotifications extends StatelessWidget {
  final List<PendingFriendship> pendingFriends;
  final Function(PendingFriendship, bool) onRespondToRequest;

  const PendingNotifications({
    super.key,
    required this.pendingFriends,
    required this.onRespondToRequest,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      count: pendingFriends.length,
      onPressed: () => _showPendingNotifications(context),
      icon: const Icon(Icons.notifications),
    );
  }

  void _showPendingNotifications(BuildContext context) {
    if (pendingFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending notifications')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _PendingNotificationsList(
          pendingFriends: pendingFriends,
          onRespondToRequest: onRespondToRequest,
        );
      },
    );
  }
}

class _PendingNotificationsList extends StatelessWidget {
  final List<PendingFriendship> pendingFriends;
  final Function(PendingFriendship, bool) onRespondToRequest;

  const _PendingNotificationsList({
    required this.pendingFriends,
    required this.onRespondToRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Text(
            'Pending Requests',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: pendingFriends.length,
              itemBuilder: (context, index) {
                final friend = pendingFriends[index];
                return _PendingNotificationItem(
                  friend: friend,
                  onRespond: onRespondToRequest,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingNotificationItem extends StatelessWidget {
  final PendingFriendship friend;
  final Function(PendingFriendship, bool) onRespond;

  const _PendingNotificationItem({
    required this.friend,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(friend.requester.username[0].toUpperCase()),
        ),
        title: Text(friend.requester.username),
        subtitle: const Text('Wants to be your friend'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => onRespond(friend, true),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => onRespond(friend, false),
            ),
          ],
        ),
      ),
    );
  }
}
