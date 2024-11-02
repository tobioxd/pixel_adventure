class UserModel {
  final String id;
  final String name;
  final String email;
  final String photoUrl;
  final String createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.createdAt,
  });
}
