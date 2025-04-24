// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_search_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserSearchResult _$UserSearchResultFromJson(Map<String, dynamic> json) =>
    UserSearchResult(
      userId: json['userId'] as String,
      username: json['username'] as String,
      memberSince: DateTime.parse(json['memberSince'] as String),
      engagementScore: (json['engagementScore'] as num).toDouble(),
      activityLevel: json['activityLevel'] as String,
    );

Map<String, dynamic> _$UserSearchResultToJson(UserSearchResult instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
      'memberSince': instance.memberSince.toIso8601String(),
      'engagementScore': instance.engagementScore,
      'activityLevel': instance.activityLevel,
    };
