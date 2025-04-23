// friendship is magic
import 'package:json_annotation/json_annotation.dart';

part 'friendship.g.dart';

@JsonSerializable(explicitToJson: true)
class Friendship {
  @JsonKey(name: 'friendshipId')
  final String friendshipId;
  final Friend friend;
  final String status;
  final String? mood; // Optional field
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  Friendship({
    required this.friendshipId,
    required this.friend,
    required this.status,
    this.mood,
    required this.createdAt,
  });

  factory Friendship.fromJson(Map<String, dynamic> json) =>
      _$FriendshipFromJson(json);
  Map<String, dynamic> toJson() => _$FriendshipToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Friend {
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;

  Friend({
    required this.userId,
    required this.username,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);
}
