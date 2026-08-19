/// Data snapshot returned when XP is awarded to track progress
class XpRewardSnapshot {
  final int startXp;
  final int startLevel;
  final int xpEarned;
  final int finalXp;
  final int finalLevel;
  final bool didLevelUp;

  XpRewardSnapshot({
    required this.startXp,
    required this.startLevel,
    required this.xpEarned,
    required this.finalXp,
    required this.finalLevel,
    required this.didLevelUp,
  });
}