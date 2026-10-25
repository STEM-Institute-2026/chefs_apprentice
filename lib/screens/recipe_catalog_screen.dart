import 'package:flutter/material.dart';
// Replace with your actual import paths:
import '../models/models.dart';
import './widgets/recipe_card.dart';
import 'widgets/header_and_app_bar.dart';
import 'widgets/filter_category_section.dart';

class RecipeCatalogScreen extends StatefulWidget {
  final List<RecipeModel> initialRecipes;

  const RecipeCatalogScreen({
    super.key,
    required this.initialRecipes,
  });

  @override
  State<RecipeCatalogScreen> createState() => _RecipeCatalogScreenState();
}

class _RecipeCatalogScreenState extends State<RecipeCatalogScreen> {
  late List<RecipeModel> allRecipes;

  // Active list driving the GridView
  late List<RecipeModel> displayedRecipes;

  // Search Controller
  final TextEditingController searchController = TextEditingController();

  // Active Filters State
  List<String> activeDietary = [];
  String? activeMealType;
  String? activeCuisine;
  List<String> activeTags = [];

  @override
  void initState() {
    super.initState();
    allRecipes = widget.initialRecipes;
    displayedRecipes = List.from(allRecipes);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // The main function that filters what is displayed on screen
  void _applyAllFilters() {
    final searchText = searchController.text.toLowerCase();

    setState(() {
      displayedRecipes = allRecipes.where((recipe) {
        // 1. Search Check
        final matchesSearch = searchText.isEmpty ||
            recipe.title.toLowerCase().contains(searchText);

        // 2. Meal Type Check
        final matchesMeal =
            activeMealType == null || recipe.mealType == activeMealType;

        // 3. Cuisine Check
        final matchesCuisine =
            activeCuisine == null || recipe.cuisine == activeCuisine;

        // 4. Dietary Check
        final matchesDietary = activeDietary.isEmpty ||
            activeDietary.every((d) => recipe.dietary.contains(d));

        // 5. Badges/Tags Check
        final matchesTags = activeTags.isEmpty ||
            activeTags.every((t) => recipe.tags.contains(t));

        return matchesSearch &&
            matchesMeal &&
            matchesCuisine &&
            matchesDietary &&
            matchesTags;
      }).toList();
    });
  }

  void _openFilterSheet() {
    // Temporary variables initialized with active filters
    List<String> tempDietary = List.from(activeDietary);
    String? tempMealType = activeMealType;
    String? tempCuisine = activeCuisine;
    List<String> tempTags = List.from(activeTags);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.creamBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Calculate live count inside sheet
            final matchingCount = allRecipes.where((recipe) {
              final searchText = searchController.text.toLowerCase();
              final matchesSearch = searchText.isEmpty ||
                  recipe.title.toLowerCase().contains(searchText);
              final matchesMeal =
                  tempMealType == null || recipe.mealType == tempMealType;
              final matchesCuisine =
                  tempCuisine == null || recipe.cuisine == tempCuisine;
              final matchesDietary = tempDietary.isEmpty ||
                  tempDietary.every((d) => recipe.dietary.contains(d));
              final matchesTags = tempTags.isEmpty ||
                  tempTags.every((t) => recipe.tags.contains(t));

              return matchesSearch &&
                  matchesMeal &&
                  matchesCuisine &&
                  matchesDietary &&
                  matchesTags;
            }).length;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. FIXED MODAL HEADER ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filters',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- 2. SCROLLABLE FILTER CONTENT ---
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dietary Category
                          FilterCategorySection(
                            title: 'Dietary',
                            options: const ['Vegetarian', 'Vegan', 'Gluten-Free'],
                            selectedOptions: tempDietary,
                            onOptionToggled: (option) {
                              setModalState(() {
                                tempDietary.contains(option)
                                    ? tempDietary.remove(option)
                                    : tempDietary.add(option);
                              });
                            },
                          ),

                          // Meal Type Category
                          FilterCategorySection(
                            title: 'Type',
                            options: const ['Breakfast', 'Lunch', 'Dinner'],
                            selectedOptions:
                                tempMealType != null ? [tempMealType!] : [],
                            onOptionToggled: (option) {
                              setModalState(() {
                                tempMealType =
                                    (tempMealType == option) ? null : option;
                              });
                            },
                          ),

                          // Cuisine Category
                          FilterCategorySection(
                            title: 'Cuisine',
                            options: const ['American', 'Italian', 'Chinese', 'Mexican', 'Indian', 'Japanese', 'Mediterranean'],
                            selectedOptions:
                                tempCuisine != null ? [tempCuisine!] : [],
                            onOptionToggled: (option) {
                              setModalState(() {
                                tempCuisine =
                                    (tempCuisine == option) ? null : option;
                              });
                            },
                          ),

                          // Badges Category
                          FilterCategorySection(
                            title: 'Badges',
                            options: const [
                              'Quick & Easy',
                              'Beginner Friendly',
                              'Budget'
                            ],
                            selectedOptions: tempTags,
                            onOptionToggled: (option) {
                              setModalState(() {
                                tempTags.contains(option)
                                    ? tempTags.remove(option)
                                    : tempTags.add(option);
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 5, color: Colors.black),

                  // --- 3. STICKY FOOTER WITH SAFE AREA ---
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.terracottaAccent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  tempDietary.clear();
                                  tempMealType = null;
                                  tempCuisine = null;
                                  tempTags.clear();
                                });
                              },
                              child: const Text(
                                'Clear filters',
                                style: TextStyle(
                                  color: AppColors.creamBackground,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.oliveSecondary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              onPressed: () {
                                // Save temp choices to active screen state
                                activeDietary = tempDietary;
                                activeMealType = tempMealType;
                                activeCuisine = tempCuisine;
                                activeTags = tempTags;

                                // Re-filter main grid & close modal
                                _applyAllFilters();
                                Navigator.pop(context);
                              },
                              child: Text(
                                matchingCount == 1
                                    ? 'See 1 dish'
                                    : 'See $matchingCount dishes',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.creamBackground,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(title: "Recipe Catalog"),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // 🔍 Search Bar & Filter Button
            TextField(
              controller: searchController,
              onChanged: (_) => _applyAllFilters(),
              decoration: InputDecoration(
                hintText: 'Search recipes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _openFilterSheet,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 🥘 Recipe Grid
            Expanded(
              child: displayedRecipes.isEmpty
                  ? const Center(
                      child: Text(
                        'No recipes match your search or filters.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : GridView.builder(
                      itemCount: displayedRecipes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        final recipe = displayedRecipes[index];
                        return RecipeCatalogCard(recipe: recipe);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}