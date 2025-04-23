import 'package:json_annotation/json_annotation.dart';

part 'blocked_user.g.dart';

@JsonSerializable(explicitToJson: true)
class BlockedRelationship {
  @JsonKey(name: 'friendshipId')
  final String friendshipId;
  @JsonKey(name: 'blockedUser')
  final BlockedUser blockedUser;
  @JsonKey(name: 'blockedBy')
  final String blockedBy; // 'you' or 'them'
  @JsonKey(name: 'blockedAt')
  final DateTime blockedAt;

  BlockedRelationship({
    required this.friendshipId,
    required this.blockedUser,
    required this.blockedBy,
    required this.blockedAt,
  });

  factory BlockedRelationship.fromJson(Map<String, dynamic> json) =>
      _$BlockedRelationshipFromJson(json);

  Map<String, dynamic> toJson() => _$BlockedRelationshipToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BlockedUser {
  @JsonKey(name: 'user_id')
  final String userId;
  final String username;

  BlockedUser({
    required this.userId,
    required this.username,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserFromJson(json);

  Map<String, dynamic> toJson() => _$BlockedUserToJson(this);
}
