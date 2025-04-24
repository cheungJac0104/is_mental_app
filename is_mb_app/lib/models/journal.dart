import 'package:json_annotation/json_annotation.dart';

part 'journal.g.dart';

@JsonSerializable(explicitToJson: true)
class Journal {
  @JsonKey(name: 'entryId')
  final String entryId;

  @JsonKey(name: 'challengeId')
  final String challengeId;

  final String title;
  final String journalContent;

  @JsonKey(name: 'completionDate')
  final DateTime completionDate;

  @JsonKey(name: 'daysRemaining')
  final int daysRemaining;

  @JsonKey(name: 'journalFriendTag')
  final JournalFriendTag? friendTag;

  @JsonKey(name: 'journalProgress')
  final int? journalProgress;

  Journal({
    required this.entryId,
    required this.challengeId,
    required this.title,
    required this.journalContent,
    required this.completionDate,
    required this.daysRemaining,
    this.friendTag,
    required this.journalProgress,
  });

  factory Journal.fromJson(Map<String, dynamic> json) =>
      _$JournalFromJson(json);
  Map<String, dynamic> toJson() => _$JournalToJson(this);
}

@JsonSerializable()
class JournalFriendTag {
  @JsonKey(name: 'userId')
  final String userId;

  final String username;

  JournalFriendTag({
    required this.userId,
    required this.username,
  });

  factory JournalFriendTag.fromJson(Map<String, dynamic> json) =>
      _$JournalFriendTagFromJson(json);
  Map<String, dynamic> toJson() => _$JournalFriendTagToJson(this);
}
