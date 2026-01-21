import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Text styles tuned for dark AR + coding experience.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle header = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle code = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'monospace',
    letterSpacing: 0.2,
    height: 1.5,
  );
}

