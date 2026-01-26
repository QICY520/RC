import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ARCodingPage3D(),
  ));
}

class ARCodingPage3D extends StatefulWidget {
  const ARCodingPage3D({super.key});

  @override
  State<ARCodingPage3D> createState() => _ARCodingPage3DState();
}

class _ARCodingPage3DState extends State<ARCodingPage3D> {
  // 1. 颜色定义
  final Color triggerColor = const Color(0xFFFFD166);
  final Color actionColor = const Color(0xFF118AB2);
  final Color logicColor = const Color(0xFFEF476F);
  final Color bgGridColor = const Color(0xFFF0F4F8);

  // 2. 交互状态
  int? _selectedCategoryIndex;
  
  // 3. 舞台中的积木数据
  final List<BlockData> _placedBlocks = [];

  // 是否正在拖拽舞台上的积木
  bool _isDraggingPlacedBlock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGridColor,
      body: Column(
        children: [
          Expanded(flex: 6, child: _buildARView(context)),
          Expanded(
            flex: 4,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSidebar(),
                Expanded(
                  flex: _selectedCategoryIndex != null ? 3 : 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedCategoryIndex != null
                        ? _buildDrawerContent(_selectedCategoryIndex!)
                        : const SizedBox.shrink(),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: _buildStageArea(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 核心：搭建舞台 ---
  Widget _buildStageArea() {
    return DragTarget<BlockData>(
      onWillAccept: (data) {
        if (data == null) return false;
        final isExisting = _placedBlocks.any((b) => b.id == data.id);
        return !isExisting; 
      },
      onAccept: (data) {
        setState(() {
          _placedBlocks.add(BlockData(data.label, data.icon, data.color));
        });
      },
      builder: (context, candidate, rejected) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Colors.grey.withOpacity(0.1))),
          ),
          child: Stack(
            children: [
              // 1. 背景网格
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              
              // 2. 积木堆叠列表
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20), // 减少底部padding，因为中间没按钮了
                  child: ListView.builder(
                    reverse: true, 
                    shrinkWrap: true,
                    // 增加右侧 Padding，防止积木被右下角的按钮遮挡
                    padding: const EdgeInsets.only(bottom: 80, left: 20, right: 80),
                    itemCount: _placedBlocks.length,
                    itemBuilder: (ctx, index) {
                      final block = _placedBlocks[index];
                      
                      return LongPressDraggable<BlockData>(
                        data: block,
                        delay: const Duration(milliseconds: 150),
                        onDragStarted: () => setState(() => _isDraggingPlacedBlock = true),
                        onDragEnd: (_) => setState(() => _isDraggingPlacedBlock = false),
                        onDraggableCanceled: (_, __) => setState(() => _isDraggingPlacedBlock = false),
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(
                            width: 110, height: 42,
                            child: IsometricBlockWidget(data: block, depth: 8, isDragging: true),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Center(
                            child: SizedBox(
                              width: 110, height: 42,
                              child: IsometricBlockWidget(data: block, depth: 8),
                            ),
                          ),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 110, height: 42,
                            child: IsometricBlockWidget(data: block, depth: 8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. 空状态
              if (_placedBlocks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.layers_outlined, size: 40, color: Colors.black12),
                        SizedBox(height: 8),
                        Text("Build your tower!", 
                          style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),

              // --- 底部功能区 (分区布局) ---

              // 4. 左下角：垃圾桶
              Positioned(
                bottom: 20,
                left: 20,
                child: _buildTrashBin(),
              ),

              // 5. 右下角：AI 按钮 + RUN 按钮 (垂直排列)
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end, // 右对齐
                  children: [
                    // 【新增】AI 语音按钮 (悬浮在上方)
                    _buildVoiceButton(),
                    
                    const SizedBox(height: 16), // 按钮间距
                    
                    // RUN 按钮
                    _buildRunButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 组件：AI 语音按钮 ---
  Widget _buildVoiceButton() {
    // 紫色系：代表 AI/魔法
    final Color topColor = const Color(0xFF8A4FFF); 
    final Color sideColor = const Color(0xFF6B3DD6); 

    return GestureDetector(
      onTap: () {
        // 点击反馈
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text("AI Listening...", style: TextStyle(fontWeight: FontWeight.bold)),
             duration: Duration(seconds: 1),
             backgroundColor: Color(0xFF8A4FFF),
             behavior: SnackBarBehavior.floating,
             width: 180,
           )
        );
      },
      child: Container(
        width: 56, // 标准 FAB 大小
        height: 56,
        decoration: BoxDecoration(
          color: topColor,
          shape: BoxShape.circle,
          boxShadow: [
            // 硬阴影：2.5D 质感
            BoxShadow(
              color: sideColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
            // 软阴影：悬浮感
            BoxShadow(
              color: const Color(0xFF8A4FFF).withOpacity(0.4),
              offset: const Offset(0, 6),
              blurRadius: 10,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(Icons.mic_rounded, color: Colors.white, size: 28),
            // 右上角的小星星装饰
            Positioned(
              top: 12,
              right: 12,
              child: Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 12),
            ),
          ],
        ),
      ),
    );
  }

  // --- 组件：垃圾桶 ---
  Widget _buildTrashBin() {
    return DragTarget<BlockData>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        setState(() {
          _placedBlocks.removeWhere((block) => block.id == data.id);
          _isDraggingPlacedBlock = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(
             content: Text("Block Removed", style: TextStyle(fontWeight: FontWeight.bold)),
             duration: Duration(milliseconds: 500),
             backgroundColor: Colors.redAccent,
             behavior: SnackBarBehavior.floating,
             width: 150,
           )
        );
      },
      builder: (context, candidates, rejected) {
        final bool isHovering = candidates.isNotEmpty;
        final bool isActive = _isDraggingPlacedBlock || isHovering;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 56 : 48,
          height: isActive ? 56 : 48,
          decoration: BoxDecoration(
            color: isHovering 
                ? Colors.redAccent 
                : (isActive ? Colors.white : Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isHovering ? Colors.redAccent : Colors.grey.withOpacity(0.3),
              width: 2
            ),
            boxShadow: isActive ? [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))
            ] : [],
          ),
          child: Icon(
            Icons.delete_outline_rounded,
            color: isHovering ? Colors.white : (isActive ? Colors.redAccent : Colors.grey),
            size: isActive ? 28 : 24,
          ),
        );
      },
    );
  }

  // --- 组件：RUN 按钮 ---
  Widget _buildRunButton() {
    final Color topColor = const Color(0xFF06D6A0); 
    final Color sideColor = const Color(0xFF049F75); 

    return GestureDetector(
      onTap: () {
        print("RUN Clicked!");
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: topColor,
          borderRadius: BorderRadius.circular(30), 
          boxShadow: [
            BoxShadow(
              color: sideColor,
              offset: const Offset(0, 4), 
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 8),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            SizedBox(width: 6),
            Text(
              "RUN",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16, 
                fontFamily: "Round", 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 其他 UI 组件 ---
  Widget _buildARView(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/home.png', fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.3), colorBlendMode: BlendMode.darken,
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.wallpaper, color: Colors.white24, size: 60))),
          const Center(child: Icon(Icons.view_in_ar_rounded, color: Colors.white24, size: 80)),
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white24, 
              child: BackButton(color: Colors.white, onPressed: () => Navigator.pop(context))
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 70,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _sidebarItem(0, Icons.flash_on_rounded, "Trigger", triggerColor),
          const SizedBox(height: 20),
          _sidebarItem(1, Icons.lightbulb_rounded, "Action", actionColor),
          const SizedBox(height: 20),
          _sidebarItem(2, Icons.alt_route_rounded, "Logic", logicColor),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String label, Color color) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 2) : null,
        ),
        child: Column(children: [
          Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 9, color: isSelected ? color : Colors.grey, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  Widget _buildDrawerContent(int index) {
    List<BlockData> items = [];
    if (index == 0) items = [
      BlockData("Mom Arrives", Icons.face_3, triggerColor),
      BlockData("Dad Leaves", Icons.face_6, triggerColor),
      BlockData("Pet Moves", Icons.pets, triggerColor)
    ];
    else if (index == 1) items = [
      BlockData("Light On", Icons.lightbulb, actionColor),
      BlockData("Fan On", Icons.wind_power, actionColor)
    ];
    else items = [
      BlockData("Wait 5s", Icons.timer, logicColor),
      BlockData("Repeat", Icons.refresh, logicColor)
    ];

    return Container(
      color: const Color(0xFFF9FAFB),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final item = items[i];
          return Draggable<BlockData>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: SizedBox(
                width: 110, height: 42,
                child: IsometricBlockWidget(data: item, depth: 6, isDragging: true),
              ),
            ),
            child: SizedBox(
              width: 110, height: 42,
              child: IsometricBlockWidget(data: item, depth: 6),
            ),
          );
        },
      ),
    );
  }
}

// --- 数据模型 ---
class BlockData {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  BlockData(this.label, this.icon, this.color, {String? id}) 
      : id = id ?? const Uuid().v4();
}

// --- 2.5D 积木绘制 ---
class IsometricBlockWidget extends StatelessWidget {
  final BlockData data;
  final double depth; 
  final bool isDragging;

  const IsometricBlockWidget({
    super.key, 
    required this.data, 
    this.depth = 8,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlockPainter(
        color: data.color,
        depth: depth,
        isDragging: isDragging,
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: depth, left: 16, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  data.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    shadows: [Shadow(color: Colors.black26, offset: Offset(0.5, 0.5), blurRadius: 1)]
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlockPainter extends CustomPainter {
  final Color color;
  final double depth;
  final bool isDragging;

  BlockPainter({required this.color, required this.depth, this.isDragging = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height - depth;
    const double r = 6.0; 
    const double tabSize = 10.0;

    final frontColor = color;
    final sideColor = HSLColor.fromColor(color).withLightness(
      (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0)
    ).toColor();
    final topHighlightColor = Colors.white.withOpacity(0.3);

    final path = Path();
    path.moveTo(tabSize + r, 0); 
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: const Radius.circular(r));
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: const Radius.circular(r));
    path.lineTo(tabSize + r, h);
    path.arcToPoint(Offset(tabSize, h - r), radius: const Radius.circular(r));
    final tabStart = (h - tabSize * 1.5) / 2;
    path.lineTo(tabSize, tabStart + tabSize * 1.5);
    path.cubicTo(0, tabStart + tabSize * 1.5, 0, tabStart, tabSize, tabStart);
    path.lineTo(tabSize, r);
    path.arcToPoint(Offset(tabSize + r, 0), radius: const Radius.circular(r));
    path.close();

    if (isDragging) {
      canvas.drawShadow(path.shift(const Offset(0, 5)), Colors.black38, 8, true);
    } else {
      canvas.drawShadow(path.shift(const Offset(0, 2)), Colors.black12, 3, true);
    }

    canvas.drawPath(path.shift(Offset(0, depth)), Paint()..color = sideColor);
    canvas.drawRect(Rect.fromLTWH(tabSize, h/2, w - tabSize, depth + h/2), Paint()..color = sideColor);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HSLColor.fromColor(frontColor).withLightness((HSLColor.fromColor(frontColor).lightness + 0.05).clamp(0.0, 1.0)).toColor(),
        frontColor,
      ],
    );
    canvas.drawPath(path, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    final highlightPath = Path();
    highlightPath.moveTo(tabSize + r, 2);
    highlightPath.lineTo(w - r, 2);
    canvas.drawPath(highlightPath, Paint()..color = topHighlightColor..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withOpacity(0.08)..strokeWidth = 1;
    for (double i = 0; i < size.width; i += 20) { canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint); }
    for (double i = 0; i < size.height; i += 20) { canvas.drawLine(Offset(0, i), Offset(size.width, i), paint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}