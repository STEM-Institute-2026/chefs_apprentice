import 'package:charles_flutter_app_main/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/constants/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  final String headerText;
  final IconData? icon;
  final Color? iconColor;

  const HeaderWidget({
    super.key,
    required this.headerText,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Ensures the widget spans full screen width
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Center(
          child: icon == null
              ? Text(
                  headerText,
                  textAlign: TextAlign.center,
                  style: kHeaderTextStyle.copyWith(color: AppColors.oliveSecondary),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 24,
                      color: iconColor ?? AppColors.terracottaAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      headerText,
                      style: kHeaderTextStyle.copyWith(color: AppColors.oliveSecondary),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final double? leadingWidth;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.leadingWidth,
    this.actions,
    this.bottom,
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
      leadingWidth: leadingWidth ?? 56.0,
      leading: leading,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}