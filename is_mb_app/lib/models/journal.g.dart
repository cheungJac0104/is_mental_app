// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Journal _$JournalFromJson(Map<String, dynamic> json) => Journal(
      entryId: json['entryId'] as String,
      challengeId: json['challengeId'] as String,
      title: json['title'] as String,
      journalContent: json['journalContent'] as String,
      completionDate: DateTime.parse(json['completionDate'] as String),
      daysRemaining: (json['daysRemaining'] as num).toInt(),
      friendTag: json['journalFriendTag'] == null
          ? null
          : JournalFriendTag.fromJson(
              json['journalFriendTag'] as Map<String, dynamic>),
      journalProgress: (json['journalProgress'] as num?)?.toInt(),
    );

Map<String, dynamic> _$JournalToJson(Journal instance) => <String, dynamic>{
      'entryId': instance.entryId,
      'challengeId': instance.challengeId,
      'title': instance.title,
      'journalContent': instance.journalContent,
      'completionDate': instance.completionDate.toIso8601String(),
      'daysRemaining': instance.daysRemaining,
      'journalFriendTag': instance.friendTag?.toJson(),
      'journalProgress': instance.journalProgress,
    };

JournalFriendTag _$JournalFriendTagFromJson(Map<String, dynamic> json) =>
    JournalFriendTag(
      userId: json['userId'] as String,
      username: json['username'] as String,
    );

Map<String, dynamic> _$JournalFriendTagToJson(JournalFriendTag instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
    };
