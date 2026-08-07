# Main App

## Main App Screen Widget

* welcome message
    * String userName:
    * int currentTier: 
    * doulbe tierProgress: 
    * int currentStreak: 
* favorite recipes
    * list <Recipe> favorite recipes or list <string> favorite recipe IDs
    * bool isLoadingFavorites (for loading purposes)
* List<Recipe> popularRecipes 
* Main Bottom Bar 
    * int selectedIndex (currently active tab)
    * icons
    * current active icon

## Learning Tree Tier Widget

* the 4 tiers 
    * int userCurrentTier for which tier u unlocked
    * int totalTiers
    * double totalCourseProgress
    * int currentStreak at the top
* for each tier
    * int tierNumber (1,2,3,4)
    * tierTitle
    * tierSubtitle
    * double progress
    * bool isLocked for if a card is greyed out
    * int totalLessons
    * int completedLessons
    * int totalRecipes for that tier 
    * int completedRecipes
* i would probably create a class for each TierModel

## Individual Tier Detail Screen 

* Uses selected `TierModel` (Title, Subtitle, Progress, Counts).
* List<LessonModel> precursorLessons: 
    * String lessonId
    * String title
    * int estimatedMinutes
    * bool isCompleted
    * bool isLocked
* List<RecipeModel> practiceRecipes: 
    * String recipeId
    * String title
    * String imageUrl
    * int cookTimeMinutes
    * bool isMastered

## Recipe Screen
* RecipeModel full data stuff
    * recipeId, title, cookTimeMinutes, imageUrl (from before)
    * String description: 
    * List<String> equipment: 
    * List<String> ingredients: 
    * int activePrepTimeMinutes: 
    * int servings
    * List<CookingStepModel> steps: 
    * String difficultyTier: 
    * bool isFavorite
    * bool isCompleted
    * String startCookingButtonLabel
    * List<String> tags: general category tags
    * String mealType: breakfast, lunch etc. 
    * double estimatedCost
    * double costPerServing
    * String? userPhotoPath

## Guided Cooking Screen
* RecipeModel activeRecipe: 
* int currentStepIndex. 
* CookingStepModel currentStep = activeRecipe.steps[currentStepIndex]
* bool isShowingCheckIn
* String? selectedOption
* String? activeTipMessage

* create new class CookingStepModel 
    * stepNumber
    * title
    * instructionText
    * audioText
    * timerSeconds
    * Parsed via `CookingStepModel.fromJson()` inside the `RecipeModel` map loop
    * within CookingStepModel, make new class checkInModel which contains: 
        * String question:
        * List<string> options
        * Map<String, String> tipResponses

## Recipe Catalog

* Brief Recipe overview cards (uses RecipeModel)
    * String title
    * int cookTimeMinutes
    * List<string> tags
    * String imageUrl
    * double CostPerServing
    * bool isFavorite
* List <RecipeModel> allRecipes
* List <RecipeModel> filteredRecipes
* String searchQuery
* String? selectedTagFilter
* double maxBudgetFilter
* List <CompletedRecipeEntry> userGallery
* when u click on one tkaes u to recipe screen with active Recipe = selectedRecipe

## Profile Screen Architecture
* UserProfileModel 
    * String userId
    * String userName
    * string avatarUrl
    * List<string> favoriteRecipeIds
* Profile Screen Live State variables
    * UserProfileModel user
    List<CompletedRecipeEntry> userGallery
    * int totalrecipesCooked
    * double totalMoneySaved
    * CompletedRecipeEntry? selectedGalleryEntry
* CopmletedRecipeEntry
    * String entryId
    * String recipeId
    * String recipeTitle
    * String imagePath
    * DateTime completedAt
    * double costSaved

# 📦 Master Data Models Specification

## 1. UserProfileModel
* `String userId`
* `String userName`
* `String avatarUrl`
* `int currentTier`
* `double tierProgress`
* `int currentStreak`
* `List<String> favoriteRecipeIds`

---

## 2. TierModel
* `int tierNumber`
* `String tierTitle`
* `String tierSubtitle`
* `double progress`
* `bool isLocked`
* `int totalLessons`
* `int completedLessons`
* `int totalRecipes`
* `int completedRecipes`

---

## 3. LessonModel
* `String lessonId`
* `String title`
* `int estimatedMinutes`
* `bool isCompleted`
* `bool isLocked`

---

## 4. StepCheckInModel
* `String question`
* `List<String> options`
* `Map<String, String> tipResponses`

---

## 5. CookingStepModel
* `int stepNumber`
* `String title`
* `String instructionText`
* `String audioText`
* `int timerSeconds`
* `StepCheckInModel? checkIn`

---

## 6. RecipeModel
* `String recipeId`
* `String title`
* `String description`
* `String imageUrl`
* `int cookTimeMinutes`
* `int activePrepTimeMinutes`
* `int servings`
* `String difficultyTier`
* `String mealType`
* `List<String> tags`
* `List<String> equipment`
* `List<String> ingredients`
* `double estimatedCost`
* `double costPerServing`
* `String startCookingButtonLabel`
* `bool isFavorite`
* `bool isCompleted`
* `bool isMastered`
* `String? userPhotoPath`
* `List<CookingStepModel> steps`

---

## 7. CompletedRecipeEntry
* `String entryId`
* `String recipeId`
* `String recipeTitle`
* `String imagePath`
* `DateTime completedAt`
* `double costSaved`

