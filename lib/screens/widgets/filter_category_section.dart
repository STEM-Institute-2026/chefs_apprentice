import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class FilterCategorySection extends StatelessWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(String option) onOptionToggled;

  const FilterCategorySection({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onOptionToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🫒 Olive Category Title
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 20,
              color: Colors.black
            ),
          ),
          const SizedBox(height: 10),

          // 🏷️ Styled Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);

              return FilterChip(
                label: Text(option),
                selected: isSelected,
                
                // 🍊 Checkmark enabled & styled orange/terracotta
                showCheckmark: true,
                checkmarkColor: AppColors.terracottaAccent,
                
                // 🎨 Background Colors
                backgroundColor: AppColors.creamBackground, // Cream background when unclicked
                selectedColor: AppColors.oliveSecondary,
                
                // 🔲 Olive Border when unclicked
                side: const BorderSide(
                  color: AppColors.oliveSecondary,
                  width: 1.0,
                ),

                // 🏷️ Text Styling
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.creamBackground // Cream text when clicked
                      : AppColors.oliveSecondary, // Olive text when unclicked
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (_) => onOptionToggled(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}