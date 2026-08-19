class User {  // users data
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });
}
// profile for users
class UserProfile {
  final String userId;
  final String displayName;
  final String? profileImage;

  UserProfile({
    required this.userId,
    required this.displayName,
    this.profileImage,
  });
}