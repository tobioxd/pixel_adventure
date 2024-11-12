import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';
import 'package:pixel_adventure/viewModels/game_result/game_result_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class GameResultCubit extends Cubit<GameResultState> {
  final Database _database = getIt<Database>();
  final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  final FirebaseFirestore _firebaseFirestore = getIt<FirebaseFirestore>();

  GameResultCubit() : super(GameResultInitial());

  void saveResultToDevice({
    required int time,
    required String character,
    required int points,
  }) async {
    try {
      log(character);
      log(points.toString());
      log(time.toString());
      final idSaved = _sharedPreferences.getString(UserDbKey.idKey) ?? 'null';
      final userId = idSaved == 'null' ? 'null' : idSaved;
      String id = const Uuid().v4().toString();
      final current = DateTime.now().toString();
      if (await NetWorkService.isConnected() && userId != 'null') {
        await _firebaseFirestore.collection(ScoresDbTable.tableName).add({
          ScoresDbTable.idColumn: id,
          ScoresDbTable.userIdColumn: userId,
          ScoresDbTable.pointsColumn: points,
          ScoresDbTable.timeColumn: time,
          ScoresDbTable.createdAtColumn: current,
          ScoresDbTable.characterColumn: character,
        });
      }
      final result = await _database.insert(ScoresDbTable.tableName, {
        ScoresDbTable.idColumn: id,
        ScoresDbTable.userIdColumn: userId,
        ScoresDbTable.pointsColumn: points,
        ScoresDbTable.timeColumn: time,
        ScoresDbTable.createdAtColumn: current,
        ScoresDbTable.characterColumn: character,
      });
      emit(result > 0
          ? GameResultSuccess()
          : const GameResultFailure('Có lỗi xảy ra khi lưu kết quả'));
    } catch (e) {
      emit(const GameResultFailure('Có lỗi xảy ra khi lưu kết quả'));
    }
  }
}
