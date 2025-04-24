import 'package:flutter/material.dart';
import '../models/friendship.dart';

class FriendDropdownSheet extends StatefulWidget {
  final List<Friendship> friends;

  const FriendDropdownSheet({
    super.key,
    required this.friends,
  });

  @override
  State<FriendDropdownSheet> createState() => _FriendDropdownSheetState();
}

class _FriendDropdownSheetState extends State<FriendDropdownSheet> {
  String? _selectedFriendId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share with Friend',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedFriendId,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                hint: const Text('Select a friend'),
                items: widget.friends.map((friend) {
                  return DropdownMenuItem<String>(
                    value: friend.friend.userId,
                    child: Text(
                      friend.friend.username,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedFriendId = value),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _selectedFriendId == null
                    ? null
                    : () {
                        final selected = widget.friends.firstWhere(
                          (f) => f.friend.userId == _selectedFriendId,
                        );
                        Navigator.pop(context, selected);
                      },
                child: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage example:
