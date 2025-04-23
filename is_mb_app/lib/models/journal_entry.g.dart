// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JournalEntry _$JournalEntryFromJson(Map<String, dynamic> json) => JournalEntry(
      entryId: json['entryId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      sharedType: json['sharedType'] as String?,
      shareStatus: json['shareStatus'] as String?,
      isEncrypted: json['isEncrypted'] as bool?,
      sharedWith: json['sharedWith'] == null
          ? null
          : SharedWithUser.fromJson(json['sharedWith'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JournalEntryToJson(JournalEntry instance) =>
    <String, dynamic>{
      'entryId': instance.entryId,
      'createdAt': instance.createdAt?.toIso8601String(),
      'sharedType': instance.sharedType,
      'shareStatus': instance.shareStatus,
      'isEncrypted': instance.isEncrypted,
      'sharedWith': instance.sharedWith?.toJson(),
    };

SharedWithUser _$SharedWithUserFromJson(Map<String, dynamic> json) =>
    SharedWithUser(
      userId: json['userId'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$SharedWithUserToJson(SharedWithUser instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'username': instance.username,
    };
