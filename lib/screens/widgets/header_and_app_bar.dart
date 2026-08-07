import 'package:charles_flutter_app_main/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/constants/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  // 1. Declare parameters (icon is optional with IconData?)
  final String headerText;
  final IconData? icon;
  final Color? iconColor;

  // 2. Constructor
  const HeaderWidget({
    super.key,
    required this.headerText,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: icon == null
          // 🔹 Case A: No icon provided (e.g. "Tier Lessons")
          ? Text(
              headerText,
              style: kHeaderTextStyle.copyWith(color: AppColors.oliveSecondary),
            )
          // 🔹 Case B: Icon provided (e.g. "Core Steps")
          : Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20, // Adjust size to match text height
                  color: iconColor ?? AppColors.terracottaAccent, // Default to terracotta accent if not passed
                ),
                const SizedBox(width: 8), // Gap between icon and text
                Text(
                  headerText,
                  style: kHeaderTextStyle.copyWith(color: AppColors.oliveSecondary),
                ),
              ],
            ),
    );
  }
}

// app bar widget

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.oliveSecondary,
      foregroundColor: AppColors.creamBackground,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
