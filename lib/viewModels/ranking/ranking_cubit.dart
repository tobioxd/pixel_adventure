import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';
import 'package:pixel_adventure/models/ranking_model.dart';
import 'package:pixel_adventure/viewModels/ranking/ranking_state.dart';

class RankingCubit extends Cubit<RankingState> {
  final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();

  RankingCubit() : super(RankingInitial());

  void loadRanking() async {
    emit(RankingLoading());
    if (await NetWorkService.isConnected() == false) {
      emit(const RankingFailed(message: "Không có kết nối mạng"));
      return;
    }
    try {
      List<RankingModel> rankings = [];
      final userDocs =
          await _firestore.collection(UserDbKey.collectionName).get();
      for (final userDocs in userDocs.docs) {
        final userId = userDocs.id;
        final userName = userDocs.get(UserDbKey.nameKey);
        final userScores = await _firestore
            .collection(ScoresDbTable.tableName)
            .where(ScoresDbTable.userIdColumn, isEqualTo: userId)
            .get();
        final totalPlayed = userScores.docs.length;
        double totalPoint = 0;
        double totalTime = 0;
        for (final userScore in userScores.docs) {
          final point = userScore.get(ScoresDbTable.pointsColumn);
          final time = userScore.get(ScoresDbTable.timeColumn);
          totalPoint += point as int;
          totalTime += time as int;
        }
        rankings.add(RankingModel(
          userId: userId,
          userName: userName,
          totalPlayed: totalPlayed,
          avgPoints: totalPoint / totalPlayed,
          avgTime: totalTime / totalPlayed,
        ));
      }
      rankings.sort((a, b) {
        int totalPlayedCompare = b.totalPlayed.compareTo(a.totalPlayed);
        if (totalPlayedCompare != 0) {
          return totalPlayedCompare;
        }
        int pointCompare = b.avgPoints.compareTo(a.avgPoints);
        if (pointCompare != 0) {
          return pointCompare;
        }
        return a.avgTime.compareTo(b.avgTime);
      });
      emit(RankingLoaded(rankings: rankings.take(5).toList()));
    } on FirebaseException {
      emit(const RankingFailed(message: "Có lỗi xảy ra khi tải bảng xếp hạng"));
    }
  }
}
