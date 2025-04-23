import 'package:json_annotation/json_annotation.dart';

part 'pending_friend.g.dart';

@JsonSerializable(explicitToJson: true)
class PendingFriendship {
  @JsonKey(name: 'friendshipId')
  final String friendshipId;
  final PendingFriend requester;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  PendingFriendship({
    required this.friendshipId,
    required this.requester,
    required this.createdAt,
  });

  factory PendingFriendship.fromJson(Map<String, dynamic> json) =>
      _$PendingFriendshipFromJson(json);

  Map<String, dynamic> toJson() => _$PendingFriendshipToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PendingFriend {
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  PendingFriend({
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory PendingFriend.fromJson(Map<String, dynamic> json) =>
      _$PendingFriendFromJson(json);

  Map<String, dynamic> toJson() => _$PendingFriendToJson(this);
}
