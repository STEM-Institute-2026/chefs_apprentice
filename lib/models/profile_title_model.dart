class ProfileTitleModel {
  final String name;
  final int requiredLevel;

  const ProfileTitleModel({required this.name, required this.requiredLevel});
  bool isUnlocked(int currentLevel) => currentLevel >= requiredLevel;
}

List<ProfileTitleModel> availableTitles = const [
  ProfileTitleModel(name: 'Novice Cook', requiredLevel: 1),
  ProfileTitleModel(name: 'Line Cook', requiredLevel: 3),
  ProfileTitleModel(name: 'Sous Chef', requiredLevel: 6),
  ProfileTitleModel(name: 'Head Chef', requiredLevel: 10),
  ProfileTitleModel(name: 'Master Connoisseur', requiredLevel: 15),
];

List<ProfileTitleModel> getUnlockedTitles(int userLevel) {
  return availableTitles.where((t) => userLevel >= t.requiredLevel).toList();
}

ProfileTitleModel getHighestTitle(int userLevel) {
  final unlocked = getUnlockedTitles(userLevel);
  return unlocked.isNotEmpty ? unlocked.last : availableTitles.first;
}