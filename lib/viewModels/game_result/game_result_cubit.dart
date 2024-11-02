import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/viewModels/game_result/game_result_state.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class GameResultCubit extends Cubit<GameResultState> {
  final Database _database = getIt<Database>();
  final FirebaseAuth _auth = getIt<FirebaseAuth>();

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
      String userId =
          _auth.currentUser == null ? 'null' : _auth.currentUser!.uid;
      String id = const Uuid().v4().toString();
      final result = await _database.insert(ScoresDbTable.tableName, {
        ScoresDbTable.idColumn: id,
        ScoresDbTable.userIdColumn: userId,
        ScoresDbTable.pointsColumn: points,
        ScoresDbTable.timeColumn: time,
        ScoresDbTable.createdAtColumn: DateTime.now().toString(),
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
