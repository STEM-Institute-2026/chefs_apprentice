import "./models/models.dart";
import './mock_data.dart'; // Imports your base mockRecipes list
import "package:flutter/material.dart";
// ==========================================
// 1. SEPARATE SKILLS LIST
// ==========================================
final List<SkillModel> allSkills = [
  SkillModel(
    id: 'skill_knife_safety',
    name: 'Knife Safety & Control',
    shortDescription: 'Master the claw grip and essential knife handling to chop safely. Good knife skills save prep time and prevent kitchen accidents.',
    icon: Icons.flatware,
    videoUrl: 'assets/videos/skill_knife_cutting.mp4',
    coreSteps: const [
      SkillStepModel(
        title: 'Claw Grip',
        description: 'Curl fingertips inward to protect fingers while steadying food.',
        imagePath: 'assets/images/knife_skills/claw_grip.webp', // Optional asset path
      ),
      SkillStepModel(
        title: 'Pinch Grip',
        description: 'Pinch the base of the blade with thumb and index finger for maximum control.',
        imagePath: 'assets/images/knife_skills/pinch_grip.jpg', // Optional asset path
      ),
      SkillStepModel(
        title: 'Rocking Motion',
        description: 'Keep the knife tip down and rock the blade smoothly forward and down.',
        // imagePath is omitted here to show it remains optional
      ),
    ],
    keyTypesOrCuts: [
      'Rough Chop: Large, casual cuts for stocks or stews.',
      'Dice: Even, square cubes for onions and peppers.',
      'Mince: Fine, tiny pieces for garlic and ginger.',
    ],
    safetyOrProTips: [
      'Place a damp paper towel under your cutting board so it doesn’t slide.',
      'Keep your knife sharp—dull knives slip much more easily.',
    ],
    whereItsUsed: 'Virtually every recipe requiring vegetables, herbs, or meats.',
  ),
  SkillModel(
    id: 'skill_boiling',
    name: 'Boiling & Simmering Control',
    shortDescription: 'Understand water heat levels for pasta, eggs, and stock control. Proper liquid temperatures prevent overcooking and preserve texture.',
    icon: Icons.soup_kitchen,
    videoUrl: 'assets/videos/boiling.mp4',
    coreSteps: const [
      SkillStepModel(
        title: 'Rolling Boil',
        description: 'Wait until large, vigorous bubbles break rapidly on the surface.',
        imagePath: '', // Optional asset path
      ),
      SkillStepModel(
        title: 'Simmer',
        description: 'Drop heat to medium-low so small, slow bubbles rise gently.',
        imagePath: '', // Optional asset path
      ),
      SkillStepModel(
        title: 'Salting',
        description: 'Salt boiling water generously until it tastes lightly like seawater.',
        // imagePath is omitted here as an example
      ),
    ],
    keyTypesOrCuts: [
      'Rolling Boil: Best for pasta and blanching green veggies.',
      'Gentle Simmer: Best for soups, stews, and delicate poached eggs.',
    ],
    safetyOrProTips: [
      'Cover the pot with a lid to bring water to a boil much faster.',
      'Never drop pasta into cold water; wait for a full boil.',
    ],
    whereItsUsed: 'Pasta, soups, boiled eggs, and stocks.',
  ),
  SkillModel(
    id: 'skill_searing',
    name: 'Pan Searing & High Heat',
    shortDescription: 'Develop rich flavor and golden crusts using proper heat and oil. Searing locks in moisture and creates a flavorful browned crust.',
    icon: Icons.local_fire_department,
    videoUrl: 'assets/videos/searing.mp4',
    coreSteps: const [
      SkillStepModel(
        title: 'Claw Grip',
        description: 'Curl fingertips inward to protect fingers while steadying food.',
        imagePath: '',
      ),
      SkillStepModel(
        title: 'Pinch Grip',
        description: 'Pinch the base of the blade with thumb and index finger for control.',
        imagePath: '',
      ),
      SkillStepModel(
        title: 'Rocking Motion',
        description: 'Keep the knife tip down and rock the blade smoothly.',
        imagePath: '',
      ),
    ],
    keyTypesOrCuts: [
      'Hard Sear: High heat for quick browning on steak or tuna.',
      'Pan Roast: Sear on stove, then finish in the oven for thick meats.',
    ],
    safetyOrProTips: [
      'Don’t crowd the pan, or the food will steam instead of sear.',
      'If meat sticks to the pan when flipping, it’s not done searing yet.',
    ],
    whereItsUsed: 'Steaks, chicken breasts, salmon fillets, and sautéed veggies.',
  ),
];

// ==========================================
// 2. TIER RECIPE LISTS
// ==========================================
final List<RecipeModel> tier1Recipes = [
  mockRecipes[0],
  mockRecipes[1],
];

final List<RecipeModel> tier2Recipes = [
  mockRecipes[2],
];

final List<RecipeModel> tier3Recipes = [
  mockRecipes[2],
];

final List<RecipeModel> tier4Recipes = [
  mockRecipes[2],
];

// ==========================================
// 3. TIER LIST
// ==========================================
final List<TierModel> mockTiers = [
  TierModel(
    id: 'tier_1',
    tierNumber: 1,
    title: 'Kitchen Fundamentals',
    description: 'Master essential knife cuts, boiling techniques, and kitchen safety basics.',
    coverImageUrl: 'https://images.unsplash.com/photo-1604543456734-4559dd906a0c?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8a25pZmUlMjBjaG9wcGluZyUyMGZvb2R8ZW58MHx8MHx8fDA%3D',
    skills: [
      allSkills[0], // Knife Safety
    ],
    recipes: tier1Recipes,
  ),
  TierModel(
    id: 'tier_2',
    tierNumber: 2,
    title: 'Heat & Pan Control',
    description: 'Learn how to sear, sauté, and manage pan temperatures like a pro.',
    coverImageUrl: 'https://images.unsplash.com/flagged/photo-1571902241554-82ec31087fe3?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Ym9pbGluZyUyMGZvb2RzfGVufDB8fDB8fHww',
    skills: [
      allSkills[1], // Pan Searing
    ],
    recipes: tier2Recipes,
  ),
];