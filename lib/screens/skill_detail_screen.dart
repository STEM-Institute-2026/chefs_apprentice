import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/models.dart';
import 'widgets/header_and_app_bar.dart';
class SkillDetailScreen extends StatefulWidget {
  final SkillModel skill;

  const SkillDetailScreen({
    super.key,
    required this.skill,
  });

  @override
  State<SkillDetailScreen> createState() => _SkillDetailScreenState();
}

class _SkillDetailScreenState extends State<SkillDetailScreen> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() async {
  final videoPath = widget.skill.videoUrl;
  
  if (videoPath != null && videoPath.trim().isNotEmpty) {
    try {
      debugPrint('Initializing video at: $videoPath');
      
      _videoController = VideoPlayerController.asset(videoPath);
      await _videoController!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        await _videoController!.setVolume(0.0);
        await _videoController!.setLooping(true);
        await _videoController!.play();
      }
    } catch (error, stack) {
      debugPrint('❌ Video initialization failed for $videoPath: $error');
      debugPrint('Stack trace: $stack');
    }
  }
}

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  bool _hasValidImagePath(String? path) {
    return path != null && path.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: CustomAppBar(title: widget.skill.name),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. HERO VIDEO & SHORT DESCRIPTION
            _buildHeroVideoSection(),
            const SizedBox(height: 12),

            // 2. CORE STEPS SECTION
            HeaderWidget(
              headerText: 'Core Steps',
              icon: Icons.restaurant_rounded,
              iconColor: AppColors.terracottaAccent,
            ),
            const SizedBox(height: 12),
            _buildStepsList(),
            const SizedBox(height: 12),

            // 3. KEY CUTS & TYPES
            if (widget.skill.keyTypesOrCuts.isNotEmpty) ...[
              HeaderWidget(
                headerText: 'Key Cuts & Types',
                icon: Icons.cut_rounded,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 12),
              _buildKeyCutsCard(),
              const SizedBox(height: 12),
            ],

            // 4. SAFETY & PRO TIPS
            if (widget.skill.safetyOrProTips.isNotEmpty) ...[
              HeaderWidget(
                headerText: 'Pro Tips & Safety',
                icon: Icons.lightbulb_outline_rounded,
                iconColor: AppColors.terracottaAccent,
              ),
              const SizedBox(height: 12),
              _buildProTipsCard(),
              const SizedBox(height: 24),
            ],

            // 5. WHERE IT'S USED
            if (widget.skill.whereItsUsed.isNotEmpty) ...[
              _buildWhereItsUsedCard(),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGET BUILDERS
  // ==========================================

  Widget _buildHeroVideoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary,
        borderRadius: BorderRadius.circular(20),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _isVideoInitialized &&
                      _videoController != null &&
                      _videoController!.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: _videoController!.value.size.width,
                        height: _videoController!.value.size.height,
                        child: VideoPlayer(_videoController!),
                      ),
                    )
                  : Container(
                      color: AppColors.oliveSecondary,
                      child: Center(
                        child: Icon(
                          widget.skill.icon,
                          size: 48,
                          color: AppColors.creamBackground.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.skill.shortDescription,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.creamBackground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.skill.coreSteps.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final step = widget.skill.coreSteps[index];
        final stepNumber = index + 1;

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.oliveSecondary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.terracottaAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.oliveSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(
                  step.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
              ),
              if (_hasValidImagePath(step.imagePath)) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      step.imagePath!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildKeyCutsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: widget.skill.keyTypesOrCuts.map((item) {
          final parts = item.split(': ');
          final title = parts[0];
          final description = parts.length > 1 ? parts[1] : '';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 6, color: AppColors.oliveSecondary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                      children: [
                        TextSpan(
                          text: '$title: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.oliveSecondary,
                          ),
                        ),
                        TextSpan(text: description),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: widget.skill.safetyOrProTips.map((tip) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 18,
                  color: AppColors.creamBackground,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: AppColors.creamBackground,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWhereItsUsedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHERE IT\'S USED',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: AppColors.oliveSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.skill.whereItsUsed,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}