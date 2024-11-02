class ScoreModel {
  final int id;
  final int points;
  final int time;
  final int userId;
  final String character;

  const ScoreModel({
    required this.character,
    required this.id,
    required this.points,
    required this.time,
    required this.userId,
  });
}
