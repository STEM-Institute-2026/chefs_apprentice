import 'package:flutter/material.dart';
import '../models/models.dart';
import 'home_screen.dart';
import 'learn_screen.dart';
import 'recipe_catalog_screen.dart';
import 'profile_screen.dart';

class MainShellScreen extends StatefulWidget {
  final List<RecipeModel> recipes;
  final List<SkillModuleModel> skillModules;
  final List<CuisineModuleModel> cuisineModules;
  final EssentialsTabModel essentialsData;
  final UserProfileModel userProfile;
  final List<BadgeModel> badges;

  const MainShellScreen({
    super.key,
    required this.recipes,
    required this.skillModules,
    required this.cuisineModules,
    required this.essentialsData,
    required this.userProfile,
    required this.badges,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        recipes: widget.recipes,
        onOpenCatalog: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
      LearnScreen(
        essentialsData: widget.essentialsData,
        skillModules: widget.skillModules,
        cuisineModules: widget.cuisineModules,
      ),
      RecipeCatalogScreen(initialRecipes: widget.recipes),
      ProfileScreen()
    ];

    return Scaffold(
      // 1. Setting resizeToAvoidBottomInset ensures the body stays fixed above system bars
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 2. Wrapping IndexedStack in Expanded forces every screen 
            // to stay strictly within the available height above the nav bar.
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: screens,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.oliveSecondary,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.oliveSecondary,
            selectedItemColor: AppColors.creamBackground,
            unselectedItemColor:
                AppColors.creamBackground.withValues(alpha: 0.6),
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
                activeIcon: Icon(
                  Icons.home_rounded,
                  color: AppColors.terracottaAccent,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(
                  Icons.school_rounded,
                  color: AppColors.terracottaAccent,
                ),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(
                  Icons.menu_book_rounded,
                  color: AppColors.terracottaAccent,
                ),
                label: 'Catalog',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(
                  Icons.person_rounded,
                  color: AppColors.terracottaAccent,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}