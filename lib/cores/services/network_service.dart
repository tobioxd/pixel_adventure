import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
import 'package:pixel_adventure/models/score_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class NetWorkService {
  static final Database _database = getIt<Database>();
  static final FirebaseAuth _auth = getIt<FirebaseAuth>();
  static final FirebaseFirestore _firestore = getIt<FirebaseFirestore>();
  static bool _isSyncing = false;

  static Future<bool> isConnected() async {
    final result = await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.mobile);
  }

  static void subcripeToConnectivityChanges() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (_isSyncing) return;

      try {
        _isSyncing = true;
        if ((result.contains(ConnectivityResult.wifi) ||
                result.contains(ConnectivityResult.mobile)) &&
            _auth.currentUser != null) {
          final userId = _auth.currentUser!.uid;
          final localScores = await _database.query(
            ScoresDbTable.tableName,
            where: "${ScoresDbTable.userIdColumn} = ?",
            whereArgs: [userId],
          );
          List<ScoreModel> scoreLocalModels = [];
          for (final score in localScores) {
            scoreLocalModels.add(ScoreModel.fromJson(score));
          }
          for (final score in scoreLocalModels) {
            final docRef = await _firestore
                .collection(ScoresDbTable.tableName)
                .doc(score.id)
                .get();
            if (!docRef.exists) {
              await _firestore
                  .collection(ScoresDbTable.tableName)
                  .doc(score.id)
                  .set(score.toJson());
            }
          }
          final remoteScores = await _firestore
              .collection(ScoresDbTable.tableName)
              .where(ScoresDbTable.userIdColumn, isEqualTo: userId)
              .get();
          await _database.delete(ScoresDbTable.tableName);
          for (final remoteScore in remoteScores.docs) {
            await _database.insert(
              ScoresDbTable.tableName,
              {
                ...remoteScore.data(),
                ScoresDbTable.idColumn: remoteScore.id,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      } on FirebaseException catch (e) {
        log("Firebase error: $e");
      } on Exception catch (e) {
        log("Sync error: $e");
      } finally {
        _isSyncing = false;
      }
    });
  }
}
