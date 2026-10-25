

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isEditing;

  /// For first-time onboarding, use this callback to switch the parent
  /// gate to the main app after preferences have been saved.
  final VoidCallback? onCompleted;

  const OnboardingScreen({
    super.key,
    this.isEditing = false,
    this.onCompleted,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  int _skillTier = 1;
  final TextEditingController _usernameController = TextEditingController();
  final Set<String> _cuisines = {};
  final Set<String> _allergies = {};
  final Set<String> _ingredients = {};
  bool _noAllergies = true;
  int? _maxCookTimeMinutes;

  static const List<String> _cuisineOptions = [
    'American',
    'Italian',
    'Chinese',
    'Mexican',
    'Indian',
    'Japanese',
    'Mediterranean',
  ];

  static const List<String> _allergyOptions = [
    'Peanuts',
    'Tree nuts',
    'Milk',
    'Eggs',
    'Soy',
    'Fish',
    'Shellfish',
    'Sesame',
    'Wheat'
  ];

  static const List<String> _ingredientOptions = [
    'Chicken',
    'Beef',
    'Fish',
    'Eggs',
    'Tofu',
    'Rice',
    'Pasta',
    'Potatoes',
    'Mushrooms',
    'Tomatoes',
    'Spinach',
    'Broccoli',
    'Beans',
    'Cheese',
  ];

  static const List<int> _timeOptions = [15, 30, 45, 60, 90];

  static const List<IconData> _stepIcons = [
    Icons.health_and_safety_rounded,
    Icons.soup_kitchen_outlined,
    Icons.public_rounded,
    Icons.schedule_rounded,
    Icons.shopping_basket_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  Future<void> _loadExistingPreferences() async {
    try {
      final profile = HistoryService.currentProfile;
      final preferences = profile.cookingPreferences;

      if (!mounted) return;

      setState(() {
        _usernameController.text = profile.userName;
        _skillTier = preferences.cookingSkillTier;
        _cuisines.addAll(preferences.favoriteCuisines);
        _allergies.addAll(preferences.allergies);
        _ingredients.addAll(preferences.preferredIngredients);
        _noAllergies = preferences.allergies.isEmpty;
        _maxCookTimeMinutes = preferences.maxCookTimeMinutes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(
        'Could not load your preferences. You can still enter them.',
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Allergies & Safety';
      case 1:
        return 'Your Cooking Journey';
      case 2:
        return 'Favorite Cuisines';
      case 3:
        return 'Time Preferences';
      case 4:
        return 'Ingredients You Enjoy';
      default:
        return 'Choose Your Username';
    }
  }

  String get _stepSubtitle {
    switch (_step) {
      case 0:
        return 'Tell us about any food allergies we should account for.';
      case 1:
        return 'Whether you are a newbie beginner or a seasoned cook, knowing your skill level helps us personalize recommendations for you. If you are a beginner, don\'t worry! Even the best of cooks started somewhere.';
      case 2:
        return 'Choose the cuisines you would be excited to learn more about and potentially cook recipes related to that cuisine. You can select multiple cuisines. You can also filter through cuisines in our recipe catalog.';
      case 3:
        return 'How much time at most are you willing to spend cooking?';
      case 4:
        return 'Optionally choose up to 5 ingredients you enjoy cooking with or have a lot of. This will help us recommend recipes that align with what you have in your pantry.';
      default:
        return 'Choose a username! It needs to be between 5 and 12 characters long.';
    }
  }

  Future<void> _next() async {
    if (_isSaving) return;

    if (_step == 5) {
      final username = _usernameController.text.trim();

      if (username.length < 5 || username.length > 12) {
        _showMessage('Username must be between 5 and 12 characters.');
        return;
      }

      await _savePreferences();
      return;
    }

    if (_step < 5) {
      setState(() => _step++);
    }
  }

  void _back() {
    if (_isSaving) return;

    if (_step > 0) {
      setState(() => _step--);
    } else if (widget.isEditing) {
      Navigator.pop(context);
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);

    try {
      final preferences = CookingPreferencesModel(
        cookingSkillTier: _skillTier,
        favoriteCuisines: _cuisines.toList(),
        allergies: _allergies.toList(),
        preferredIngredients: _ingredients.toList(),
        maxCookTimeMinutes: _maxCookTimeMinutes,
      );

      await HistoryService.saveCookingPreferences(
        preferences,
        userName: _usernameController.text.trim(),
      );

      if (!mounted) return;

      if (widget.isEditing) {
        Navigator.pop(context, true);
      } else if (widget.onCompleted != null) {
        widget.onCompleted!();
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage('Could not save your preferences. Please try again.');
      setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.oliveSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(
        title: widget.isEditing ? 'Cooking Preferences' : 'Meet Your Taste',
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.creamBackground,
          ),
          onPressed: _back,
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.terracottaAccent,
                ),
              )
            : Column(
                children: [
                  _buildProgressHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.04, 0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: SingleChildScrollView(
                        key: ValueKey(_step),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HeaderWidget(
                              headerText: _stepTitle,
                              icon: _stepIcons[_step],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _stepSubtitle,
                              style: const TextStyle(
                                fontSize: 17,
                                height: 1.45,
                                color: AppColors.oliveSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildQuestionContent(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'YOUR CHEF PROFILE',
                style: TextStyle(
                  color: AppColors.terracottaAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '${_step + 1} OF 6',
                style: const TextStyle(
                  color: AppColors.oliveSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: (_step + 1) / 6,
              minHeight: 7,
              backgroundColor:
                  AppColors.oliveSecondary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.terracottaAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    switch (_step) {
      case 0:
        return _buildAllergyChoices();
      case 1:
        return _buildSkillChoices();
      case 2:
        return _buildMultiChoiceGrid(
          options: _cuisineOptions,
          selected: _cuisines,
          onToggle: (value) {
            setState(() {
              if (!_cuisines.add(value)) _cuisines.remove(value);
            });
          },
          icon: Icons.public_rounded,
          iconBesideText: true,
        );
      case 3:
        return _buildTimeChoices();
      case 4:
        return _buildIngredientChoices();
      default:
        return _buildUsernameInput();
    }
  }

  Widget _buildSkillChoices() {
    const tiers = [
      (
        tier: 1,
        title: 'Beginner',
        description:
            'I’m learning the basics, like chopping and following simple recipes.',
        icon: Icons.spa_outlined,
      ),
      (
        tier: 2,
        title: 'Comfortable cook',
        description:
            'I can follow most recipes and handle several cooking techniques.',
        icon: Icons.soup_kitchen_outlined,
      ),
      (
        tier: 3,
        title: 'Experienced',
        description:
            'I’m comfortable with complex recipes and more advanced techniques.',
        icon: Icons.restaurant_menu_rounded,
      ),
    ];

    return Column(
      children: tiers.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _choiceCard(
            title: item.title,
            description: item.description,
            icon: item.icon,
            selected: _skillTier == item.tier,
            onTap: () => setState(() => _skillTier = item.tier),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllergyChoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _choiceCard(
          title: 'No listed allergies',
          description: 'I don’t have any of the allergies listed below.',
          icon: Icons.check_circle_outline_rounded,
          selected: _noAllergies,
          onTap: () {
            setState(() {
              _noAllergies = true;
              _allergies.clear();
            });
          },
        ),
        const SizedBox(height: 12),
        _buildMultiChoiceGrid(
          options: _allergyOptions,
          selected: _allergies,
          icon: Icons.warning_amber_rounded,
          iconBesideText: true,
          onToggle: (value) {
            setState(() {
              _noAllergies = false;
              if (!_allergies.add(value)) _allergies.remove(value);
              if (_allergies.isEmpty) _noAllergies = true;
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.terracottaAccent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.oliveSecondary.withValues(alpha: 0.35),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.terracottaAccent,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'These answers help filter recommendations, but they cannot guarantee a recipe is allergen-free. Always check ingredient labels and cross-contact risks.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    color: AppColors.oliveSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientChoices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'SELECTED',
              style: TextStyle(
                color: AppColors.oliveSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            const Spacer(),
            Text(
              '${_ingredients.length} / 5 (optional)',
              style: const TextStyle(
                color: AppColors.oliveSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildMultiChoiceGrid(
          options: _ingredientOptions,
          selected: _ingredients,
          icon: Icons.shopping_basket_outlined,
          onToggle: (value) {
            setState(() {
              if (_ingredients.contains(value)) {
                _ingredients.remove(value);
              } else if (_ingredients.length < 5) {
                _ingredients.add(value);
              } else {
                _showMessage('Choose up to 5 ingredients.');
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeChoices() {
    return Column(
      children: [
        _choiceCard(
          title: 'No time limit',
          description: 'I’m happy to spend as long as the recipe takes.',
          icon: Icons.all_inclusive_rounded,
          selected: _maxCookTimeMinutes == null,
          onTap: () => setState(() => _maxCookTimeMinutes = null),
        ),
        const SizedBox(height: 12),
        ..._timeOptions.map((minutes) {
          final description = switch (minutes) {
            15 => 'Quick meals and simple snacks',
            30 => 'A practical everyday meal',
            45 => 'A little more time to cook',
            60 => 'Time for a more involved recipe',
            _ => 'Longer recipes are fine with me',
          };

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _choiceCard(
              title: 'Up to $minutes minutes',
              description: description,
              icon: Icons.schedule_rounded,
              selected: _maxCookTimeMinutes == minutes,
              onTap: () => setState(() => _maxCookTimeMinutes = minutes),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMultiChoiceGrid({
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
    required IconData icon,
    bool iconBesideText = true,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 500 ? 3 : 2;
        const spacing = 10.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: options.map((option) {
            final isSelected = selected.contains(option);

            return SizedBox(
              width: width,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onToggle(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.oliveSecondary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.oliveSecondary
                          : AppColors.oliveSecondary.withValues(alpha: 0.16),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: iconBesideText
                      ? Row(
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : icon,
                              color: isSelected
                                  ? AppColors.creamBackground
                                  : AppColors.terracottaAccent,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.creamBackground
                                      : AppColors.oliveSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle : icon,
                              color: isSelected
                                  ? AppColors.creamBackground
                                  : AppColors.terracottaAccent,
                              size: 22,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.creamBackground
                                    : AppColors.oliveSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _choiceCard({
    required String title,
    required String description,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.oliveSecondary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.oliveSecondary.withValues(alpha: 0.14),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.creamBackground.withValues(alpha: 0.14)
                    : AppColors.terracottaAccent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected
                    ? AppColors.creamBackground
                    : AppColors.terracottaAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected
                          ? AppColors.creamBackground
                          : AppColors.oliveSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: selected
                          ? AppColors.creamBackground.withValues(alpha: 0.9)
                          : AppColors.oliveSecondary.withValues(alpha: 0.8),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              color: selected
                  ? AppColors.creamBackground
                  : AppColors.oliveSecondary.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _usernameController,
          maxLength: 12,
          textCapitalization: TextCapitalization.none,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Username',
            hintText: 'e.g. kitchenpro',
            helperText: 'Use 5–12 characters.',
            filled: true,
            fillColor: Colors.white,
            counterStyle:
                const TextStyle(color: AppColors.oliveSecondary),
            labelStyle:
                const TextStyle(color: AppColors.oliveSecondary),
            hintStyle: TextStyle(
              color: AppColors.oliveSecondary.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.oliveSecondary.withValues(alpha: 0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.oliveSecondary.withValues(alpha: 0.2),
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide(
                color: AppColors.terracottaAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isLastStep = _step == 5;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.creamBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_step > 0 || widget.isEditing)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: _isSaving ? null : _back,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.oliveSecondary,
                  side: const BorderSide(
                    color: AppColors.oliveSecondary,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_step > 0 || widget.isEditing)
            const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.terracottaAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.terracottaAccent.withValues(alpha: 0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep
                              ? (widget.isEditing
                                  ? 'Save Profile'
                                  : 'Finish Setup')
                              : 'Continue',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
