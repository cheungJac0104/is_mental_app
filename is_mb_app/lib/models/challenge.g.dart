// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Challenge _$ChallengeFromJson(Map<String, dynamic> json) => Challenge(
      challengeId: json['challengeId'] as String?,
      title: json['title'] as String?,
      completionDate: json['completionDate'] == null
          ? null
          : DateTime.parse(json['completionDate'] as String),
      participantCount: json['participantCount'] as String?,
      journalEntries: (json['journalEntries'] as List<dynamic>?)
          ?.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChallengeToJson(Challenge instance) => <String, dynamic>{
      'challengeId': instance.challengeId,
      'title': instance.title,
      'completionDate': instance.completionDate?.toIso8601String(),
      'participantCount': instance.participantCount,
      'journalEntries':
          instance.journalEntries?.map((e) => e.toJson()).toList(),
    };
