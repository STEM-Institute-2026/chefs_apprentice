import 'package:charles_flutter_app_main/constants/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:charles_flutter_app_main/constants/app_colors.dart';

class HeaderWidget extends StatelessWidget {
  // 1. Declare any parameters passed into this widget
  final String headerText;

  // 2. Constructor with super key
  const HeaderWidget({
    super.key,
    required this.headerText,
  });

  // 3. The build method that returns your UI
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        headerText,
        style: kHeaderTextStyle.copyWith(color: AppColors.oliveSecondary),
      ),
    );
  }
}