import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/models/user_model.dart';
import 'package:pixel_adventure/viewModels/login/login_state.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class LoginCubit extends Cubit<LoginState> {
  final FirebaseAuth _auth = getIt<FirebaseAuth>();
  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  final Database _database = getIt<Database>();

  LoginCubit() : super(LoginInitial());

  void login({required String email, required String password}) async {
    if (await NetWorkService.isConnected() == false) {
      emit(const LoginFailure(message: "Không có kết nối mạng"));
      return;
    }
    emit(LoginLoading());
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result.user == null) {
        emit(const LoginFailure(message: "Tài hoặc mật khẩu không chính xác"));
        return;
      }
      final userId = result.user!.uid;
      final userDoc = await _firestore
          .collection(UserDbKey.collectionName)
          .doc(userId)
          .get();
      if (!userDoc.exists) {
        emit(const LoginFailure(message: "Tài khoản không tồn tại"));
        return;
      }
      final user = UserModel.fromJson({
        ...userDoc.data() as Map<String, dynamic>,
        UserDbKey.idKey: userId,
      });
      await _sharedPreferences.setString(UserDbKey.idKey, user.id);
      await _sharedPreferences.setString(UserDbKey.emailKey, user.email);
      await _sharedPreferences.setString(UserDbKey.nameKey, user.name);
      await _sharedPreferences.setString(UserDbKey.photoKey, user.photo);
      await _sharedPreferences.setString(
          UserDbKey.createdAtKey, user.createdAt.toString());
      await _database.delete(ScoresDbTable.tableName);
      final cloudScores = await _firestore
          .collection(ScoresDbTable.tableName)
          .where(ScoresDbTable.userIdColumn, isEqualTo: userId)
          .get();
      for (var score in cloudScores.docs) {
        await _database.insert(
          ScoresDbTable.tableName,
          {
            ...score.data(),
            ScoresDbTable.idColumn: score.id,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      emit(LoginSuccess());
    } on FirebaseAuthException {
      emit(const LoginFailure(message: "Tài hoặc mật khẩu không chính xác"));
    }
  }
}
