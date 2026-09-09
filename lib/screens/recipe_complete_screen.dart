import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';

import "../models/models.dart"; 
import 'photo_upload_box.dart';
import '../services/history_service.dart';
import '../services/badge_evaluator_service.dart';
import '../services/data_loader_service.dart';
import 'widgets/header_and_app_bar.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart'; // For kIsWeb check
import '../services/image_upload_service.dart';

class RecipeCompleteScreen extends StatefulWidget {
  final RecipeModel recipe;


  const RecipeCompleteScreen({
    super.key, 
    required this.recipe // <-- Added AppData dependency
  });

  @override
  State<RecipeCompleteScreen> createState() => _RecipeCompleteScreenState();
}

  class _RecipeCompleteScreenState extends State<RecipeCompleteScreen> {
    double? _calculatedSavings;
    XFile? _selectedPhotoFile;
    int? _userRating;
    bool _isSaving = false; // Tracks saving state to prevent double-clicks

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        const int xpEarned = 500;
        final snapshot = HistoryService.addXp(xpEarned);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => XpRewardDialog(
            earnedXp: snapshot.xpEarned,
            startXp: snapshot.startXp,
            startLevel: snapshot.startLevel,
            getXpForLevel: HistoryService.getXpForLevel,
          ),
        );
      });
    }

    // Save Meal Logic
    Future<void> _handleSaveMeal() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // 1. Load app data on the fly using your DataLoaderService
      final AppData appData = await DataLoaderService.loadInitialData();

      String persistentPath = '';

      if (_selectedPhotoFile != null) {
        if (kIsWeb) {
          final uploadedUrl = await ImageUploadService.uploadToImgBB(_selectedPhotoFile!);
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            persistentPath = uploadedUrl;
          } else {
            throw Exception('Failed to upload image to host.');
          }
        } else {
          final appDir = await path_provider.getApplicationDocumentsDirectory();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(_selectedPhotoFile!.path)}';
          final File localImage = await File(_selectedPhotoFile!.path).copy('${appDir.path}/$fileName');
          persistentPath = localImage.path;
        }
      }

      final newHistoryItem = CookedHistoryModel(
        entryId: DateTime.now().millisecondsSinceEpoch.toString(),
        recipeId: widget.recipe.recipeId,
        recipeTitle: widget.recipe.title,
        imagePath: persistentPath,
        dateCooked: DateTime.now(),
        costSaved: _calculatedSavings,
        rating: _userRating,
      );

      // 2. Pass the freshly loaded data into HistoryService
      final List<BadgeUnlockResult> newlyUnlocked = await HistoryService.addMeal(
        meal: newHistoryItem,
        badges: appData.badges,
        cuisineModules: appData.cuisineModules,
        skillModules: appData.skillModules,
      );

      if (!mounted) return;

      // 3. Navigate back to root/home screen
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 4. Show celebration popup if any badges leveled up
      if (newlyUnlocked.isNotEmpty) {
        _showBadgeUnlockDialog(context, newlyUnlocked);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save meal: $e')),
      );
    }
  }

  // Badge level-up dialog launcher
  void _showBadgeUnlockDialog(BuildContext context, List<BadgeUnlockResult> unlocks) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.creamBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          title: Column(
            children: [
              // Top Terracotta Circle with White Star
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.terracottaAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Badge Leveled Up!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: unlocks.map((unlock) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.terracottaAccent, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        unlock.badge.iconPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.workspace_premium,
                          size: 32,
                          color: AppColors.terracottaAccent,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    unlock.badge.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    'Reached Star Level ${unlock.newStarLevel}!',
                    style: const TextStyle(
                      color: AppColors.oliveSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            // Full-width Terracotta Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracottaAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text(
                  'Awesome!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: const CustomAppBar(title: "Meal Complete!"),
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
                  _selectedPhotoFile = image;
                });
              },
            ),
            const SizedBox(height: 16),
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
              onPressed: _isSaving ? null : _handleSaveMeal,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.oliveSecondary,
                foregroundColor: AppColors.creamBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.creamBackground,
                      ),
                    )
                  : const Text(
                      'Save to Cooked History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
  final int startLevel;
  final int startXp;
  final int earnedXp;
  final int Function(int level) getXpForLevel;

  const XpRewardDialog({
    super.key,
    required this.startLevel,
    required this.startXp,
    required this.earnedXp,
    required this.getXpForLevel,
  });

  @override
  State<XpRewardDialog> createState() => _XpRewardDialogState();
}

class _XpRewardDialogState extends State<XpRewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late ConfettiController _confettiController;

  late int _displayLevel;
  late int _currentMaxXp;
  bool _didLevelUp = false;
  double _textOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _displayLevel = widget.startLevel;
    _currentMaxXp = widget.getXpForLevel(widget.startLevel);

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    final double initialProgress =
        _currentMaxXp > 0 ? (widget.startXp / _currentMaxXp).clamp(0.0, 1.0) : 0.0;
    _progressAnimation = AlwaysStoppedAnimation<double>(initialProgress);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _runXpSequence();
  }

  void _runXpSequence() async {
    int currentLevel = widget.startLevel;
    int currentXp = widget.startXp;
    int remainingXpToEarn = widget.earnedXp;

    while (remainingXpToEarn > 0) {
      if (!mounted) return;

      int maxForCurrentLevel = widget.getXpForLevel(currentLevel);

      if (mounted) {
        setState(() {
          _displayLevel = currentLevel;
          _currentMaxXp = maxForCurrentLevel;
        });
      }

      int xpNeededToFill = maxForCurrentLevel - currentXp;

      if (remainingXpToEarn >= xpNeededToFill) {
        double startProgress = (currentXp / maxForCurrentLevel).clamp(0.0, 1.0);
        _progressAnimation = Tween<double>(begin: startProgress, end: 1.0).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
        await _controller.forward();

        await Future.delayed(const Duration(milliseconds: 250));

        remainingXpToEarn -= xpNeededToFill;
        currentLevel++;
        currentXp = 0;

        _controller.reset();

        if (mounted) {
          setState(() {
            _displayLevel = currentLevel;
            _currentMaxXp = widget.getXpForLevel(currentLevel);
            _didLevelUp = true;
            _progressAnimation = const AlwaysStoppedAnimation<double>(0.0);
          });

          _confettiController.play();
        }

        await Future.delayed(const Duration(milliseconds: 100));
      } else {
        double startProgress = (currentXp / maxForCurrentLevel).clamp(0.0, 1.0);
        double endProgress =
            ((currentXp + remainingXpToEarn) / maxForCurrentLevel).clamp(0.0, 1.0);

        _progressAnimation = Tween<double>(begin: startProgress, end: endProgress).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
        );
        await _controller.forward();

        currentXp += remainingXpToEarn;
        remainingXpToEarn = 0;
      }
    }

    if (mounted) {
      setState(() {
        _textOpacity = 1.0;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: AppColors.creamBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.terracottaAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star_rounded, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  '+${widget.earnedXp} XP EARNED!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
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
                            color: AppColors.terracottaAccent,
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
                                color: AppColors.terracottaAccent,
                              ),
                            ),
                            Text(
                              '$_currentMaxXp xp',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.terracottaAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
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
                      color: AppColors.oliveSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracottaAccent,
                      foregroundColor: AppColors.creamBackground,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Awesome!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.terracottaAccent,
                AppColors.oliveSecondary,
                Colors.amber,
                Colors.orange,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetInputSection extends StatefulWidget {
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
    String rawText = _spentController.text.trim();

    if (rawText.isEmpty) {
      _showErrorSnackBar('Please enter the amount you spent.');
      return;
    }

    double? spentAmount = double.tryParse(rawText);

    if (spentAmount == null || spentAmount < 0) {
      _showErrorSnackBar('Please enter a valid dollar amount.');
      return;
    }

    setState(() {
      _savings = widget.restaurantAverage - spentAmount;
      _isSubmitted = true;
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
      _isSubmitted = false;
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

          TextField(
            style: const TextStyle(
              color: AppColors.terracottaAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            controller: _spentController,
            enabled: !_isSubmitted,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                color: AppColors.terracottaAccent,
                fontSize: 18,
              ),
              hintText: '0.00',
              hintStyle: const TextStyle(
                color: AppColors.terracottaAccent,
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

          if (_isSubmitted) ...[
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    savedMoney
                        ? '🎉 You saved \$${_savings.abs().toStringAsFixed(2)} vs. eating out!'
                        : '💸 You spent \$${_savings.abs().toStringAsFixed(2)} more than eating out!',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.creamBackground,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

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
  final ValueChanged<int?> onRatingChanged;

  const RatingSection({
    super.key,
    required this.onRatingChanged,
  });

  @override
  State<RatingSection> createState() => _RatingSectionState();
}

class _RatingSectionState extends State<RatingSection> {
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              int starNumber = index + 1;
              bool isSelected = _selectedRating != null && starNumber <= _selectedRating!;

              return IconButton(
                onPressed: () {
                  setState(() {
                    _selectedRating = starNumber;
                  });
                  widget.onRatingChanged(_selectedRating);
                },
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isSelected 
                      ? AppColors.terracottaAccent 
                      : AppColors.creamBackground.withValues(alpha: 0.4),
                  size: 36,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}