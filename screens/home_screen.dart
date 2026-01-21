import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/placeholders/ar_view_placeholder.dart';
import '../widgets/placeholders/code_editor_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: const Text('Home', style: AppText.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back, creator', style: AppText.headline),
            const SizedBox(height: 12),
            const Text(
              'Preview the AR scene and code output using the shared theme.',
              style: AppText.body,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: AppColors.primaryGlow,
                  ),
                  onPressed: () {},
                  child: const Text('Start'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Workspace'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: const [
                  Expanded(child: ArViewPlaceholder()),
                  SizedBox(width: 12),
                  Expanded(child: CodeEditorPlaceholder()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

