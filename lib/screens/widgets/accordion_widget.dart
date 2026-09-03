import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/models/models.dart';
import 'recipe_card.dart';

class AccordionWidget extends StatelessWidget {
  final String title;
  final List<RecipeModel> recipes;
  final bool initiallyExpanded;

  const AccordionWidget({
    super.key,
    required this.title,
    required this.recipes,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: AppColors.oliveSecondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          backgroundColor: AppColors.oliveSecondary,
          collapsedBackgroundColor: AppColors.oliveSecondary,
          iconColor: AppColors.creamBackground,
          collapsedIconColor: AppColors.creamBackground,
          leading: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.creamBackground,
            size: 24,
          ),
          trailing: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.creamBackground,
            size: 24,
          ),
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 6.0,
          ),
          title: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.creamBackground,
              ),
            ),
          ),
          children: [
            Divider(
              color: AppColors.creamBackground.withValues(alpha: 0.3),
              height: 1,
              thickness: 1,
            ),
            Container(
              width: double.infinity,
              color: AppColors.oliveSecondary,
              padding: const EdgeInsets.all(16.0),
              child: recipes.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'No recipes available for this section.',
                          style: TextStyle(
                            color: AppColors.creamBackground,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recipes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        return RecipeCatalogCard(recipe: recipes[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}