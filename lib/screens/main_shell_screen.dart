import 'package:flutter/material.dart';
import '../models/models.dart';
import 'home_screen.dart';
import 'tier_selection_screen.dart';
import 'recipe_catalog_screen.dart';
import 'cooked_history_screen.dart';

class MainShellScreen extends StatefulWidget {
  final List<RecipeModel> recipes;

  const MainShellScreen({
    super.key,
    required this.recipes,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 1. Array of your 4 main screens
    final List<Widget> screens = [
      HomeScreen(recipes: widget.recipes),
      const TierSelectionScreen(),
      RecipeCatalogScreen(initialRecipes: widget.recipes),
      CookedHistoryScreen(key: ValueKey(_selectedIndex)),
    ];

    return Scaffold(
      // 2. IndexedStack keeps all 4 screens alive so scroll position isn't lost
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),

      // 3. Custom styled Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed, // Displays all 4 labels
          backgroundColor: AppColors.oliveSecondary,
          selectedItemColor: AppColors.creamBackground,
          unselectedItemColor: AppColors.creamBackground.withValues(alpha: 0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded, color: AppColors.terracottaAccent,),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers_rounded, color: AppColors.terracottaAccent,),
              label: 'Tiers',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded, color: AppColors.terracottaAccent,),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history_rounded, color: AppColors.terracottaAccent,),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}