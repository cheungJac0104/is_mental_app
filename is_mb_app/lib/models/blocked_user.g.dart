// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlockedRelationship _$BlockedRelationshipFromJson(Map<String, dynamic> json) =>
    BlockedRelationship(
      friendshipId: json['friendshipId'] as String,
      blockedUser:
          BlockedUser.fromJson(json['blockedUser'] as Map<String, dynamic>),
      blockedBy: json['blockedBy'] as String,
      blockedAt: DateTime.parse(json['blockedAt'] as String),
    );

Map<String, dynamic> _$BlockedRelationshipToJson(
        BlockedRelationship instance) =>
    <String, dynamic>{
      'friendshipId': instance.friendshipId,
      'blockedUser': instance.blockedUser.toJson(),
      'blockedBy': instance.blockedBy,
      'blockedAt': instance.blockedAt.toIso8601String(),
    };

BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) => BlockedUser(
      userId: json['user_id'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$BlockedUserToJson(BlockedUser instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
    };
