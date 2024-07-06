class UserModel {
  final String email;
  final String name;
  final bool isVerified;

  UserModel({
    required this.email,
    required this.name,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      isVerified: json['is_verified'],
    );
  }
}
