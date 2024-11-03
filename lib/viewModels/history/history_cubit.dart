import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/models/score_model.dart';
import 'package:pixel_adventure/viewModels/history/history_state.dart';
import 'package:sqflite/sqflite.dart';

class HistoryCubit extends Cubit<HistoryState> {
  final Database _database = getIt<Database>();

  HistoryCubit() : super(HistoryInitial());

  void loadHistory() async {
    try {
      emit(HistoryLoading());
      final rawData = await _database.query(ScoresDbTable.tableName);
      final scores = rawData.map((e) => ScoreModel.fromJson(e)).toList();
      emit(HistoryLoaded(scores));
    } catch (e) {
      emit(const HistoryError("Có lỗi xảy ra khi tải lịch sử chơi."));
    }
  }
}
