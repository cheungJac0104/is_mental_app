import 'package:is_mb_app/models/user_search_result.dart';

import 'friendship.dart';
import 'pending_friend.dart';
import 'user.dart';

extension PendingFriendExtension on PendingFriendship {
  Friendship beFriend() {
    final newFriend =
        Friend(userId: requester.userId, username: requester.username);
    final newFriendship = Friendship(
        friendshipId: friendshipId,
        friend: newFriend,
        status: "accepted",
        createdAt: createdAt);

    return newFriendship;
  }
}

extension UserSearchListExtension on UserSearchResult {
  User toUser() => User(id: userId, username: username);
}
