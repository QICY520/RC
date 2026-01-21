import 'package:flutter/material.dart';
import '../../mock/demo_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class CodeEditorPlaceholder extends StatelessWidget {
  const CodeEditorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: demoSnippets.length,
        separatorBuilder: (_, __) => Divider(
          color: AppColors.border,
          height: 24,
        ),
        itemBuilder: (context, index) {
          final snippet = demoSnippets[index].trimRight();
          final lines = snippet.split('\n');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Snippet ${index + 1}',
                  style: AppText.caption.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(lines.length, (lineIndex) {
                final lineNumber = lineIndex + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 36,
                        child: Text(
                          lineNumber.toString().padLeft(2, '0'),
                          style: AppText.caption,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          lines[lineIndex],
                          style: AppText.body.copyWith(
                            color: AppColors.textPrimary,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

