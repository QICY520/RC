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

// ⚠️ 注意：这里添加了 TickerProviderStateMixin 用于处理动画
class _ARCodingPage3DState extends State<ARCodingPage3D> with TickerProviderStateMixin {
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

  // --- 【新增核心状态】 ---
  bool _isRunning = false; // 控制是否切换到了“运行后”状态
  late AnimationController _lightBreathingController; // 控制台灯光晕呼吸
  
  // 1. 新增：控制气泡上下浮动的控制器
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    // 初始化呼吸动画：2秒一次循环
    _lightBreathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 2. 新增：初始化浮动动画 (2.5秒一个来回，比较轻盈)
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true); // 自动循环往复
  }

  @override
  void dispose() {

    _lightBreathingController.dispose();
    _floatingController.dispose(); // 3. 别忘了销毁
    super.dispose();
  }

  // --- 【新增】运行/停止逻辑 ---
  void _toggleRun() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      // 开始运行：播放呼吸动画
      _lightBreathingController.repeat(reverse: true);
      print("System Running: Switched to Scene 2");
    } else {
      // 停止运行：重置动画
      _lightBreathingController.stop();
      _lightBreathingController.reset();
      print("System Stopped: Reset to Scene 1");
    }
    
  }

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

  // =========================================================
  // 🎥 核心修改区域：双图切换 + 语义锚定 + 动态光效
  // =========================================================
  Widget _buildARView(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ------------------------------------------------
          // 层级 1: 运行前底图 (图一: home1.jpg)
          // ------------------------------------------------
          AnimatedOpacity(
            opacity: _isRunning ? 0.0 : 1.0, // 运行时淡出
            duration: const Duration(milliseconds: 800), // 800ms 平滑切换
            child: Image.asset(
              'assets/images/home_off.png', // 【确保图片存在】
              fit: BoxFit.cover,
              // 稍微压暗一点，让上面的UI更清晰
              color: Colors.black.withOpacity(0.1), 
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // ------------------------------------------------
          // 层级 2: 运行后底图 (图二: home2.jpg)
          // ------------------------------------------------
          AnimatedOpacity(
            opacity: _isRunning ? 1.0 : 0.0, // 运行时淡入
            duration: const Duration(milliseconds: 800),
            child: Image.asset(
              'assets/images/home_on.png', // 【确保图片存在】
              fit: BoxFit.cover,
            ),
          ),

          // ------------------------------------------------
          // 层级 3: AI 语义锚定气泡 (只在运行前显示)
          // ------------------------------------------------
          AnimatedOpacity(
            opacity: _isRunning ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            // 使用 AnimatedBuilder 让整个层级跟随 _floatingController 动起来
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                // 计算偏移量：上下移动 8 像素
                final double offset = math.sin(_floatingController.value * math.pi) * 8.0;
                return Transform.translate(
                  offset: Offset(0, offset), // 只在 Y 轴移动
                  child: child,
                );
              },
              // 这里放原本的 Stack，注意去掉了 const
              child: Stack(
                fit: StackFit.expand,
                children: const [
                   // 台灯标签
                   Align(
                    alignment: Alignment(-0.25, -0.45),
                    child: DeviceTagWidget(name: "Smart Lamp", state: "Connected", icon: Icons.light),
                  ),
                  // 电视标签
                   Align(
                    alignment: Alignment(0.7, -0.1),
                    child: DeviceTagWidget(name: "Smart TV", state: "Standby", icon: Icons.tv),
                  ),
                  // 风扇标签
                   Align(
                    alignment: Alignment(0.2, 0.4),
                    child: DeviceTagWidget(name: "Air Fan", state: "Standby", icon: Icons.wind_power),
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------
          // 层级 4: 动态光效反馈 (只在运行后显示)
          // ------------------------------------------------
          // 在图二的基础上，叠加一个动态呼吸的光晕，让静图变动图
          AnimatedOpacity(
            opacity: _isRunning ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 动态光晕 (位置需要对准台灯灯罩)
                Align(
                  alignment: const Alignment(-0.25, -0.28), 
                  child: AnimatedBuilder(
                    animation: _lightBreathingController,
                    builder: (context, child) {
                      // 呼吸效果：透明度在 0.4 ~ 0.7 之间浮动，大小微调
                      return Transform.scale(
                        scale: 1.0 + (_lightBreathingController.value * 0.15), 
                        child: Opacity(
                          opacity: 0.4 + (_lightBreathingController.value * 0.3),
                          child: Container(
                            width: 220, 
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // 径向渐变：中心暖黄 -> 边缘透明
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFFFD166).withOpacity(0.7), 
                                  const Color(0xFFFFD166).withOpacity(0.0)
                                ],
                                stops: const [0.1, 0.7],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 返回按钮
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

  // --- 核心：搭建舞台 (保持原样) ---
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
              Positioned.fill(child: CustomPaint(painter: GridPainter())),
              
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 20),
                  child: ListView.builder(
                    reverse: true, 
                    shrinkWrap: true,
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

              Positioned(
                bottom: 20,
                left: 20,
                child: _buildTrashBin(),
              ),

              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildVoiceButton(),
                    const SizedBox(height: 16),
                    _buildRunButton(), // 修改了这里
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- 组件：AI 语音按钮 (保持原样) ---
  Widget _buildVoiceButton() {
    final Color topColor = const Color(0xFF8A4FFF); 
    final Color sideColor = const Color(0xFF6B3DD6); 

    return GestureDetector(
      onTap: () {
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: topColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: sideColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            ),
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

  // --- 组件：垃圾桶 (保持原样) ---
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

  // --- 组件：RUN 按钮 (修改为可切换状态) ---
  Widget _buildRunButton() {
    // 根据状态切换颜色和文字
    final Color topColor = _isRunning ? const Color(0xFFEF476F) : const Color(0xFF06D6A0); 
    final Color sideColor = _isRunning ? const Color(0xFFC83E5D) : const Color(0xFF049F75); 
    final String label = _isRunning ? "STOP" : "RUN";
    final IconData icon = _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded;

    return GestureDetector(
      onTap: _toggleRun, // 绑定切换逻辑
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120, // 设置固定宽度确保切换时大小一致
        padding: const EdgeInsets.symmetric(vertical: 10), // 移除水平 padding，由 width 控制
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
          mainAxisAlignment: MainAxisAlignment.center, // 内容居中
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
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

  // --- 其他 UI 组件 (保持原样) ---
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

// --- 【新增】设备 AI 语义标签组件 ---
// --- 【修改后】设备 AI 语义标签组件 ---
class DeviceTagWidget extends StatelessWidget {
  final String name;
  final String state;
  final IconData icon;

  const DeviceTagWidget({
    super.key,
    required this.name,
    required this.state,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // AR 科技风格配色
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. 气泡主体
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            // 背景：深蓝色渐变，半透明
            gradient: LinearGradient(
              colors: [
                const Color(0xFF00C6FF).withOpacity(0.8), // 亮青色
                const Color(0xFF0072FF).withOpacity(0.8), // 深蓝色
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            // 边框：亮白色/青色描边，增加立体感
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            // 阴影：发光效果
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C6FF).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标背景圈
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name, 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 11, 
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5
                    )
                  ),
                  Text(
                    state, 
                    style: TextStyle(
                      color: Colors.cyanAccent.shade100, // 状态用亮青色，对比度更高
                      fontSize: 9,
                      fontWeight: FontWeight.w500
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 2. 连接线和小圆点 (锚定点)，增加 AR 真实感
        CustomPaint(
          size: const Size(20, 20), // 连接线区域大小
          painter: _AnchorPainter(),
        ),
      ],
    );
  }
}

// 画一个小三角形或者线条指向物体
class _AnchorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF0072FF).withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final Path path = Path();
    // 倒三角形
    path.moveTo(size.width / 2 - 6, 0); // 上左
    path.lineTo(size.width / 2 + 6, 0); // 上右
    path.lineTo(size.width / 2, 8);     // 下尖端
    path.close();

    canvas.drawPath(path, paint);
    
    // 底部锚点光圈
    final Paint dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
      
    // 画一个小圆点在三角形下方
    canvas.drawCircle(Offset(size.width / 2, 12), 3, dotPaint);
    
    // 画一个发光晕
    final Paint glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
      
    canvas.drawCircle(Offset(size.width / 2, 12), 6, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}