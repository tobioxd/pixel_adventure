import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/cores/services/get_it_service.dart';
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

          await _database.transaction((txn) async {
            // Sync local to cloud
            final localScores = await txn.query(
              ScoresDbTable.tableName,
              where: "${ScoresDbTable.userIdColumn} = ?",
              whereArgs: [userId],
            );

            for (var score in localScores) {
              final docRef = _firestore
                  .collection(ScoresDbTable.tableName)
                  .doc(score[ScoresDbTable.idColumn] as String);

              final cloudScore = await docRef.get();
              if (!cloudScore.exists) {
                await docRef.set({
                  ScoresDbTable.pointsColumn: score[ScoresDbTable.pointsColumn],
                  ScoresDbTable.timeColumn: score[ScoresDbTable.timeColumn],
                  ScoresDbTable.userIdColumn: score[ScoresDbTable.userIdColumn],
                  ScoresDbTable.createdAtColumn:
                      score[ScoresDbTable.createdAtColumn],
                  ScoresDbTable.characterColumn:
                      score[ScoresDbTable.characterColumn],
                });
              }
            }

            // Sync cloud to local
            await txn.delete(ScoresDbTable.tableName);

            final cloudScores = await _firestore
                .collection(ScoresDbTable.tableName)
                .where(ScoresDbTable.userIdColumn, isEqualTo: userId)
                .get();

            for (var doc in cloudScores.docs) {
              final data = doc.data();
              await txn.insert(ScoresDbTable.tableName, {
                ScoresDbTable.idColumn: doc.id,
                ScoresDbTable.pointsColumn: data[ScoresDbTable.pointsColumn],
                ScoresDbTable.timeColumn: data[ScoresDbTable.timeColumn],
                ScoresDbTable.userIdColumn: data[ScoresDbTable.userIdColumn],
                ScoresDbTable.createdAtColumn:
                    data[ScoresDbTable.createdAtColumn],
                ScoresDbTable.characterColumn:
                    data[ScoresDbTable.characterColumn],
              });
            }
          });
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
