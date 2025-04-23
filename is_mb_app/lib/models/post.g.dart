// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      postId: json['post_id'] as String?,
      content: json['content'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      privacyMode: json['privacy_mode'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      isLiked: json['is_liked'] as bool?,
      author: json['author'] == null
          ? null
          : Author.fromJson(json['author'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'post_id': instance.postId,
      'content': instance.content,
      'created_at': instance.createdAt?.toIso8601String(),
      'privacy_mode': instance.privacyMode,
      'like_count': instance.likeCount,
      'user_id': instance.userId,
      'is_liked': instance.isLiked,
      'author': instance.author?.toJson(),
    };

Author _$AuthorFromJson(Map<String, dynamic> json) => Author(
      userId: json['user_id'] as String?,
      username: json['username'] as String?,
    );

Map<String, dynamic> _$AuthorToJson(Author instance) => <String, dynamic>{
      'user_id': instance.userId,
      'username': instance.username,
    };
