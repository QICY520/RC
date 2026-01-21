import 'package:flutter/material.dart';
import 'package:ruanchuang/mock/demo_scripts.dart';
import 'package:ruanchuang/theme/app_colors.dart';
import 'package:ruanchuang/widgets/placeholders/ar_view_placeholder.dart';
import 'package:ruanchuang/widgets/placeholders/code_editor_placeholder.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({super.key});

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  late List<String> _codeLines;
  bool _hasObject = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _codeLines = List.of(DemoScript.initialCode);
  }

  Future<void> _handleMicTap() async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);

    // Show listening dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          content: const Text(
            '正在听你说...',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        );
      },
    ).timeout(const Duration(milliseconds: 1500), onTimeout: () {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    });

    // Ensure dialog closed
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    // Simulate AI thinking
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _codeLines = [
        ..._codeLines,
        ...DemoScript.generatedCode,
      ];
      _hasObject = true;
      _isGenerating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          DemoScript.aiResponse,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        onPressed: _handleMicTap,
        child: const Icon(Icons.mic),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(flex: 6, child: ArViewPlaceholder(hasObject: _hasObject)),
            const SizedBox(height: 12),
            Expanded(flex: 4, child: CodeEditorPlaceholder(lines: _codeLines)),
          ],
        ),
      ),
    );
  }
}

