import 'package:json_annotation/json_annotation.dart';

part 'user_search_result.g.dart';

@JsonSerializable(explicitToJson: true)
class UserSearchResult {
  @JsonKey(name: 'userId')
  final String userId;
  final String username;
  @JsonKey(name: 'memberSince')
  final DateTime memberSince;
  @JsonKey(name: 'engagementScore')
  final double engagementScore;
  @JsonKey(name: 'activityLevel')
  final String activityLevel;

  UserSearchResult({
    required this.userId,
    required this.username,
    required this.memberSince,
    required this.engagementScore,
    required this.activityLevel,
  });

  factory UserSearchResult.fromJson(Map<String, dynamic> json) => 
      _$UserSearchResultFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserSearchResultToJson(this);
}