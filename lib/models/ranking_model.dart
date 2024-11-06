class RankingModel {
  final String userId;
  final String userName;
  final double avgPoints;
  final double avgTime;
  final int totalPlayed;

  const RankingModel({
    required this.userId,
    required this.userName,
    required this.avgPoints,
    required this.avgTime,
    required this.totalPlayed,
  });
}
