import 'models/models.dart';

// Sample User Profile Data
final mockUserProfile = UserProfileModel(
  userId: 'user_001',
  userName: 'Alex',
  avatarUrl: null,
  currentLevel: 1,
  currentXp: 0,
  maxXp: 1000,
  recipesTried: 0,
  totalTimesCooked: 0,
);

// Sample Recipe List for Catalog Simulation
final List<RecipeModel> mockRecipes = [
  // 1. Classic Garlic Bagel
  RecipeModel(
    recipeId: 'rec_001',
    title: 'Classic Garlic Bagel',
    description: 'A delicious homemade bagel topped with crispy garlic butter.',
    imageUrl:
        'https://res.cloudinary.com/kraft-heinz-whats-cooking-ca/image/upload/f_auto/q_auto/c_limit,w_3840/v1/dxp-images/brands/Recipes/all-recipe-assets/cheesy-garlic-bread-bagel-recipe/149d4f7a2c6140b4828b5583d4e80b46_xy8zb4?_a=BAVMn6ID0',
    cookTimeMinutes: 25,
    activePrepTimeMinutes: 10,
    servings: 2,
    difficultyTier: 'Tier 1',
    mealType: 'Breakfast',
    cuisine: 'American',
    dietary: const ['Vegetarian'],
    tags: const ['Beginner Friendly', 'Budget'],
    ingredients: {
      'Flour': '2 cups',
      'Yeast': '1 tbsp',
      'Garlic': '2 cloves',
      'Butter': '2 tbsp',
    },
    estimatedCost: 3.50,
    costPerServing: 1.75,
    estimatedRestaurantCost: 7.00,
    startCookingButtonLabel: 'Start Cooking',
    nutritionStats: const NutritionModel(
      calories: 404,
      proteinGrams: 11,
      carbsGrams: 77,
      fatGrams: 5,
    ),
    steps: [
      CookingStepModel(
        stepNumber: 1,
        title: "Prep the Dough",
        instructionText:
            'Prep the dough by mixing the flour and yeast in a bowl with warm water.',
        timerSeconds: 300,
        importantTip: "Make sure your dough ends up smooth and elastic. If it's too sticky, add a bit more flour. If it's too dry, add some water.", 
      ),
      CookingStepModel(
        stepNumber: 2,
        title: "Bake",
        instructionText:
            'Place on a baking sheet at 375°F (190°C) for 15 minutes.',
        timerSeconds: 900,
      ),
    ],
  ),

  // 2. Creamy Garlic Alfredo
  RecipeModel(
    recipeId: 'rec_002',
    title: 'Creamy Garlic Alfredo',
    description:
        'Rich fettuccine pasta tossed in a rich, buttery garlic parmesan cream sauce.',
    imageUrl:
        'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?q=80&w=1000&auto=format&fit=crop',
    cookTimeMinutes: 20,
    activePrepTimeMinutes: 10,
    servings: 2,
    difficultyTier: 'Tier 1',
    mealType: 'Dinner',
    cuisine: 'Italian',
    dietary: const ['Vegetarian'],
    tags: const ['Quick & Easy'],
    ingredients: {
      'Fettuccine': '8 oz',
      'Heavy Cream': '1 cup',
      'Parmesan': '1/2 cup',
      'Butter': '3 tbsp',
      'Garlic': '3 cloves',
    },
    estimatedCost: 4.80,
    costPerServing: 2.40,
    estimatedRestaurantCost: 16.00,
    startCookingButtonLabel: 'Start Cooking',
    nutritionStats: const NutritionModel(
      calories: 1070,
      proteinGrams: 26,
      carbsGrams: 86,
      fatGrams: 70,
    ),
    steps: [
      CookingStepModel(
        stepNumber: 1,
        title: "Boil Pasta",
        instructionText:
            'Boil fettuccine in salted water according to package instructions.',
        timerSeconds: 600,
      ),
      CookingStepModel(
        stepNumber: 2,
        title: "Make Sauce",
        instructionText:
            'Melt butter, sauté garlic, then stir in heavy cream and parmesan until smooth.',
        timerSeconds: 300,
      ),
    ],
  ),

  // 3. Chicken & Veggie Stir Fry
  RecipeModel(
    recipeId: 'rec_003',
    title: 'Chicken & Veggie Stir Fry',
    description:
        'Tender chicken breast slices sizzled with fresh broccoli, peppers, and savory soy glaze.',
    imageUrl:
        'https://images.unsplash.com/photo-1603133872878-684f208fb84b?q=80&w=1000&auto=format&fit=crop',
    cookTimeMinutes: 15,
    activePrepTimeMinutes: 15,
    servings: 3,
    difficultyTier: 'Tier 2',
    mealType: 'Dinner',
    cuisine: 'Asian',
    dietary: const ['Gluten-Free'],
    tags: const ['Quick & Easy', 'Beginner Friendly'],
    ingredients: {
      'Chicken Breast': '1 lb',
      'Broccoli Florets': '2 cups',
      'Bell Pepper': '1 large',
      'Soy Sauce': '3 tbsp',
      'Sesame Oil': '1 tbsp',
    },
    estimatedCost: 7.50,
    costPerServing: 2.50,
    estimatedRestaurantCost: 18.50,
    startCookingButtonLabel: 'Start Cooking',
    nutritionStats: const NutritionModel(
      calories: 250,
      proteinGrams: 36,
      carbsGrams: 7,
      fatGrams: 9,
    ),
    steps: [
      CookingStepModel(
        stepNumber: 1,
        title: "Sear Chicken",
        instructionText:
            'Slice chicken thinly and cook in oil over high heat until browned.',
        timerSeconds: 360,
      ),
      CookingStepModel(
        stepNumber: 2,
        title: "Toss Veggies & Sauce",
        instructionText:
            'Add broccoli, peppers, and soy sauce. Stir-fry until veggies are tender-crisp.',
        timerSeconds: 240,
      ),
    ],
  ),
];

// Single recipe fallback
final mockRecipe = mockRecipes.first;