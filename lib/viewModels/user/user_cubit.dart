import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/models/user_model.dart';
import 'package:pixel_adventure/viewModels/user/user_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';

class UserCubit extends Cubit<UserState> {
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  final FirebaseAuth _firebaseAuth = getIt<FirebaseAuth>();
  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();

  UserCubit() : super(UserInitial());

  void loadUser() async {
    if (await NetWorkService.isConnected()) {
      final user = _firebaseAuth.currentUser;
      final userId = _sharedPreferences.getString(UserDbKey.idKey);
      if (user == null) {
        if (userId == null) {
          final data = await rootBundle.load(
            'assets/images/default_user_avatar/steve_avatar.jpg',
          );
          final imageBytes = data.buffer.asUint8List();
          String imageBase64 = base64Encode(imageBytes);
          emit(UserLoaded(
            user: UserModel(
              createdAt: DateTime.now(),
              email: 'null',
              id: 'null',
              name: 'Guest',
              photo: imageBase64,
            ),
          ));
        } else {
          final userDoc =
              await _firestore.collection('users').doc(userId).get();
          if (!userDoc.exists) {
            await _sharedPreferences.remove(UserDbKey.idKey);
            await _sharedPreferences.remove(UserDbKey.nameKey);
            await _sharedPreferences.remove(UserDbKey.emailKey);
            await _sharedPreferences.remove(UserDbKey.photoKey);
            await _sharedPreferences.remove(UserDbKey.createdAtKey);
            final data = await rootBundle.load(
              'assets/images/default_user_avatar/steve_avatar.jpg',
            );
            final imageBytes = data.buffer.asUint8List();
            String imageBase64 = base64Encode(imageBytes);
            emit(UserLoaded(
              user: UserModel(
                createdAt: DateTime.now(),
                email: 'null',
                id: 'null',
                name: 'Guest',
                photo: imageBase64,
              ),
            ));
          } else {
            final user = UserModel.fromJson({
              UserDbKey.idKey: userId,
              ...userDoc.data() as Map<String, dynamic>,
            });
            await _sharedPreferences.setString(UserDbKey.idKey, user.id);
            await _sharedPreferences.setString(UserDbKey.nameKey, user.name);
            await _sharedPreferences.setString(UserDbKey.emailKey, user.email);
            await _sharedPreferences.setString(UserDbKey.photoKey, user.photo);
            await _sharedPreferences.setString(
                UserDbKey.createdAtKey, user.createdAt.toString());
            emit(UserLoaded(user: user));
          }
        }
      } else {
        final userDoc = await _firestore
            .collection(UserDbKey.collectionName)
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _sharedPreferences.remove(UserDbKey.idKey);
          await _sharedPreferences.remove(UserDbKey.nameKey);
          await _sharedPreferences.remove(UserDbKey.emailKey);
          await _sharedPreferences.remove(UserDbKey.photoKey);
          await _sharedPreferences.remove(UserDbKey.createdAtKey);
          final data = await rootBundle.load(
            'assets/images/default_user_avatar/steve_avatar.jpg',
          );
          final imageBytes = data.buffer.asUint8List();
          String imageBase64 = base64Encode(imageBytes);
          emit(UserLoaded(
            user: UserModel(
              createdAt: DateTime.now(),
              email: 'null',
              id: 'null',
              name: 'Guest',
              photo: imageBase64,
            ),
          ));
        } else {
          final userData = userDoc.data() as Map<String, dynamic>;
          final userModel = UserModel.fromJson({
            UserDbKey.idKey: user.uid,
            ...userData,
          });
          await _sharedPreferences.setString(UserDbKey.idKey, userModel.id);
          await _sharedPreferences.setString(UserDbKey.nameKey, userModel.name);
          await _sharedPreferences.setString(
              UserDbKey.emailKey, userModel.email);
          await _sharedPreferences.setString(
              UserDbKey.photoKey, userModel.photo);
          await _sharedPreferences.setString(
              UserDbKey.createdAtKey, userModel.createdAt.toString());
          emit(UserLoaded(user: userModel));
        }
      }
    } else {
      final userId = _sharedPreferences.getString(UserDbKey.idKey);
      if (userId == null) {
        final data = await rootBundle.load(
          'assets/images/default_user_avatar/steve_avatar.jpg',
        );
        final imageBytes = data.buffer.asUint8List();
        String imageBase64 = base64Encode(imageBytes);
        emit(UserLoaded(
          user: UserModel(
            createdAt: DateTime.now(),
            email: 'null',
            id: 'null',
            name: 'Guest',
            photo: imageBase64,
          ),
        ));
      } else {
        final userName = _sharedPreferences.getString(UserDbKey.nameKey);
        final userPhoto = _sharedPreferences.getString(UserDbKey.photoKey);
        final userEmail = _sharedPreferences.getString(UserDbKey.emailKey);
        final createdAt = DateTime.parse(
            _sharedPreferences.getString(UserDbKey.createdAtKey)!);
        emit(UserLoaded(
          user: UserModel(
            id: userId,
            name: userName!,
            photo: userPhoto!,
            email: userEmail!,
            createdAt: createdAt,
          ),
        ));
      }
    }
  }
}
