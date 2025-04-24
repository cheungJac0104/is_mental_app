class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String bio;
  final String profilePhotoUrl;
  final String coverPhotoUrl;
  final int moodCount;
  final int followingCount;
  final int followerCount;

  const User({
    required this.id,
    required this.username,
    this.fullName = '',
    this.email = '',
    this.bio = '',
    this.profilePhotoUrl = '',
    this.coverPhotoUrl = '',
    this.moodCount = 0,
    this.followingCount = 0,
    this.followerCount = 0,
  });
}
