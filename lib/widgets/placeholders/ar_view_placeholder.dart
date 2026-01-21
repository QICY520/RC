import 'package:flutter/material.dart';
import 'package:ruanchuang/theme/app_colors.dart';
import 'package:ruanchuang/theme/app_text_styles.dart';

/// AR view placeholder; shows camera icon by default and a lamp when loaded.
class ArViewPlaceholder extends StatelessWidget {
  const ArViewPlaceholder({super.key, required this.hasObject});

  final bool hasObject;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasObject ? Icons.lightbulb_outline : Icons.camera_alt_outlined,
              size: 56,
              color: hasObject ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              hasObject ? '模型已加载' : 'AR preview',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }
}

