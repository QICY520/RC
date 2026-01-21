import 'package:flutter/material.dart';
import 'package:ruanchuang/mock/demo_scripts.dart';
import 'package:ruanchuang/theme/app_colors.dart';
import 'package:ruanchuang/theme/app_text_styles.dart';

/// Code editor placeholder with code/block toggle and intent chips.
class CodeEditorPlaceholder extends StatefulWidget {
  const CodeEditorPlaceholder({super.key, required this.lines});

  final List<String> lines;

  @override
  State<CodeEditorPlaceholder> createState() => _CodeEditorPlaceholderState();
}

class _CodeEditorPlaceholderState extends State<CodeEditorPlaceholder> {
  bool _isBlockView = false;

  List<String> get _codeLines =>
      widget.lines.isNotEmpty ? widget.lines : DemoScript.generatedCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  _isBlockView ? '积木视图' : '代码视图',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: AppColors.textSecondary),
                  onPressed: () {
                    setState(() => _isBlockView = !_isBlockView);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _isBlockView ? _buildBlocks() : _buildCode(),
            ),
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              children: const [
                _IntentChip(label: '妈妈'),
                SizedBox(width: 8),
                _IntentChip(label: '回家'),
                SizedBox(width: 8),
                _IntentChip(label: '开灯'),
                SizedBox(width: 8),
                _IntentChip(label: '欢迎音乐'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCode() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: _codeLines.length,
      itemBuilder: (context, index) {
        final lineNumber = (index + 1).toString().padLeft(2, '0');
        final line = _codeLines[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 32,
                child: Text(
                  lineNumber,
                  style: AppTextStyles.code.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  line,
                  style: AppTextStyles.code.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlocks() {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          '当 [妈妈] [回家]',
          style: AppTextStyles.body.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _IntentChip extends StatelessWidget {
  const _IntentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.background)),
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
    );
  }
}

