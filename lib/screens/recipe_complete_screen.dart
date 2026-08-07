import 'package:flutter/material.dart';
import "../models/models.dart"; 
import 'package:flutter/services.dart';
import 'photo_upload_box.dart'; // 
import 'package:image_picker/image_picker.dart';
import '../services/history_service.dart';
import 'widgets/header_and_app_bar.dart';

class RecipeCompleteScreen extends StatefulWidget {
  final RecipeModel recipe;
  const RecipeCompleteScreen({super.key, required this.recipe});

  @override
  State<RecipeCompleteScreen> createState() => _RecipeCompleteScreenState();
}

class _RecipeCompleteScreenState extends State<RecipeCompleteScreen> {
  double? _calculatedSavings;
  String? _userPhotoPath;
  int? _userRating;

  @override
  void initState() {
    super.initState();
    // Triggers the XP Popup as soon as the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false, // User must tap "Awesome!" to close
        builder: (context) => const XpRewardDialog(
          earnedXp: 150,
          currentXp: 400,
          xpPerLevel: 600,
          startLevel: 3,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(title: "Meal Complete!"),

      // --- SCROLLABLE CONTENT AREA ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            BudgetInputSection(
              restaurantAverage: widget.recipe.estimatedRestaurantCost,
              onSavingsCalculated: (savings) {
                setState(() {
                  _calculatedSavings = savings;
                });
              },
            ),
            const SizedBox(height: 20),
            RatingSection(
              onRatingChanged: (rating) {
                setState(() {
                  _userRating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            PhotoUploadBox(
              onImageSelected: (XFile? image) {
                setState(() {
                  _userPhotoPath = image?.path;
                });
              },
            ),
            const SizedBox(height: 16), // Padding bottom so content doesn't get cut off
          ],
        ),
      ),

      // --- STICKY BOTTOM BUTTON ---
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final newHistoryItem = CookedHistoryModel(
                  entryId: DateTime.now().millisecondsSinceEpoch.toString(),
                  recipeId: widget.recipe.recipeId,
                  recipeTitle: widget.recipe.title,
                  imagePath: _userPhotoPath ?? '',
                  completedAt: DateTime.now(),
                  costSaved: _calculatedSavings,
                  rating: _userRating,
                );

                // 1. Add the new history item to global state
                HistoryService.addMeal(newHistoryItem);

                // 2. Pop all screens until back to RecipeDetailScreen or root
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.oliveSecondary,
                foregroundColor: AppColors.creamBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Save to Cooked History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. XP REWARD POPUP DIALOG WIDGET
// ============================================================================
class XpRewardDialog extends StatefulWidget {
  final int earnedXp;
  final int currentXp;
  final int xpPerLevel;
  final int startLevel;

  const XpRewardDialog({
    super.key,
    required this.earnedXp,
    required this.currentXp,
    required this.xpPerLevel,
    required this.startLevel,
  });

  @override
  State<XpRewardDialog> createState() => _XpRewardDialogState();
}

class _XpRewardDialogState extends State<XpRewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  late int _displayLevel;
  bool _didLevelUp = false;
  double _textOpacity = 0.0; // Starts hidden for smooth fade-in

  @override
  void initState() {
    super.initState();
    _displayLevel = widget.startLevel;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _runXpSequence();
  }

  void _runXpSequence() async {
    double startProgress = widget.currentXp / widget.xpPerLevel;
    int totalXp = widget.currentXp + widget.earnedXp;

    if (totalXp >= widget.xpPerLevel) {
      // 1. Animate bar fill up to 100%
      _progressAnimation = Tween<double>(begin: startProgress, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      await _controller.forward();

      // 2. Pause briefly at 100%
      await Future.delayed(const Duration(milliseconds: 250));

      // 3. Reset bar to 0% and animate leftover XP
      _controller.reset();
      double leftoverProgress = (totalXp - widget.xpPerLevel) / widget.xpPerLevel;

      _progressAnimation = Tween<double>(begin: 0.0, end: leftoverProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      await _controller.forward();

      // 4. Update level & trigger fade-in text
      if (mounted) {
        setState(() {
          _displayLevel = widget.startLevel + 1;
          _didLevelUp = true;
          _textOpacity = 1.0;
        });
      }
    } else {
      // Normal XP gain without level up
      double endProgress = totalXp / widget.xpPerLevel;
      _progressAnimation = Tween<double>(begin: startProgress, end: endProgress).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      await _controller.forward();

      if (mounted) {
        setState(() {
          _textOpacity = 1.0;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Prevents memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(28.0),
        decoration: BoxDecoration(
          color: AppColors.creamBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Gold Star Badge (Changed to Terracotta)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.terracottaAccent, // 👈 Swapped to Terracotta
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 12),

            // XP Text Header
            Text(
              '+${widget.earnedXp} XP EARNED!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // Animated Progress Bar with 0 and Max Labels
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _progressAnimation.value,
                        minHeight: 14,
                        backgroundColor: Colors.amber.shade100,
                        color: AppColors.terracottaAccent, // 👈 Swapped to Terracotta
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '0 xp',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracottaAccent, // 👈 Swapped to Terracotta
                          ),
                        ),
                        Text(
                          '${widget.xpPerLevel} xp',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.terracottaAccent, // 👈 Swapped to Terracotta
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),

            // Delayed Fade-in Level Text Underneath
            AnimatedOpacity(
              opacity: _textOpacity,
              duration: const Duration(milliseconds: 500),
              child: Text(
                _didLevelUp
                    ? '🎉 LEVEL UP! You are now Level $_displayLevel!'
                    : 'Current Level: $_displayLevel',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.oliveSecondary, // 👈 Changed to Olive for high contrast
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Dismiss Button (Changed to Terracotta)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracottaAccent, // 👈 Swapped to Terracotta
                  foregroundColor: AppColors.creamBackground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.of(context).pop(), // Closes popup
                child: const Text(
                  'Awesome!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetInputSection extends StatefulWidget {
  // Pass the restaurant price from your Recipe model here!
  final double restaurantAverage; 
  final ValueChanged<double> onSavingsCalculated;

  const BudgetInputSection({
    super.key, 
    required this.restaurantAverage,
    required this.onSavingsCalculated,
  });

  @override
  State<BudgetInputSection> createState() => _BudgetInputSectionState();
}

class _BudgetInputSectionState extends State<BudgetInputSection> {
  final TextEditingController _spentController = TextEditingController();

  bool _isSubmitted = false;
  double _savings = 0.0; 
  
  void _onCalculate() {
    // 1. Remove extra whitespaces
    String rawText = _spentController.text.trim();

    // 2. FAILSAFE: Check if empty
    if (rawText.isEmpty) {
      _showErrorSnackBar('Please enter the amount you spent.');
      return;
    }

    // 3. FAILSAFE: Try converting to double
    double? spentAmount = double.tryParse(rawText);

    // 4. FAILSAFE: Check for invalid input or negative numbers
    if (spentAmount == null || spentAmount < 0) {
      _showErrorSnackBar('Please enter a valid dollar amount.');
      return;
    }

    // 5. If everything is valid, proceed!
    setState(() {
      _savings = widget.restaurantAverage - spentAmount;
      _isSubmitted = true; // Locks field and shows results
    });

    widget.onSavingsCalculated(_savings);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onEdit() {
    setState(() {
      _isSubmitted = false; // Unlocks field to allow edits
    });
  }

  @override
  void dispose() {
    _spentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool savedMoney = _savings >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How much did you spend on ingredients?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.creamBackground),
          ),
          const SizedBox(height: 4),
          Text(
            'On average, this meal costs \$${widget.restaurantAverage.toStringAsFixed(2)} at a restaurant.',
            style: const TextStyle(fontSize: 13, color: AppColors.creamBackground),
          ),
          const SizedBox(height: 12),

          // --- TEXTFIELD WITH FAILSAFE FORMATTERS ---
          TextField(
            style: const TextStyle(
              color: AppColors.terracottaAccent, // Or any color you want for user input
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            controller: _spentController,
            enabled: !_isSubmitted,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            // 🛡️ FAILSAFE: Prevents non-numeric characters and limits to 2 decimal places
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                color: AppColors.terracottaAccent, // Style the "0.00" hint here
                fontSize: 18,
              ),
              hintText: '0.00',
              hintStyle: const TextStyle(
                color: AppColors.terracottaAccent, // Style the "0.00" hint here
                fontSize: 18,
              ),
              filled: true,
              fillColor: _isSubmitted
                  ? const Color(0xFFE9ECEF)
                  : const Color(0xFFF1F3F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- CALCULATE BUTTON ---
          if (!_isSubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracottaAccent,
                  foregroundColor: AppColors.creamBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _onCalculate,
                child: const Text(
                  'Calculate Savings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          // --- RESULTS + EDIT BUTTON ---
          if (_isSubmitted) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 1. Wrapped in Expanded so long strings wrap cleanly onto new lines!
                Expanded(
                  child: Text(
                    savedMoney
                        ? '🎉 You saved \$${_savings.abs().toStringAsFixed(2)} vs. eating out!'
                        : '💸 You spent \$${_savings.abs().toStringAsFixed(2)} more than eating out!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.creamBackground,
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Keeps a slight gap before the button

                // 2. The Edit Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.black26),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class RatingSection extends StatefulWidget {
  // Callback accepts int? so it can pass null if unselected
  final ValueChanged<int?> onRatingChanged;

  const RatingSection({
    super.key,
    required this.onRatingChanged,
  });

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
  // Starts as null (no stars selected!)
  int? _selectedRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'How did it turn out?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.creamBackground),
          ),
          const SizedBox(height: 12),

          // --- 5-STAR RATING ROW ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              int starNumber = index + 1;
              // Check if selected (if _selectedRating is null, this is false for all stars)
              bool isSelected = _selectedRating != null && starNumber <= _selectedRating!;

              return IconButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = starNumber;
                  });
                  // Pass the chosen rating to parent
                  widget.onRatingChanged(_selectedRating);
                },
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  // 1. Terracotta pop when selected, soft cream outline when unselected
                  color: isSelected 
                      ? AppColors.terracottaAccent 
                      : AppColors.creamBackground.withValues(alpha: 0.4),
                  size: 36,
                )
              );
            }),
          ),
        ],
      ),
    );
  }
}