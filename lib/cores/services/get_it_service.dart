import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:pixel_adventure/cores/constants/scores_db_table.dart';
import 'package:pixel_adventure/viewModels/game_result/game_result_cubit.dart';
import 'package:pixel_adventure/viewModels/history/history_cubit.dart';
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
    version: 3,
    onCreate: (db, version) async {
      await db.execute("""
        CREATE TABLE ${ScoresDbTable.tableName} (
            ${ScoresDbTable.characterColumn} TEXT,
            ${ScoresDbTable.createdAtColumn} TEXT,
            ${ScoresDbTable.idColumn} TEXT PRIMARY KEY,
            ${ScoresDbTable.pointsColumn} INTEGER,
            ${ScoresDbTable.timeColumn} INTEGER,
            ${ScoresDbTable.userIdColumn} TEXT
        );
      """);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute("DROP TABLE IF EXISTS ${ScoresDbTable.tableName}");
      await db.execute("""
        CREATE TABLE ${ScoresDbTable.tableName} (
          ${ScoresDbTable.idColumn} TEXT PRIMARY KEY,
          ${ScoresDbTable.userIdColumn} TEXT,
          ${ScoresDbTable.pointsColumn} INTEGER,
          ${ScoresDbTable.timeColumn} INTEGER,
          ${ScoresDbTable.createdAtColumn} TEXT,
          ${ScoresDbTable.characterColumn} TEXT
        );
      """);
    },
  );
  getIt.registerSingleton<Database>(database);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerFactory<SoundCubit>(() => SoundCubit());
  getIt.registerFactory<PlayerCutbit>(() => PlayerCutbit());
  getIt.registerFactory<GameResultCubit>(() => GameResultCubit());
  getIt.registerFactory<HistoryCubit>(() => HistoryCubit());
}
