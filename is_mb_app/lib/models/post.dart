import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable(explicitToJson: true)
class Post {
  @JsonKey(name: 'post_id')
  final String? postId;
  final String? content;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'privacy_mode')
  final String? privacyMode;
  @JsonKey(name: 'like_count')
  final int? likeCount;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'is_liked')
  final bool? isLiked;
  final Author? author;

  Post({
    this.postId,
    this.content,
    this.createdAt,
    this.privacyMode,
    this.likeCount,
    this.userId,
    this.isLiked,
    this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Author {
  @JsonKey(name: 'user_id')
  final String? userId;
  final String? username;

  Author({
    this.userId,
    this.username,
  });

  factory Author.fromJson(Map<String, dynamic> json) => _$AuthorFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorToJson(this);
}
