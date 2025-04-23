import 'package:json_annotation/json_annotation.dart';

import 'journal_entry.dart';

part 'challenge.g.dart';

@JsonSerializable(explicitToJson: true)
class Challenge {
  @JsonKey(name: 'challengeId')
  final String? challengeId;
  final String? title;
  @JsonKey(name: 'completionDate')
  final DateTime? completionDate;
  @JsonKey(name: 'participantCount')
  String? participantCount;
  @JsonKey(name: 'journalEntries')
  List<JournalEntry>? journalEntries;

  Challenge({
    this.challengeId,
    this.title,
    this.completionDate,
    this.participantCount,
    this.journalEntries,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return _$ChallengeFromJson(json)
      ..journalEntries = (json['journalEntries'] as List<dynamic>?)
          ?.where((entry) => entry != null)
          .map((entry) => JournalEntry.fromJson(entry as Map<String, dynamic>))
          .toList();
  }
  Map<String, dynamic> toJson() => _$ChallengeToJson(this);
}
