import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import '../../services/history_service.dart';
import '../recipe_detail_screen.dart';


class RecipeCatalogCard extends StatefulWidget {
  final RecipeModel recipe;

  const RecipeCatalogCard({
    super.key,
    required this.recipe,
  });

  @override
  State<RecipeCatalogCard> createState() => _RecipeCatalogCardState();
}

class _RecipeCatalogCardState extends State<RecipeCatalogCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Navigate to detail screen and rebuild when returning to keep favorites synced
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: widget.recipe),
          ),
        );
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image + Favorite Button Overlay
            Expanded(
              child: Stack(
                children: [
                  // Recipe Image
                  Positioned.fill(
                    child: Image.network(
                      widget.recipe.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.restaurant,
                            color: Colors.grey,
                            size: 36,
                          ),
                        );
                      },
                    ),
                  ),

                  if (HistoryService.isRecipeCompleted(widget.recipe.recipeId))
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.terracottaAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: AppColors.creamBackground, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Made',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Favorite Button Overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            HistoryService.toggleFavorite(widget.recipe.recipeId);
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Icon(
                            HistoryService.isRecipeFavorite(widget.recipe.recipeId)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: HistoryService.isRecipeFavorite(widget.recipe.recipeId)
                                ? Colors.red
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Recipe Title
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.recipe.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}