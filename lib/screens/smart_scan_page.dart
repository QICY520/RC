import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

// ⚠️ 路径检查：请确保这里引用是正确的
import 'ar_coding_page_3d.dart'; 

class SmartScanPage extends StatefulWidget {
  const SmartScanPage({super.key});

  @override
  State<SmartScanPage> createState() => _SmartScanPageState();
}

class _SmartScanPageState extends State<SmartScanPage> with TickerProviderStateMixin {
  // 流程状态: 0=扫描, 1=锁定, 2=完成
  int _step = 0;

  // 动画控制器
  late AnimationController _scanLineController;
  late AnimationController _blockScaleController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    // 1. 初始化控制器
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _blockScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _particleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    // 2. 启动
    _scanLineController.repeat();
    _startAutoSequence();
  }

  // --- 自动流程逻辑 ---
  void _startAutoSequence() async {
    // 3秒后 -> 锁定
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted || _step > 0) return;
    
    setState(() {
      _step = 1;
      _scanLineController.stop(); 
    });

    // 再过1.5秒 -> 生成积木
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _step > 1) return;

    setState(() {
      _step = 2;
    });
    _blockScaleController.forward(from: 0.0);
    _particleController.forward(from: 0.0);
  }

  // --- 手动点击跳过 (防卡死) ---
  void _forceNextStep() {
    if (_step == 0) {
      setState(() { _step = 1; _scanLineController.stop(); });
    } else if (_step == 1) {
      setState(() => _step = 2);
      _blockScaleController.forward(from: 0.0);
      _particleController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _blockScaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double centerX = screenSize.width * 0.5;
    final double centerY = screenSize.height * 0.5;

    // 垂直偏移量
    const double verticalOffset = 60.0; 

    return Scaffold(
      backgroundColor: const Color(0xFF2A0E68),
      body: GestureDetector(
        onTap: _forceNextStep, 
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. 背景
            Image.asset(
              'assets/images/home_scan.jpg',
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: const Color(0xFF2A0E68)),
            ),

            // 2. 彩虹扫描线 (Step 0)
            if (_step == 0)
              AnimatedBuilder(
                animation: _scanLineController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RainbowScannerPainter(progress: _scanLineController.value),
                    size: Size.infinite,
                  );
                },
              ),

            // 3. 魔法透镜锁定圈 (Step 1+)
            if (_step >= 1)
              Positioned(
                left: centerX - 80,
                top: (centerY - 80) + verticalOffset, 
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, val, child) => Transform.scale(scale: val, child: child),
                  child: _buildMagicLensBox(),
                ),
              ),

            // 4. 粒子爆炸 (Step 2)
            if (_step == 2)
              Positioned(
                left: centerX,
                top: (centerY - 60) + verticalOffset, 
                child: MagicExplosionParticles(controller: _particleController),
              ),

            // 5. 积木卡片 (Step 2)
            if (_step == 2)
              Positioned(
                left: centerX - 65,
                top: (centerY - 150) + verticalOffset, 
                child: ScaleTransition(
                  scale: CurvedAnimation(parent: _blockScaleController, curve: Curves.elasticOut),
                  child: _buildGlowingGeneratedBlockCard(),
                ),
              ),

            // 6. 顶部栏
            Positioned(
              top: 50, left: 20, right: 20,
              child: _buildTopBar(),
            ),

            // 7. 底部按钮
            if (_step == 2)
              Positioned(
                bottom: 60, // 稍微提高一点
                left: 0, 
                right: 0,
                child: Center(child: _build3DActionButton(context)),
              ),
          ],
        ),
      ),
    );
  }

  // --- 顶部状态栏 ---
  Widget _buildTopBar() {
    String text = _step == 0 ? "Scanning Magic..." : (_step == 1 ? "Target Locked!" : "Magic Found!");
    IconData icon = _step == 0 ? Icons.auto_awesome : (_step == 1 ? Icons.gps_fixed : Icons.check_circle_rounded);
    
    List<Color> gradientColors;
    if (_step == 0) {
      gradientColors = [const Color(0xFF4FC3F7), const Color(0xFF29B6F6)]; 
    } else if (_step == 1) {
      gradientColors = [const Color(0xFFFFE082), const Color(0xFFFFCA28)]; 
    } else {
      gradientColors = [const Color(0xFFA5D6A7), const Color(0xFF66BB6A)]; 
    }

    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
            boxShadow: [
              BoxShadow(color: gradientColors.last.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))
            ],
          ),
          child: Row(
            children: [
              if (_step == 0)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                )
              else 
                Icon(icon, color: Colors.white, size: 18),
              if (_step != 0) const SizedBox(width: 8),
              Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(width: 40),
      ],
    );
  }

  // --- 【修改】立体风格操作按钮 ---
  Widget _build3DActionButton(BuildContext context) {
    // 按钮主色调 (糖果粉)
    const Color mainColor = Color(0xFFFF66C4); 
    // 按钮阴影/侧边色 (深粉)
    const Color sideColor = Color(0xFFD42E7A); 

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 🏆 贴纸风格的提示横幅 (小巧版)
        Transform.rotate(
          angle: -0.05, 
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFAB00), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(color: const Color(0xFFFF6D00).withOpacity(0.5), offset: const Offset(0, 3), blurRadius: 0),
                BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 6), blurRadius: 8), 
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.emoji_events_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "NEW BLOCK UNLOCKED!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 1)],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        
        // 立体按钮实体
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ARCodingPage3D())),
          child: Container(
            // 移除 width: double.infinity，改为自适应宽度，加 padding
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: mainColor,
              borderRadius: BorderRadius.circular(40), // 圆润的形状
              boxShadow: [
                // 1. 硬阴影 (Side/Depth Effect) - 模拟3D厚度
                const BoxShadow(
                  color: sideColor, 
                  offset: Offset(0, 6), // 向下偏移，形成厚度
                  blurRadius: 0, // 无模糊，硬边
                ),
                // 2. 软阴影 (Drop Shadow) - 模拟悬浮
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(0, 12),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // 紧凑布局
              children: const [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  "START CODING", 
                  style: TextStyle(
                    color: Colors.white, 
                    fontSize: 18, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 1
                  )
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- 魔法透镜锁定圈 ---
  Widget _buildMagicLensBox() {
    return SizedBox(
      width: 160, height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFE082).withOpacity(0.6), width: 2), 
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFE082).withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
              ],
            ),
          ),
          RotationTransition(
            turns: _scanLineController,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.8), width: 2, style: BorderStyle.solid),
              ),
            ),
          ),
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1), 
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 0, top: 130), 
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082), 
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
              ),
              child: const Text(
                "MAGIC FAN", 
                style: TextStyle(color: Color(0xFF5D4037), fontWeight: FontWeight.w900, fontSize: 13)
              ),
            ),
          )
        ],
      ),
    );
  }

  // --- 积木卡片 (2.5D 拼图方块风格) ---
  Widget _buildGlowingGeneratedBlockCard() {
    // 积木颜色 (使用与编程页一致的动作块颜色: Blue/Cyan)
    const Color blockColor = Color(0xFF118AB2); 

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 150, height: 60, // 尺寸适配画笔
            decoration: BoxDecoration(
               // 添加外发光，模拟选中/高亮状态
               boxShadow: [
                 BoxShadow(
                   color: blockColor.withOpacity(0.6 * value),
                   blurRadius: 20,
                   spreadRadius: 2,
                 )
               ]
            ),
            child: CustomPaint(
              painter: BlockPainter(color: blockColor, depth: 8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 12), // 修正内容位置(考虑depth和tab)
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wind_power_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("Fan On", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// 🧩 积木形状绘制 (复用自 AR Coding Page)
// ---------------------------------------------------------
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
    // 侧边颜色变暗
    final sideColor = HSLColor.fromColor(color).withLightness(
      (HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0)
    ).toColor();
    final topHighlightColor = Colors.white.withOpacity(0.3);

    final path = Path();
    // 绘制拼图形状 (左凸右平结构，简化版)
    path.moveTo(tabSize + r, 0); 
    path.lineTo(w - r, 0);
    path.arcToPoint(Offset(w, r), radius: const Radius.circular(r));
    path.lineTo(w, h - r);
    path.arcToPoint(Offset(w - r, h), radius: const Radius.circular(r));
    path.lineTo(tabSize + r, h);
    path.arcToPoint(Offset(tabSize, h - r), radius: const Radius.circular(r));
    
    // 左侧凸起 (Tab)
    final tabStart = (h - tabSize * 1.5) / 2;
    path.lineTo(tabSize, tabStart + tabSize * 1.5);
    path.cubicTo(0, tabStart + tabSize * 1.5, 0, tabStart, tabSize, tabStart);
    path.lineTo(tabSize, r);
    path.arcToPoint(Offset(tabSize + r, 0), radius: const Radius.circular(r));
    path.close();

    // 阴影
    canvas.drawShadow(path.shift(const Offset(0, 4)), Colors.black26, 6, true);

    // 绘制侧面 (立体厚度)
    canvas.drawPath(path.shift(Offset(0, depth)), Paint()..color = sideColor);
    // 填充侧面连接处
    canvas.drawRect(Rect.fromLTWH(tabSize, h/2, w - tabSize, depth + h/2), Paint()..color = sideColor);

    // 绘制正面 (渐变效果)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        HSLColor.fromColor(frontColor).withLightness((HSLColor.fromColor(frontColor).lightness + 0.05).clamp(0.0, 1.0)).toColor(),
        frontColor,
      ],
    );
    canvas.drawPath(path, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    // 顶部高光描边
    final highlightPath = Path();
    highlightPath.moveTo(tabSize + r, 2);
    highlightPath.lineTo(w - r, 2);
    canvas.drawPath(highlightPath, Paint()..color = topHighlightColor..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// ✨ 画笔组件 (VFX Painters)
// ---------------------------------------------------------

// 🌈 彩虹扫描画笔
class RainbowScannerPainter extends CustomPainter {
  final double progress;
  RainbowScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height * progress;
    
    final Paint corePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.purpleAccent.withOpacity(0), 
          Colors.lightBlueAccent, 
          Colors.lightGreenAccent, 
          Colors.amberAccent, 
          Colors.purpleAccent.withOpacity(0)
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 5, size.width, 10));

    canvas.drawRect(Rect.fromLTWH(0, y - 5, size.width, 10), corePaint);

    final Paint tailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.lightBlueAccent.withOpacity(0),
          Colors.purpleAccent.withOpacity(0.15),
          Colors.pinkAccent.withOpacity(0.3),
        ],
      ).createShader(Rect.fromLTWH(0, y - 200, size.width, 200));

    Path tailPath = Path();
    tailPath.moveTo(0, y);
    for (double x = 0; x <= size.width; x += 10) {
      tailPath.lineTo(x, y - 100 - 20 * math.sin(x / 40 + progress * 10));
    }
    tailPath.lineTo(size.width, y);
    tailPath.close();
    canvas.drawPath(tailPath, tailPaint);

    final math.Random random = math.Random(progress.toInt());
    final Paint starPaint = Paint()..color = Colors.white.withOpacity(0.7);
    for (int i = 0; i < 25; i++) {
      double x = random.nextDouble() * size.width;
      double starY = y - random.nextDouble() * 150;
      double radius = random.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(x, starY), radius, starPaint);
    }
  }
  @override
  bool shouldRepaint(covariant RainbowScannerPainter oldDelegate) => oldDelegate.progress != progress;
}

// ✨ 粒子爆炸组件 (带尺寸约束)
class MagicExplosionParticles extends StatelessWidget {
  final AnimationController controller;
  const MagicExplosionParticles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SizedBox(
          width: 10, height: 10, 
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none, 
            children: List.generate(12, (index) {
               final double angle = (index / 12) * 2 * math.pi;
               final double dist = controller.value * 120; 
               final double dx = math.cos(angle) * dist;
               final double dy = math.sin(angle) * dist;
               final double size = (1.0 - controller.value) * 12; 
               
               final Color color = [Colors.amberAccent, Colors.cyanAccent, Colors.pinkAccent][index % 3];

               return Positioned(
                 left: dx, top: dy,
                 child: Opacity(
                   opacity: 1.0 - controller.value,
                   child: Icon(Icons.star_rounded, size: size, color: color),
                 ),
               );
            }),
          ),
        );
      },
    );
  }
}