class UserModel {
  final String userId;
  final String username;
  final String email;
  final String? profilePicture;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    this.profilePicture,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePicture: json['profile_picture'] as String?,
      role: (json['role'] as String?) ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }
}
