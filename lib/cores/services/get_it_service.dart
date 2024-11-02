import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/viewModels/player/player_cubit.dart';
import 'package:pixel_adventure/viewModels/sound/sound_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  final databasePath = await getDatabasesPath();
  String path = join(databasePath, 'pixel_adventure.db');
  Database database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE ${ScoresDbTable.tableName}(
          ${ScoresDbTable.characterColumn} TEXT,
          ${ScoresDbTable.createdAtColumn} TEXT,
          ${ScoresDbTable.idColumn} INTEGER PRIMARY KEY,
          ${ScoresDbTable.pointsColumn} INTEGER,
          ${ScoresDbTable.timeColumn} INTEGER,
          ${ScoresDbTable.userIdColumn} INTEGER);
      """);
    },
  );
  getIt.registerSingleton<Database>(database);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerFactory<SoundCubit>(() => SoundCubit());
  getIt.registerFactory<PlayerCutbit>(() => PlayerCutbit());
}
