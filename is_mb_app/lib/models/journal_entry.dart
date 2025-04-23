import 'package:json_annotation/json_annotation.dart';

part 'journal_entry.g.dart';

@JsonSerializable(explicitToJson: true)
class JournalEntry {
  final String? entryId;
  final DateTime? createdAt;
  final String? sharedType; // 'friend', 'public', or 'private'
  final String? shareStatus;
  final bool? isEncrypted;
  final SharedWithUser? sharedWith;

  JournalEntry({
    this.entryId,
    this.createdAt,
    this.sharedType,
    this.shareStatus,
    this.isEncrypted,
    this.sharedWith,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);

  Map<String, dynamic> toJson() => _$JournalEntryToJson(this);
}

@JsonSerializable()
class SharedWithUser {
  final String? userId;
  final String? username;

  SharedWithUser({
    this.userId,
    this.username,
  });

  factory SharedWithUser.fromJson(Map<String, dynamic> json) =>
      _$SharedWithUserFromJson(json);

  Map<String, dynamic> toJson() => _$SharedWithUserToJson(this);
}
