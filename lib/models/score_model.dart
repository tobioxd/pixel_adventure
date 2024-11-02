import 'package:pixel_adventure/cores/constants/scores_db_table.dart';

class ScoreModel {
  final String id;
  final int points;
  final Duration time;
  final String userId;
  final String character;
  final DateTime createdAt;

  const ScoreModel({
    required this.character,
    required this.id,
    required this.points,
    required this.time,
    required this.userId,
    required this.createdAt,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> map) {
    return ScoreModel(
      id: map[ScoresDbTable.idColumn],
      points: map[ScoresDbTable.pointsColumn],
      time: Duration(seconds: map[ScoresDbTable.timeColumn]),
      userId: map[ScoresDbTable.userIdColumn],
      character: map[ScoresDbTable.characterColumn],
      createdAt: DateTime.parse(map[ScoresDbTable.createdAtColumn]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ScoresDbTable.idColumn: id,
      ScoresDbTable.pointsColumn: points,
      ScoresDbTable.timeColumn: time.inSeconds,
      ScoresDbTable.userIdColumn: userId,
      ScoresDbTable.characterColumn: character,
      ScoresDbTable.createdAtColumn: createdAt.toString(),
    };
  }
}
