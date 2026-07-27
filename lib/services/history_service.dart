import '../models/models.dart';

class HistoryService {
  // Global list to store saved meals while the app is running
  static final List<CookedHistoryModel> savedMeals = [];

  static void addMeal(CookedHistoryModel meal) {
    savedMeals.add(meal);
  }
}