import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/constants/user_db_key.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/cores/services/network_service.dart';
import 'package:pixel_adventure/models/score_model.dart';
import 'package:pixel_adventure/models/user_model.dart';
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
      List<ScoreModel> highestScores = [];
      final highestScoreDocs = await _firestore
          .collection(ScoresDbTable.tableName)
          .orderBy(ScoresDbTable.pointsColumn, descending: true)
          .get();
      for (final doc in highestScoreDocs.docs) {
        if (highestScores.length == 5) {
          break;
        }
        final scoreObject = ScoreModel.fromJson({
          ScoresDbTable.idColumn: doc.id,
          ...doc.data(),
        });
        if (highestScores
            .any((element) => element.userId == scoreObject.userId)) {
          continue;
        } else {
          highestScores.add(scoreObject);
        }
      }
      highestScores.sort((a, b) {
        int pointsComapare = b.points.compareTo(a.points);
        if (pointsComapare != 0) {
          return pointsComapare;
        }
        int timeCompare = a.time.compareTo(b.time);
        if (timeCompare != 0) {
          return timeCompare;
        }
        return a.createdAt.compareTo(b.createdAt);
      });
      List<UserModel> users = [];
      for (final score in highestScores) {
        final userDoc = await _firestore
            .collection(UserDbKey.collectionName)
            .doc(score.userId)
            .get();
        final userObject = UserModel.fromJson({
          UserDbKey.idKey: userDoc.id,
          ...userDoc.data()!,
        });
        users.add(userObject);
      }
      Map<UserModel, ScoreModel> rankings =
          Map.fromIterables(users, highestScores);
      emit(RankingLoaded(rankings: rankings));
    } on FirebaseException {
      emit(const RankingFailed(message: "Có lỗi xảy ra khi tải bảng xếp hạng"));
    }
  }
}
