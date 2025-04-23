// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Friendship _$FriendshipFromJson(Map<String, dynamic> json) => Friendship(
      friendshipId: json['friendshipId'] as String,
      friend: Friend.fromJson(json['friend'] as Map<String, dynamic>),
      status: json['status'] as String,
      mood: json['mood'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$FriendshipToJson(Friendship instance) =>
    <String, dynamic>{
      'friendshipId': instance.friendshipId,
      'friend': instance.friend.toJson(),
      'status': instance.status,
      'mood': instance.mood,
      'createdAt': instance.createdAt.toIso8601String(),
    };

Friend _$FriendFromJson(Map<String, dynamic> json) => Friend(
      userId: json['user_id'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$FriendToJson(Friend instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
    };
