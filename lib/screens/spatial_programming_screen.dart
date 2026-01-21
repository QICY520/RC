import 'package:flutter/material.dart';
import 'package:ruanchuang/theme/app_colors.dart';
import 'package:ruanchuang/theme/app_text_styles.dart';
import 'package:ruanchuang/widgets/ui/aim_box.dart';

/// Full-screen spatial programming mock: AR area + coding table + drawer.
class SpatialProgrammingScreen extends StatefulWidget {
  const SpatialProgrammingScreen({super.key});

  @override
  State<SpatialProgrammingScreen> createState() =>
      _SpatialProgrammingScreenState();
}

class _SpatialProgrammingScreenState extends State<SpatialProgrammingScreen>
    with SingleTickerProviderStateMixin {
  bool _drawerOpen = false;
  List<String> _logicBlocks = [];
  bool _isRunning = false;
  bool _dadSeated = false;
  bool _acOn = false;

  final List<_BlockItem> _inventory = [
    _BlockItem(icon: Icons.man_outlined, label: '爸爸'),
    _BlockItem(icon: Icons.person_outline, label: '妈妈'),
    _BlockItem(icon: Icons.ac_unit_outlined, label: '空调'),
    _BlockItem(icon: Icons.chair_outlined, label: '沙发'),
    _BlockItem(icon: Icons.extension, label: '当'),
    _BlockItem(icon: Icons.extension, label: '如果'),
    _BlockItem(icon: Icons.extension, label: '然后'),
    _BlockItem(icon: Icons.event_seat_outlined, label: '坐下'),
    _BlockItem(icon: Icons.power_settings_new, label: '打开'),
  ];

  static const _lampItem =
      _BlockItem(icon: Icons.lightbulb_outline, label: '台灯积木');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final bottomHeight = size.height * 0.45;
          final topHeight = size.height - bottomHeight;

          return Stack(
            children: [
              // Background camera feed placeholder
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg_living_room.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              // AR demo area
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topHeight,
                child: _ArActors(
                  dadSeated: _dadSeated,
                  acOn: _acOn,
                ),
              ),
              // Camera entry button
              Positioned(
                top: 24,
                right: 16,
                child: Material(
                  color: Colors.black.withOpacity(0.4),
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.textPrimary),
                    onPressed: _openPhotoCapture,
                  ),
                ),
              ),
              // Bottom panel with run + coding table
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: bottomHeight,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Row(
                          children: [
                            const Spacer(),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _logicBlocks.isEmpty ? null : _runLogic,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('运行'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: CodingTable(
                            blocks: _logicBlocks,
                            onMicTap: _handleMicInput,
                            onDrop: _handleDropBlock,
                            onDelete: _handleDeleteBlock,
                            colorFor: _colorForLabel,
                            canViewCode: _isLogicValid(_logicBlocks),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Drawer menu on the left
              Align(
                alignment: Alignment.centerLeft,
                child: DrawerMenu(
                  isOpen: _drawerOpen,
                  onToggle: () => setState(() => _drawerOpen = !_drawerOpen),
                  items: _inventory,
                  colorFor: _colorForLabel,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addLampItem() {
    if (!_inventory.contains(_lampItem)) {
      setState(() {
        _inventory.insert(0, _lampItem);
      });
    }
  }

  void _handleMicInput() {
    // Toast-like prompt
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          '正在聆听...',
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    // Mock parsed blocks
    const parsed = ['当', '爸爸', '坐下', '空调', '打开'];
    setState(() {
      _logicBlocks = parsed;
    });
  }

  bool _isLogicValid(List<String> blocks) {
    // Required sequence: 当 爸爸 坐下 空调 打开
    const expected = ['当', '爸爸', '坐下', '空调', '打开'];
    if (blocks.length != expected.length) return false;
    for (var i = 0; i < expected.length; i++) {
      if (blocks[i] != expected[i]) return false;
    }
    return true;
  }

  void _handleDropBlock(Object data, int? targetIndex) {
    setState(() {
      // From drawer
      if (data is _BlockItem) {
        final insertAt = targetIndex ?? _logicBlocks.length;
        _logicBlocks =
            [..._logicBlocks]..insert(insertAt.clamp(0, _logicBlocks.length), data.label);
        return;
      }
      // Reorder from existing chips
      if (data is _DragPayload) {
        final from = data.fromIndex;
        var to = targetIndex ?? _logicBlocks.length;
        if (from < 0 || from >= _logicBlocks.length) return;
        final list = [..._logicBlocks];
        final item = list.removeAt(from);
        // adjust target if removal before target
        if (from < to) to -= 1;
        to = to.clamp(0, list.length);
        list.insert(to, item);
        _logicBlocks = list;
      }
    });
  }

  void _handleDeleteBlock(Object data) {
    setState(() {
      if (_logicBlocks.isEmpty) return;
      if (data is _DragPayload) {
        final from = data.fromIndex;
        if (from < 0 || from >= _logicBlocks.length) return;
        final list = [..._logicBlocks]..removeAt(from);
        _logicBlocks = list;
        return;
      }
      if (data is _BlockItem) {
        final idx = _logicBlocks.indexOf(data.label);
        if (idx == -1) return;
        final list = [..._logicBlocks]..removeAt(idx);
        _logicBlocks = list;
      }
    });
  }

  Future<void> _runLogic() async {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _dadSeated = true;
      _acOn = false;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _acOn = true;
      _isRunning = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surface,
        content: Text(
          '逻辑执行成功！',
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  void _openPhotoCapture() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoCaptureScreen(
          onExtract: () {
            _addLampItem();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.surface,
                content: Text(
                  '台灯积木已加入背包！',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _colorForLabel(String label) {
    if (label == '爸爸' || label == '妈妈') return AppColors.blockRole;
    if (label == '空调' || label == '沙发' || label.contains('台灯')) {
      return AppColors.blockDevice;
    }
    if (label == '坐下' || label == '打开') return AppColors.blockAction;
    if (label == '当' || label == '如果' || label == '然后') {
      return AppColors.blockLogic;
    }
    return AppColors.surfaceMuted;
  }
}

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.items,
    required this.colorFor,
  });

  final bool isOpen;
  final VoidCallback onToggle;
  final List<_BlockItem> items;
  final Color Function(String) colorFor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: isOpen ? 240 : 56,
      height: 340,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Icon(
                Icons.backpack_outlined,
                color: AppColors.textPrimary,
              ),
              if (isOpen) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _DraggableBlock(item: item, colorFor: colorFor);
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockItem {
  const _BlockItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _DragPayload {
  const _DragPayload({required this.label, required this.fromIndex});
  final String label;
  final int fromIndex;
}

class _DraggableBlock extends StatelessWidget {
  const _DraggableBlock({required this.item, required this.colorFor});
  final _BlockItem item;
  final Color Function(String) colorFor;

  @override
  Widget build(BuildContext context) {
    final color = colorFor(item.label);
    final child = _BlockCard(item: item, color: color);
    return Draggable<_BlockItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 80,
          child: child,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: child,
      ),
      child: child,
    );
  }
}

class _BlockCard extends StatelessWidget {
  const _BlockCard({required this.item, required this.color});
  final _BlockItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: AppColors.background),
          const SizedBox(height: 6),
          Text(
            item.label,
            style: AppTextStyles.body.copyWith(
              color: AppColors.background,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReorderChip extends StatelessWidget {
  const _ReorderChip({
    required this.label,
    required this.color,
    required this.index,
    required this.onDrop,
  });

  final String label;
  final Color color;
  final int index;
  final void Function(Object, int? targetIndex) onDrop;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.body.copyWith(
          color: AppColors.background,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Draggable<_DragPayload>(
      data: _DragPayload(label: label, fromIndex: index),
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 90,
          child: chip,
        ),
      ),
      affinity: Axis.horizontal,
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: chip,
      ),
      child: DragTarget<Object>(
        onWillAccept: (_) => true,
        onAccept: (data) => onDrop(data, index),
        builder: (context, cand, rej) {
          final hovering = cand.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: hovering
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary, width: 2),
                  )
                : null,
            child: chip,
          );
        },
      ),
    );
  }
}

class _ArActors extends StatelessWidget {
  const _ArActors({
    required this.dadSeated,
    required this.acOn,
  });

  final bool dadSeated;
  final bool acOn;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0.1, 0.2),
          child: _ImageCard(
            asset: dadSeated
                ? 'assets/images/dad_sit.png'
                : 'assets/images/dad_stand.png',
            label: dadSeated ? '爸爸（坐下）' : '爸爸（站立）',
          ),
        ),
        Align(
          alignment: const Alignment(0.6, -0.1),
          child: _ImageCard(
            asset: acOn ? 'assets/images/ac_on.png' : 'assets/images/ac_off.png',
            label: acOn ? '空调（出风）' : '空调（关闭）',
          ),
        ),
      ],
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.surface.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              asset,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: AppColors.surfaceMuted,
                alignment: Alignment.center,
                child: Text(
                  '缺少图片\n$asset',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _PhotoCaptureScreen extends StatefulWidget {
  const _PhotoCaptureScreen({required this.onExtract});
  final VoidCallback onExtract;

  @override
  State<_PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<_PhotoCaptureScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flyController;
  bool _isExtracting = false;

  @override
  void initState() {
    super.initState();
    _flyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _flyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final aimPos = Offset(size.width * 0.62, size.height * 0.5);
          final bagPos = Offset(32, size.height / 2);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bg_living_room.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 16,
                top: 40,
                child: SafeArea(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('返回'),
                  ),
                ),
              ),
              // Aim box + extract
              Positioned(
                left: aimPos.dx - 120 / 2,
                top: aimPos.dy - 120 / 2,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const AimBox(size: 120),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isExtracting ? null : () => _startExtract(aimPos, bagPos),
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('提取'),
                    ),
                  ],
                ),
              ),
              // bag icon target
              Positioned(
                left: 8,
                top: size.height / 2 - 24,
                child: Icon(Icons.backpack_outlined,
                    size: 32, color: AppColors.textPrimary),
              ),
              if (_isExtracting)
                AnimatedBuilder(
                  animation: _flyController,
                  builder: (context, _) {
                    final t = CurvedAnimation(
                      parent: _flyController,
                      curve: Curves.easeInOut,
                    ).value;
                    final current = Offset.lerp(aimPos, bagPos, t)!;
                    return Positioned(
                      left: current.dx - 16,
                      top: current.dy - 16,
                      child: Icon(
                        Icons.lightbulb_outline,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startExtract(Offset aimPos, Offset bagPos) async {
    if (_isExtracting) return;
    setState(() => _isExtracting = true);
    await _flyController.forward(from: 0);
    if (!mounted) return;
    widget.onExtract();
    setState(() => _isExtracting = false);
    Navigator.of(context).pop();
  }
}

class CodingTable extends StatefulWidget {
  const CodingTable({
    super.key,
    required this.blocks,
    required this.onMicTap,
    required this.onDrop,
    required this.onDelete,
    required this.colorFor,
    required this.canViewCode,
  });

  final List<String> blocks;
  final VoidCallback onMicTap;
  final void Function(Object data, int? targetIndex) onDrop;
  final void Function(Object data) onDelete;
  final Color Function(String) colorFor;
  final bool canViewCode;

  @override
  State<CodingTable> createState() => _CodingTableState();
}

class _CodingTableState extends State<CodingTable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flipController;
  bool _isCodeView = false;
  _CodeLang _lang = _CodeLang.python;

  BoxDecoration get _decoration => BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      );

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _toggleView() {
    if (!_isCodeView && !widget.canViewCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface,
          content: Text(
            '逻辑未验证通过，暂不可查看源代码',
            style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
          ),
        ),
      );
      return;
    }
    setState(() => _isCodeView = !_isCodeView);
    if (_isCodeView) {
      _flipController.forward(from: 0);
    } else {
      _flipController.reverse(from: 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  _isCodeView ? '代码视图' : '积木视图',
                  style:
                      AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
                const Spacer(),
                if (_isCodeView)
                  _LangToggle(
                    value: _lang,
                    onChanged: (v) => setState(() => _lang = v),
                  ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _toggleView,
                  icon: Icon(
                    _isCodeView ? Icons.widgets_outlined : Icons.code,
                    color: widget.canViewCode || _isCodeView
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                  label: Text(
                    _isCodeView ? '返回积木' : '查看源代码',
                    style: AppTextStyles.body.copyWith(
                      color: widget.canViewCode || _isCodeView
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: AnimatedBuilder(
                animation: _flipController,
                builder: (context, _) {
                  final t = CurvedAnimation(
                    parent: _flipController,
                    curve: Curves.easeInOut,
                  ).value;
                  final angle = t * 3.1415926;

                  final showFront = angle <= 1.5707963;
                  final front = _BlocksView(
                    blocks: widget.blocks,
                    onDrop: widget.onDrop,
                    onDelete: widget.onDelete,
                    colorFor: widget.colorFor,
                  );
                  final back = _CodeView(
                    lines: _lang == _CodeLang.python
                        ? _pythonPseudo(widget.blocks)
                        : _cppPseudo(widget.blocks),
                  );

                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: showFront
                        ? front
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(3.1415926),
                            child: back,
                          ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: FloatingActionButton(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                onPressed: widget.onMicTap,
                mini: true,
                child: const Icon(Icons.mic),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _CodeLang { python, cpp }

class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.value, required this.onChanged});

  final _CodeLang value;
  final ValueChanged<_CodeLang> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(
            active: value == _CodeLang.python,
            label: 'Python',
            onTap: () => onChanged(_CodeLang.python),
          ),
          _Pill(
            active: value == _CodeLang.cpp,
            label: 'C++',
            onTap: () => onChanged(_CodeLang.cpp),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.active, required this.label, required this.onTap});
  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: active ? AppColors.background : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _BlocksView extends StatelessWidget {
  const _BlocksView({
    required this.blocks,
    required this.onDrop,
    required this.onDelete,
    required this.colorFor,
  });

  final List<String> blocks;
  final void Function(Object data, int? targetIndex) onDrop;
  final void Function(Object data) onDelete;
  final Color Function(String) colorFor;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAccept: (_) => true,
      onAccept: (data) => onDrop(data, blocks.length),
      builder: (context, candidate, rejected) {
        final hasCandidate = candidate.isNotEmpty;
        final currentBlocks = blocks;
        if (currentBlocks.isEmpty) {
          return Stack(
            children: [
              const Center(
                child: Text(
                  '拖拽积木到此处，组成逻辑',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              if (hasCandidate)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }

        final chips = <Widget>[];
        for (var i = 0; i < currentBlocks.length; i++) {
          final b = currentBlocks[i];
          chips.add(
            _ReorderChip(
              label: b,
              color: colorFor(b),
              index: i,
              onDrop: onDrop,
            ),
          );
        }
        // Trailing drop zone to append
        chips.add(
          DragTarget<Object>(
            onWillAccept: (_) => true,
            onAccept: (data) => onDrop(data, currentBlocks.length),
            builder: (context, cand, rej) => SizedBox(
              width: 32,
              height: 32,
              child: cand.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: AppColors.overlay,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 56),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: _TrashBin(onDelete: onDelete),
            ),
            if (hasCandidate)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.overlay,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TrashBin extends StatelessWidget {
  const _TrashBin({required this.onDelete});
  final void Function(Object data) onDelete;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Object>(
      onWillAccept: (_) => true,
      onAccept: onDelete,
      builder: (context, cand, rej) {
        final hovering = cand.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 48,
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: (hovering ? AppColors.danger : AppColors.surface)
                .withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hovering ? AppColors.danger : AppColors.border,
            ),
          ),
          child: Icon(
            Icons.delete_outline,
            color: hovering ? AppColors.background : AppColors.textPrimary,
          ),
        );
      },
    );
  }
}

class _CodeView extends StatelessWidget {
  const _CodeView({required this.lines});
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final lineNumber = (index + 1).toString().padLeft(2, '0');
          final line = lines[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    lineNumber,
                    style: AppTextStyles.code
                        .copyWith(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    line,
                    style: AppTextStyles.code.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

List<String> _pythonPseudo(List<String> blocks) {
  // minimal pseudo; only meaningful when logic matches.
  return const [
    '# pseudo (Python)',
    'if Dad.is_sitting:',
    '    AC.turn_on()',
  ];
}

List<String> _cppPseudo(List<String> blocks) {
  return const [
    '// pseudo (C++)',
    'if (Dad.isSitting()) {',
    '  AC::TurnOn();',
    '}',
  ];
}

