import 'dart:async';
import 'dart:math' as math;
import 'dart:ui'; // 用于磨砂玻璃效果
import 'package:flutter/material.dart';
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
  // ✨ 新增：AI 信息面板动画控制器
  late AnimationController _aiInfoController;
  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    // 1. 初始化控制器
    _scanLineController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _blockScaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _particleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    // AI 信息延迟一点出现，更有层次感
    _aiInfoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _floatingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);

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

    // 再过1.5秒 -> 生成积木 & AI分析结果
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted || _step > 1) return;

    setState(() {
      _step = 2;
    });
    _blockScaleController.forward(from: 0.0);
    _particleController.forward(from: 0.0);
    
    // 延迟 0.3秒 弹出 AI 信息，制造“分析完成”的感觉
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _aiInfoController.forward();
    });
  }

  // --- 手动点击跳过 (防卡死) ---
  void _forceNextStep() {
    if (_step == 0) {
      setState(() { _step = 1; _scanLineController.stop(); });
    } else if (_step == 1) {
      setState(() => _step = 2);
      _blockScaleController.forward(from: 0.0);
      _particleController.forward(from: 0.0);
      _aiInfoController.forward();
    }
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _blockScaleController.dispose();
    _particleController.dispose();
    _aiInfoController.dispose();
    _floatingController.dispose();
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
              'assets/images/home_scan.jpg', // 你的背景图
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
                left: centerX - 75, // 修正居中
                top: (centerY - 140) + verticalOffset, // 放在圈圈上方，不遮挡
                child: ScaleTransition(
                  scale: CurvedAnimation(parent: _blockScaleController, curve: Curves.elasticOut),
                  child: _buildGlowingGeneratedBlockCard(),
                ),
              ),

            // ✨ New Block Unlocked 提示 (Step 2 - 放在积木旁边)
            if (_step == 2)
              Positioned(
                left: centerX + 60, // 放在积木右侧稍微重叠一点，或者完全在右边
                top: (centerY - 175) + verticalOffset, // 稍微靠上
                child: ScaleTransition(
                  scale: CurvedAnimation(parent: _blockScaleController, curve: Curves.elasticOut),
                  child: Transform.rotate(
                    angle: 0.1, // 稍微倾斜
                    child: _buildMiniUnlockBanner(),
                  ),
                ),
              ),

            // ✨ 6. AI 知识卡片 (Step 2 - 位于上方)
            if (_step == 2)
              Positioned(
                top: (centerY - 300) + verticalOffset, // 放在圈圈上方
                left: 20,
                right: 20,
                child: AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, math.sin(_floatingController.value * math.pi * 2) * 5),
                      child: child,
                    );
                  },
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                        .animate(CurvedAnimation(parent: _aiInfoController, curve: Curves.easeOutBack)),
                    child: FadeTransition(
                      opacity: _aiInfoController,
                      child: _buildAIKnowledgeCard(),
                    ),
                  ),
                ),
              ),

            // ✨ 7. AI 智能建议 (Step 2 - 位于下方)
            if (_step == 2)
              Positioned(
                top: (centerY + 100) + verticalOffset, // 放在圈圈下方
                left: 30,
                right: 30,
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
                      .animate(CurvedAnimation(parent: _aiInfoController, curve: Curves.easeOutBack)),
                  child: FadeTransition(
                    opacity: _aiInfoController,
                    child: _buildAISuggestion(),
                  ),
                ),
              ),

            // 8. 顶部栏
            Positioned(
              top: 50, left: 20, right: 20,
              child: _buildTopBar(),
            ),

            // 9. 底部按钮
            if (_step == 2)
              Positioned(
                bottom: 50,
                left: 0, 
                right: 0,
                child: Center(
                  // 给按钮也加个淡入动画
                  child: FadeTransition(
                    opacity: _aiInfoController,
                    child: _build3DActionButton(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- 顶部状态栏 ---
  Widget _buildTopBar() {
    String text = _step == 0 ? "正在施展魔法扫描..." : (_step == 1 ? "目标已锁定!" : "分析完成!");
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

  // --- ✨ 新增：AI 知识卡片 (玻璃拟态风格) ---
  Widget _buildAIKnowledgeCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.9),
                Colors.white.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00ACC1).withOpacity(0.15), 
                blurRadius: 30, 
                offset: const Offset(0, 15),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                     BoxShadow(color: const Color(0xFF00ACC1).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                  ]
                ),
                child: const Icon(Icons.wind_power, color: Color(0xFF00ACC1), size: 38),
              ),
              const SizedBox(width: 18),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("智能风扇", style: TextStyle(color: Color(0xFF2D3436), fontSize: 20, fontWeight: FontWeight.w900, fontFamily: "Round")),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildAttrChip(Icons.memory, "物联设备"),
                        const SizedBox(width: 8),
                         _buildAttrChip(Icons.wifi, "在线"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // ✨ 简单的儿童介绍
                    const Text(
                      "我可以吹出凉风让你感到舒适! 🌬️",
                      style: TextStyle(color: Color(0xFF636E72), fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttrChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF6C5CE7)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF6C5CE7), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- ✨ 新增：AI 智能建议气泡 ---
  Widget _buildAISuggestion() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // 暖橙色背景
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.lightbulb, color: Color(0xFFFF9800), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "AI 建议:\n", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE65100), fontSize: 12)),
                  TextSpan(
                    text: "室内温度 28°C! 试着对风扇编程让它 ",
                    style: TextStyle(color: Color(0xFF5D4037), fontSize: 13),
                  ),
                  TextSpan(
                    text: "自动开启",
                    style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 13, decoration: TextDecoration.underline),
                  ),
                  TextSpan(
                    text: " 当你进入房间时。",
                    style: TextStyle(color: Color(0xFF5D4037), fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 立体风格操作按钮 ---
  Widget _build3DActionButton(BuildContext context) {
    const Color mainColor = Color(0xFFFF66C4); 
    const Color sideColor = Color(0xFFD42E7A); 

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ARCodingPage3D())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            const BoxShadow(color: sideColor, offset: Offset(0, 6), blurRadius: 0),
            BoxShadow(color: Colors.black.withOpacity(0.3), offset: const Offset(0, 12), blurRadius: 10),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              "开始编程", 
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)
            ),
          ],
        ),
      ),
    );
  }

  // --- 迷你解锁横幅 ---
  Widget _buildMiniUnlockBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 缩小 padding
      decoration: BoxDecoration(
        color: const Color(0xFFFFAB00),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), offset: const Offset(0, 4), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.emoji_events_rounded, color: Colors.white, size: 14), // 缩小图标
          SizedBox(width: 4),
          Text(
            "新积木解锁!", // 简化文字
            style: TextStyle(
              color: Colors.white,
              fontSize: 10, // 缩小字体
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
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
        ],
      ),
    );
  }

  // --- 积木卡片 (2.5D 拼图方块风格) ---
  Widget _buildGlowingGeneratedBlockCard() {
    const Color blockColor = Color(0xFF118AB2); 

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 150, height: 60,
            decoration: BoxDecoration(
               boxShadow: [
                 BoxShadow(color: blockColor.withOpacity(0.6 * value), blurRadius: 20, spreadRadius: 2)
               ]
            ),
            child: CustomPaint(
              painter: BlockPainter(color: blockColor, depth: 8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wind_power_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("开启风扇", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
// 🧩 积木形状绘制
// ---------------------------------------------------------
class BlockPainter extends CustomPainter {
  final Color color;
  final double depth;
  BlockPainter({required this.color, required this.depth});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height - depth;
    const double r = 6.0; 
    const double tabSize = 10.0;

    final sideColor = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0)).toColor();
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

    canvas.drawShadow(path.shift(const Offset(0, 4)), Colors.black26, 6, true);
    canvas.drawPath(path.shift(Offset(0, depth)), Paint()..color = sideColor);
    canvas.drawRect(Rect.fromLTWH(tabSize, h/2, w - tabSize, depth + h/2), Paint()..color = sideColor);

    final gradient = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness + 0.05).clamp(0.0, 1.0)).toColor(), color],
    );
    canvas.drawPath(path, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));

    final highlightPath = Path();
    highlightPath.moveTo(tabSize + r, 2); highlightPath.lineTo(w - r, 2);
    canvas.drawPath(highlightPath, Paint()..color = topHighlightColor..style = PaintingStyle.stroke..strokeWidth = 1.5..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------
// ✨ 画笔组件 (VFX Painters)
// ---------------------------------------------------------

class RainbowScannerPainter extends CustomPainter {
  final double progress;
  RainbowScannerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double y = size.height * progress;
    final Paint corePaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.purpleAccent.withOpacity(0), Colors.lightBlueAccent, Colors.lightGreenAccent, Colors.amberAccent, Colors.purpleAccent.withOpacity(0)],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 5, size.width, 10));
    canvas.drawRect(Rect.fromLTWH(0, y - 5, size.width, 10), corePaint);

    final Paint tailPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.lightBlueAccent.withOpacity(0), Colors.purpleAccent.withOpacity(0.15), Colors.pinkAccent.withOpacity(0.3)],
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
                 child: Opacity(opacity: 1.0 - controller.value, child: Icon(Icons.star_rounded, size: size, color: color)),
               );
            }),
          ),
        );
      },
    );
  }
}