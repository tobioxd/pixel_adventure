import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/models/score_model.dart';
import 'package:pixel_adventure/models/user_model.dart';
import 'package:pixel_adventure/viewModels/profile/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();
  final FirebaseAuth _firebaseAuth = getIt<FirebaseAuth>();
  final Database _database = getIt<Database>();

  ProfileCubit() : super(ProfileInitial());

  void changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (await NetWorkService.isConnected() == false) {
      emit(const ProfileError(message: "Không có kết nối mạng"));
      return;
    }
    if (_firebaseAuth.currentUser == null) {
      await _sharedPreferences.clear();
      emit(ProfileRequireLogin());
      return;
    }
    if (newPassword != confirmNewPassword) {
      emit(const ProfileError(message: "Mật khẩu mới không khớp"));
      return;
    }
    final user = _firebaseAuth.currentUser!;
    try {
      final email = user.email!;
      final credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);
      await user.reauthenticateWithCredential(credential);
      emit(ProfileChangePasswordSuccess());
    } on FirebaseException {
      emit(const ProfileError(message: "Mật khẩu cũ không chính xác"));
    } finally {
      await user.updatePassword(newPassword);
    }
  }

  void loadProfile() async {
    final userId = _sharedPreferences.getString(UserDbKey.idKey);
    final name = _sharedPreferences.getString(UserDbKey.nameKey);
    final email = _sharedPreferences.getString(UserDbKey.emailKey);
    final photoBase64 = _sharedPreferences.getString(UserDbKey.photoKey);
    final createdAt = _sharedPreferences.getString(UserDbKey.createdAtKey);

    final user = UserModel(
      id: userId!,
      name: name!,
      email: email!,
      photo: photoBase64!,
      createdAt: DateTime.parse(createdAt!),
    );

    emit(ProfileLoaded(userModel: user));
  }

  void updateProfile({required String name, File? photo}) async {
    if (await NetWorkService.isConnected() == false) {
      emit(const ProfileError(message: "Không có kết nối mạng"));
      return;
    }
    if (_firebaseAuth.currentUser == null) {
      await _sharedPreferences.clear();
      emit(ProfileRequireLogin());
      return;
    }
    String imageBase64 = 'null';
    if (photo != null) {
      final imageBytes = await photo.readAsBytes();
      imageBase64 = base64Encode(imageBytes);
    }
    try {
      await _firestore
          .collection(UserDbKey.collectionName)
          .doc(_firebaseAuth.currentUser!.uid)
          .update(imageBase64 != 'null'
              ? {
                  UserDbKey.nameKey: name,
                  UserDbKey.photoKey: imageBase64,
                }
              : {
                  UserDbKey.nameKey: name,
                });
      await _sharedPreferences.setString(UserDbKey.nameKey, name);
      if (imageBase64 != 'null') {
        await _sharedPreferences.setString(UserDbKey.photoKey, imageBase64);
      }
    } on FirebaseException {
      emit(const ProfileError(message: "Có lỗi xảy ra khi cập nhật thông tin"));
      return;
    }
    loadProfile();
  }

  void logout() async {
    try {
      if (await NetWorkService.isConnected() == false) {
        emit(const ProfileError(message: "Không có kết nối mạng"));
        return;
      }
      final localScores = await _database.query(
        ScoresDbTable.tableName,
        where: "${ScoresDbTable.userIdColumn} = ?",
        whereArgs: [_firebaseAuth.currentUser!.uid],
      );
      final scores = localScores.map((e) => ScoreModel.fromJson(e)).toList();
      for (final score in scores) {
        final scoreDoc = await _firestore
            .collection(ScoresDbTable.tableName)
            .doc(score.id)
            .get();
        if (!scoreDoc.exists) {
          await _firestore
              .collection(ScoresDbTable.tableName)
              .doc(score.id)
              .set({
            ScoresDbTable.characterColumn: score.character,
            ScoresDbTable.createdAtColumn: score.createdAt.toString(),
            ScoresDbTable.pointsColumn: score.points,
            ScoresDbTable.timeColumn: score.time.inSeconds,
            ScoresDbTable.userIdColumn: score.userId,
          });
        }
      }
      await _firebaseAuth.signOut();
      await _sharedPreferences.clear();
      await _database.delete(ScoresDbTable.tableName);
      emit(ProfileLogout());
    } catch (e) {
      emit(const ProfileError(message: "Có lỗi xảy ra khi đăng xuất"));
    }
  }
}
