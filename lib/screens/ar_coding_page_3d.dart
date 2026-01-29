import 'dart:math' as math;
import 'dart:async'; // 引入 Timer 和 Future
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
//  AR Coding Page - AI Copilot Enhanced Version
// ---------------------------------------------------------------------------

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

  // --- 【核心动画状态】 ---
  bool _isRunning = false; // 控制是否切换到了“运行后”状态
  late AnimationController _lightBreathingController; // 控制台灯光晕呼吸
  late AnimationController _floatingController; // 控制气泡上下浮动

  // --- 【AI 助手核心状态机】 ---
  // 0: 空闲
  // 1: 聆听中 (第1轮)
  // 2: 用户说 "我要打开风扇"
  // 3: AI 提问 "什么时候? 有人还是太热?"
  // 4: 用户说 "因为太热了"
  // 5: AI 指引 "去找 High Temp" (等待拖拽)
  // 6: 积木已放置 -> AI 追问 "然后做什么?" (等待点击语音)
  // 7: 聆听中 (第2轮)
  // 8: 用户说 "打开风扇"
  // 9: AI 指引 "去找 Fan On" (等待拖拽)
  // 10: 完成 -> AI 总结 "IF-THEN 逻辑"
  int _aiStep = 0; 
  
  String _aiMessage = "";
  String _userMessage = "";
  
  // 引导高亮控制
  int? _highlightCategoryIndex; // 高亮侧边栏分类
  String? _targetBlockLabel; // 高亮具体积木
  
  late AnimationController _pulseController; // AI 头像和语音按钮的呼吸动画

  @override
  void initState() {
    super.initState();
    // 初始化呼吸动画：2秒一次循环
    _lightBreathingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    // 初始化浮动动画
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    // AI 呼吸动画
    _pulseController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 1)
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _lightBreathingController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // --- 运行/停止逻辑 ---
  void _toggleRun() {
    setState(() {
      _isRunning = !_isRunning;
    });
    if (_isRunning) {
      _lightBreathingController.repeat(reverse: true);
    } else {
      _lightBreathingController.stop();
      _lightBreathingController.reset();
    }
  }

  // =========================================================
  // 🤖 AI 交互逻辑核心 (The Brain)
  // =========================================================

  // 触发语音按钮点击
  void _onVoiceButtonTap() {
    // 如果是初始状态，开始第一轮对话
    if (_aiStep == 0) {
      _startAIDemoPart1();
    } 
    // 如果是第一块积木放好后，开始第二轮对话
    else if (_aiStep == 6) {
      _startAIDemoPart2();
    }
    // 其他状态点击无效（或可以提示“正在思考中”）
  }

  // 第一轮：引导条件 (Trigger)
  void _startAIDemoPart1() {
    setState(() {
      _aiStep = 1; 
      _userMessage = "正在聆听...";
      _aiMessage = "";
    });

    // 模拟识别过程
    Future.delayed(const Duration(milliseconds: 1500), () {
      if(!mounted) return;
      setState(() {
        _aiStep = 2;
        _userMessage = "“ 我想要打开风扇。 ”";
      });
    });

    // AI 提问引导
    Future.delayed(const Duration(seconds: 3), () {
      if(!mounted) return;
      setState(() {
        _aiStep = 3;
        _userMessage = ""; 
        _aiMessage = "好呀！但是风扇是什么时候要开始工作的呢？\n是因为有人来了，还是太热了？";
        // 这里可以高亮 Trigger 分类提示一下
        _highlightCategoryIndex = 0; 
      });
    });

    // 用户回答
    Future.delayed(const Duration(seconds: 7), () { 
      if(!mounted) return;
      setState(() {
        _aiStep = 4;
        _aiMessage = ""; 
        _userMessage = "“ 因为太热了。 ”";
      });
    });

    // AI 指引去拖拽
    Future.delayed(const Duration(milliseconds: 8500), () {
      if(!mounted) return;
      setState(() {
        _aiStep = 5;
        _userMessage = "";
        _aiMessage = "明白了！我们需要一个能感知温度的积木。\n去黄色的 Trigger 里找找 ‘High Temp’ 吧！";
        
        // 自动操作 UI
        _selectedCategoryIndex = 0; // 自动打开 Trigger
        _highlightCategoryIndex = 0; // 高亮 Trigger Tab
        _targetBlockLabel = "High Temp"; // 高亮具体积木
      });
    });
  }

  // 当积木被拖入舞台时触发
  void _onBlockPlacedInStage(BlockData data) {
    // 逻辑一：如果正在等待 High Temp
    if (_aiStep == 5 && data.label == "High Temp") {
      setState(() {
        _aiStep = 6; // 进入中间态
        _highlightCategoryIndex = null;
        _targetBlockLabel = null;
        _aiMessage = "太棒了！我们已经让风扇有了“感觉”。\n那么，当温度变高之后，你要让风扇做什么呢？";
      });
      // 这里的交互设计：等待用户再次点击语音按钮回答
    }
    
    // 逻辑二：如果正在等待 Fan On
    if (_aiStep == 9 && data.label == "Fan On") {
      setState(() {
        _aiStep = 10; // 完成态
        _highlightCategoryIndex = null;
        _targetBlockLabel = null;
        _aiMessage = "完美的逻辑！你是小小工程师！\n你刚刚写出了一个 “如果...就...” (If...Then) 的条件语句哦！";
      });
      
      // 5秒后自动隐藏 AI
      Future.delayed(const Duration(seconds: 8), () {
        if (mounted && _aiStep == 10) {
          setState(() {
            _aiStep = 0;
            _aiMessage = "";
          });
        }
      });
    }
  }

  // 第二轮：引导动作 (Action)
  void _startAIDemoPart2() {
    setState(() {
      _aiStep = 7; // 聆听中 2
      _aiMessage = "";
      _userMessage = "正在聆听...";
    });

    // 模拟用户回答
    Future.delayed(const Duration(milliseconds: 1500), () {
      if(!mounted) return;
      setState(() {
        _aiStep = 8;
        _userMessage = "“ 打开风扇！ ”";
      });
    });

    // AI 指引去拖拽 Action
    Future.delayed(const Duration(seconds: 3), () {
      if(!mounted) return;
      setState(() {
        _aiStep = 9;
        _userMessage = "";
        _aiMessage = "收到！那就给它一个动作指令吧。\n去绿色的 Action (动作) 列表里找找 ‘Fan On’！";
        
        // 自动操作 UI
        _selectedCategoryIndex = 1; // 自动打开 Action
        _highlightCategoryIndex = 1; // 高亮 Action Tab
        _targetBlockLabel = "Fan On"; // 高亮具体积木
      });
    });
  }

  // =========================================================
  // 🏗️ UI 构建部分
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGridColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // 动态计算底部编程区域的高度（占屏幕高度的 40%）
          final double bottomAreaHeight = constraints.maxHeight * 0.4;
          
          return Stack(
            children: [
              // 主体内容 Column
              Column(
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

              // --- AI 对话交互层 (Overlay) ---
              if (_aiStep > 0) _buildAIOverlay(bottomAreaHeight),
            ],
          );
        },
      ),
    );
  }

  // --- AR 视图 (保持原样) ---
  Widget _buildARView(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 运行前底图
          AnimatedOpacity(
            opacity: _isRunning ? 0.0 : 1.0, 
            duration: const Duration(milliseconds: 800), 
            child: Image.asset(
              'assets/images/home_off.png', 
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.1), 
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // 运行后底图
          AnimatedOpacity(
            opacity: _isRunning ? 1.0 : 0.0, 
            duration: const Duration(milliseconds: 800),
            child: Image.asset(
              'assets/images/home_on.png', 
              fit: BoxFit.cover,
            ),
          ),
          // AI 语义标签
          AnimatedOpacity(
            opacity: _isRunning ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: AnimatedBuilder(
              animation: _floatingController,
              builder: (context, child) {
                final double offset = math.sin(_floatingController.value * math.pi) * 8.0;
                return Transform.translate(offset: Offset(0, offset), child: child);
              },
              child: Stack(
                fit: StackFit.expand,
                children: const [
                   Align(alignment: Alignment(-0.25, -0.45), child: DeviceTagWidget(name: "Smart Lamp", state: "Connected", icon: Icons.light)),
                   Align(alignment: Alignment(0.7, -0.1), child: DeviceTagWidget(name: "Smart TV", state: "Standby", icon: Icons.tv)),
                   Align(alignment: Alignment(0.2, 0.4), child: DeviceTagWidget(name: "Air Fan", state: "Standby", icon: Icons.wind_power)),
                ],
              ),
            ),
          ),
          // 动态光效
          AnimatedOpacity(
            opacity: _isRunning ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Align(
                  alignment: const Alignment(-0.25, -0.28), 
                  child: AnimatedBuilder(
                    animation: _lightBreathingController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_lightBreathingController.value * 0.15), 
                        child: Opacity(
                          opacity: 0.4 + (_lightBreathingController.value * 0.3),
                          child: Container(
                            width: 220, height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [const Color(0xFFFFD166).withOpacity(0.7), const Color(0xFFFFD166).withOpacity(0.0)],
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

  // --- 舞台区域 (集成 AI 监听) ---
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
        // 🔥 核心：通知 AI 有积木放进来了
        _onBlockPlacedInStage(data);
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
                      // 连线特效逻辑可以放这里
                      return LongPressDraggable<BlockData>(
                        data: block,
                        delay: const Duration(milliseconds: 150),
                        onDragStarted: () => setState(() => _isDraggingPlacedBlock = true),
                        onDragEnd: (_) => setState(() => _isDraggingPlacedBlock = false),
                        onDraggableCanceled: (_, __) => setState(() => _isDraggingPlacedBlock = false),
                        feedback: Material(
                          color: Colors.transparent,
                          child: SizedBox(width: 110, height: 42, child: IsometricBlockWidget(data: block, depth: 8, isDragging: true)),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Center(child: SizedBox(width: 110, height: 42, child: IsometricBlockWidget(data: block, depth: 8))),
                        ),
                        child: Center(child: SizedBox(width: 110, height: 42, child: IsometricBlockWidget(data: block, depth: 8))),
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
                        Text("Build your tower!", style: TextStyle(color: Colors.black26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 20, left: 20,
                child: _buildTrashBin(),
              ),
              Positioned(
                bottom: 20, right: 20,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildVoiceButton(),
                    const SizedBox(height: 16),
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

  // --- AI 语音按钮 (带呼吸提示) ---
  Widget _buildVoiceButton() {
    final Color topColor = const Color(0xFF8A4FFF);
    final Color sideColor = const Color(0xFF6B3DD6); 
    
    // 状态判定
    bool isListening = _aiStep == 1 || _aiStep == 7;
    // 当处于 Step 6 (等待用户回答第二轮) 时，呼吸闪烁提示用户点击
    bool shouldPulse = _aiStep == 6; 

    return GestureDetector(
      onTap: _onVoiceButtonTap,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          double scale = shouldPulse ? (1.0 + _pulseController.value * 0.1) : 1.0;
          return Transform.scale(scale: scale, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isListening ? 64 : 56,
          height: isListening ? 64 : 56,
          decoration: BoxDecoration(
            color: topColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: sideColor, offset: const Offset(0, 4), blurRadius: 0),
              BoxShadow(
                color: const Color(0xFF8A4FFF).withOpacity(isListening ? 0.6 : 0.4),
                offset: const Offset(0, 6),
                blurRadius: isListening ? 20 : 10,
                spreadRadius: isListening ? 5 : 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(isListening ? Icons.graphic_eq : Icons.mic_rounded, color: Colors.white, size: 28),
              if (!isListening)
                const Positioned(
                  top: 12, right: 12,
                  child: Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- AI 覆盖层 (Avatar + 气泡) ---
  Widget _buildAIOverlay(double bottomOffset) {
    return Positioned(
      bottom: bottomOffset, // 动态定位在编程区域上方
      right: 20,
      left: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 用户气泡
          if (_userMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Text(_userMessage, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
            ),

          // AI 气泡
          if (_aiMessage.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF651FFF)]),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                      boxShadow: [BoxShadow(color: const Color(0xFF651FFF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                    ),
                    child: Text(
                      _aiMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ScaleTransition(
                  scale: Tween(begin: 0.9, end: 1.1).animate(_pulseController),
                  child: Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF7C4DFF), width: 2),
                      boxShadow: [BoxShadow(color: const Color(0xFF7C4DFF).withOpacity(0.4), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF7C4DFF), size: 30),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- 侧边栏 (带高亮逻辑) ---
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
    // 判断是否需要高亮推荐
    bool isHighlight = _highlightCategoryIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = isSelected ? null : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          // 高亮时显示浅色背景
          color: isHighlight ? color.withOpacity(0.2) : (isSelected ? color.withOpacity(0.1) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          // 高亮时边框加粗
          border: isHighlight 
              ? Border.all(color: color, width: 3) 
              : (isSelected ? Border.all(color: color, width: 2) : null),
          // 高亮时加阴影
          boxShadow: isHighlight ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10)] : [],
        ),
        child: Column(children: [
          Icon(icon, color: (isSelected || isHighlight) ? color : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 9, color: (isSelected || isHighlight) ? color : Colors.grey, fontWeight: FontWeight.bold))
        ]),
      ),
    );
  }

  // --- 抽屉内容 (带具体积木高亮) ---
  Widget _buildDrawerContent(int index) {
    List<BlockData> items = [];
    if (index == 0) items = [
      BlockData("Mom Arrives", Icons.face_3, triggerColor),
      BlockData("Dad Leaves", Icons.face_6, triggerColor),
      BlockData("Pet Moves", Icons.pets, triggerColor),
      BlockData("High Temp", Icons.thermostat, triggerColor), // Temp
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
          // 判断是否是 AI 推荐的那个积木
          bool isTargetBlock = _targetBlockLabel != null && item.label == _targetBlockLabel;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Draggable<BlockData>(
                data: item,
                feedback: Material(
                  color: Colors.transparent,
                  child: SizedBox(width: 110, height: 42, child: IsometricBlockWidget(data: item, depth: 6, isDragging: true)),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // 如果是目标积木，加一个发光背景框
                  decoration: isTargetBlock ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: item.color.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)],
                  ) : null,
                  child: SizedBox(width: 110, height: 42, child: IsometricBlockWidget(data: item, depth: 6)),
                ),
              ),
              // 高亮时显示的提示图标
              if (isTargetBlock)
                const Positioned(
                  right: -15, top: -5,
                  child: Icon(Icons.touch_app_rounded, color: Colors.purpleAccent, size: 32),
                )
            ],
          );
        },
      ),
    );
  }

  // --- 垃圾桶 ---
  Widget _buildTrashBin() {
    return DragTarget<BlockData>(
      onWillAccept: (data) => true,
      onAccept: (data) {
        setState(() {
          _placedBlocks.removeWhere((block) => block.id == data.id);
          _isDraggingPlacedBlock = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
             content: Text("Block Removed", style: TextStyle(fontWeight: FontWeight.bold)),
             duration: Duration(milliseconds: 500),
             backgroundColor: Colors.redAccent,
             behavior: SnackBarBehavior.floating, width: 150,
        ));
      },
      builder: (context, candidates, rejected) {
        final bool isHovering = candidates.isNotEmpty;
        final bool isActive = _isDraggingPlacedBlock || isHovering;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 56 : 48, height: isActive ? 56 : 48,
          decoration: BoxDecoration(
            color: isHovering ? Colors.redAccent : (isActive ? Colors.white : Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: isHovering ? Colors.redAccent : Colors.grey.withOpacity(0.3), width: 2),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,4))] : [],
          ),
          child: Icon(Icons.delete_outline_rounded, color: isHovering ? Colors.white : (isActive ? Colors.redAccent : Colors.grey), size: isActive ? 28 : 24),
        );
      },
    );
  }

  // --- RUN 按钮 ---
  Widget _buildRunButton() {
    final Color topColor = _isRunning ? const Color(0xFFEF476F) : const Color(0xFF06D6A0); 
    final Color sideColor = _isRunning ? const Color(0xFFC83E5D) : const Color(0xFF049F75);
    final String label = _isRunning ? "STOP" : "RUN";
    final IconData icon = _isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded;
    return GestureDetector(
      onTap: _toggleRun,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 120, 
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: topColor,
          borderRadius: BorderRadius.circular(30), 
          boxShadow: [
            BoxShadow(color: sideColor, offset: const Offset(0, 4), blurRadius: 0),
            BoxShadow(color: Colors.black.withOpacity(0.15), offset: const Offset(0, 8), blurRadius: 8),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Round", fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          ],
        ),
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
  BlockData(this.label, this.icon, this.color, {String? id}) : id = id ?? const Uuid().v4();
}

// --- 2.5D 积木 ---
class IsometricBlockWidget extends StatelessWidget {
  final BlockData data;
  final double depth; 
  final bool isDragging;
  const IsometricBlockWidget({super.key, required this.data, this.depth = 8, this.isDragging = false});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BlockPainter(color: data.color, depth: depth, isDragging: isDragging),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: depth, left: 16, right: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Flexible(child: Text(data.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, shadows: [Shadow(color: Colors.black26, offset: Offset(0.5, 0.5), blurRadius: 1)]), overflow: TextOverflow.ellipsis)),
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
    const double r = 6.0; const double tabSize = 10.0;
    final frontColor = color;
    final sideColor = HSLColor.fromColor(color).withLightness((HSLColor.fromColor(color).lightness - 0.15).clamp(0.0, 1.0)).toColor();
    final topHighlightColor = Colors.white.withOpacity(0.3);

    final path = Path();
    path.moveTo(tabSize + r, 0); path.lineTo(w - r, 0);
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

    if (isDragging) canvas.drawShadow(path.shift(const Offset(0, 5)), Colors.black38, 8, true);
    else canvas.drawShadow(path.shift(const Offset(0, 2)), Colors.black12, 3, true);

    canvas.drawPath(path.shift(Offset(0, depth)), Paint()..color = sideColor);
    canvas.drawRect(Rect.fromLTWH(tabSize, h/2, w - tabSize, depth + h/2), Paint()..color = sideColor);
    final gradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [HSLColor.fromColor(frontColor).withLightness((HSLColor.fromColor(frontColor).lightness + 0.05).clamp(0.0, 1.0)).toColor(), frontColor]);
    canvas.drawPath(path, Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)));
    final highlightPath = Path();
    highlightPath.moveTo(tabSize + r, 2); highlightPath.lineTo(w - r, 2);
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

// --- 设备 AI 语义标签 ---
class DeviceTagWidget extends StatelessWidget {
  final String name;
  final String state;
  final IconData icon;
  const DeviceTagWidget({super.key, required this.name, required this.state, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF00C6FF).withOpacity(0.8), const Color(0xFF0072FF).withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
            boxShadow: [BoxShadow(color: const Color(0xFF00C6FF).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: 2)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 14)),
              const SizedBox(width: 8),
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  Text(state, style: TextStyle(color: Colors.cyanAccent.shade100, fontSize: 9, fontWeight: FontWeight.w500)),
              ]),
            ],
          ),
        ),
        CustomPaint(size: const Size(20, 20), painter: _AnchorPainter()),
      ],
    );
  }
}

class _AnchorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = const Color(0xFF0072FF).withOpacity(0.8)..style = PaintingStyle.fill;
    final Path path = Path();
    path.moveTo(size.width / 2 - 6, 0); path.lineTo(size.width / 2 + 6, 0); path.lineTo(size.width / 2, 8); path.close();
    canvas.drawPath(path, paint);
    final Paint dotPaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width / 2, 12), 3, dotPaint);
    final Paint glowPaint = Paint()..color = Colors.white.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawCircle(Offset(size.width / 2, 12), 6, glowPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}