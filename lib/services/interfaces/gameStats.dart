class GameStats {
  final String winner;
  final String loser;
  final int winnerDifferencesFound;
  final int loserDifferencesFound;
  final int gameTime;

  GameStats({
    required this.winner,
    required this.loser,
    required this.winnerDifferencesFound,
    required this.loserDifferencesFound,
    required this.gameTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'winner': winner,
      'loser': loser,
      'winnerDifferencesFound': winnerDifferencesFound,
      'loserDifferencesFound': loserDifferencesFound,
      'gameTime': gameTime,
    };
  }
}
