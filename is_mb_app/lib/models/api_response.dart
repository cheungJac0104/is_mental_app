import 'package:json_annotation/json_annotation.dart';

import 'blocked_user.dart';
import 'challenge.dart';
import 'journal.dart';
import 'pending_friend.dart';
import 'post.dart';
import 'friendship.dart';
import 'user_search_result.dart';

part 'api_response.g.dart';

@JsonSerializable(explicitToJson: true)
class PostResponse {
  final bool success;
  final int count;
  final List<Post> data;
  final Pagination pagination;

  PostResponse({
    required this.success,
    required this.count,
    required this.data,
    required this.pagination,
  });

  factory PostResponse.fromJson(Map<String, dynamic> json) =>
      _$PostResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PostResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ChallengeResponse {
  final bool success;
  final int count;
  final List<Challenge> data;
  final Pagination pagination;

  ChallengeResponse({
    required this.success,
    required this.count,
    required this.data,
    required this.pagination,
  });

  factory ChallengeResponse.fromJson(Map<String, dynamic> json) =>
      _$ChallengeResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ChallengeResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FriendResponse {
  final bool success;
  final int count;
  final List<Friendship> data;

  FriendResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory FriendResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FriendResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PendingFriendResponse {
  final bool success;
  final int count;
  final List<PendingFriendship> data;

  PendingFriendResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory PendingFriendResponse.fromJson(Map<String, dynamic> json) =>
      _$PendingFriendResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PendingFriendResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BlockedListResponse {
  final bool success;
  final int count;
  final List<BlockedRelationship> data;

  BlockedListResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory BlockedListResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockedListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlockedListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SearchListResponse {
  final bool success;
  final int count;
  final List<UserSearchResult> data;
  final Pagination pagination;

  SearchListResponse(
      {required this.success,
      required this.count,
      required this.data,
      required this.pagination});

  factory SearchListResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SearchListResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JournalResponse {
  final bool success;
  final Journal data;

  JournalResponse({
    required this.success,
    required this.data,
  });

  factory JournalResponse.fromJson(Map<String, dynamic> json) {
    return JournalResponse(
      success: json['success'] as bool,
      data: Journal.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => _$JournalResponseToJson(this);
}

@JsonSerializable()
class Pagination {
  final int limit;
  final int offset;
  final int? nextOffset;

  Pagination({
    required this.limit,
    required this.offset,
    this.nextOffset,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);
}
