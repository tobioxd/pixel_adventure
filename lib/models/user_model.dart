import 'package:pixel_adventure/cores/constants/user_db_key.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String photo;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.photo,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UserDbKey.idKey],
      name: json[UserDbKey.nameKey],
      email: json[UserDbKey.emailKey],
      photo: json[UserDbKey.photoKey],
      createdAt: DateTime.parse(json[UserDbKey.createdAtKey]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      UserDbKey.idKey: id,
      UserDbKey.nameKey: name,
      UserDbKey.emailKey: email,
      UserDbKey.photoKey: photo,
      UserDbKey.createdAtKey: createdAt.toString(),
    };
  }
}
