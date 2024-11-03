import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/models/user_model.dart';
import 'package:pixel_adventure/viewModels/register/register_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final FirebaseAuth _firebaseAuth = getIt<FirebaseAuth>();
  final FirebaseFirestore _firebaseFirestore = getIt<FirebaseFirestore>();
  final SharedPreferences _sharePreference = getIt<SharedPreferences>();
  static const int kMaxImageSize = 512 * 1024;

  RegisterCubit() : super(RegisterInitial());

  void register({
    required String email,
    required String password,
    required String confirmPassword,
    required String name,
    File? image,
  }) async {
    if (password != confirmPassword) {
      emit(const RegisterFailed("Mật khẩu không trùng khớp"));
      return;
    }
    String imageBase64 = "";
    if (image != null) {
      if (image.lengthSync() > kMaxImageSize) {
        emit(const RegisterFailed("Kích thước ảnh quá lớn"));
        return;
      }
      List<int> imageBytes = await image.readAsBytes();
      imageBase64 = base64Encode(imageBytes);
    } else {
      final data = await rootBundle.load(
        'assets/images/default_user_avatar/steve_avatar.jpg',
      );
      final imageBytes = data.buffer.asUint8List();
      imageBase64 = base64Encode(imageBytes);
    }
    try {
      emit(RegisterLoading());
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final id = userCredential.user!.uid;
      final createdAt = DateTime.now();
      await _firebaseFirestore
          .collection(UserDbKey.collectionName)
          .doc(id)
          .set({
        UserDbKey.nameKey: name,
        UserDbKey.emailKey: email,
        UserDbKey.photoKey: imageBase64,
        UserDbKey.createdAtKey: createdAt.toString(),
      });
      await _sharePreference.setString(UserDbKey.idKey, id);
      await _sharePreference.setString(UserDbKey.nameKey, name);
      await _sharePreference.setString(UserDbKey.emailKey, email);
      await _sharePreference.setString(UserDbKey.photoKey, imageBase64);
      await _sharePreference.setString(
          UserDbKey.createdAtKey, createdAt.toString());
      emit(RegisterSuccessfully(
        userModel: UserModel(
          id: id,
          name: name,
          email: email,
          photo: imageBase64,
          createdAt: createdAt,
        ),
      ));
    } on FirebaseAuthException {
      emit(const RegisterFailed("Có lỗi xảy ra khi đăng ký tài khoản"));
    }
  }
}
