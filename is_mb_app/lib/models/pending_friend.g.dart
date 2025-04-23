// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_friend.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingFriendship _$PendingFriendshipFromJson(Map<String, dynamic> json) =>
    PendingFriendship(
      friendshipId: json['friendshipId'] as String,
      requester:
          PendingFriend.fromJson(json['requester'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PendingFriendshipToJson(PendingFriendship instance) =>
    <String, dynamic>{
      'friendshipId': instance.friendshipId,
      'requester': instance.requester.toJson(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

PendingFriend _$PendingFriendFromJson(Map<String, dynamic> json) =>
    PendingFriend(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PendingFriendToJson(PendingFriend instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
      'created_at': instance.createdAt.toIso8601String(),
    };
