import 'package:flutter/material.dart';
import 'screens/ar_coding_page_3d.dart';
import 'screens/smart_scan_page.dart';
import 'screens/profile_page.dart'; 

void main() {
  runApp(const ARSmartHomeApp());
}

class ARSmartHomeApp extends StatelessWidget {
  const ARSmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR 智能家居互联',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Round',
        scaffoldBackgroundColor: const Color(0xFFFBFBFB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF9F1C),
          primary: const Color(0xFFFF9F1C),
          secondary: const Color(0xFF2EC4B6),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// 🏠 HomeScreen: 现在它是一个“外壳”，负责管理底部导航和页面切换
// ---------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // 页面列表：这里定义了四个 Tab 对应的内容
  final List<Widget> _pages = [
    const HomeContentPage(), // 提取出来的原主页内容
    const Center(child: Text("Discover Page (Coming Soon)")), // 占位
    const Center(child: Text("Learn Page (Coming Soon)")),    // 占位
    const ProfilePage(),     // 个人中心页
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      // 使用 Stack 确保底部导航栏悬浮在内容之上
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 页面内容层 (使用 IndexedStack 保持页面状态)
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),

          // 2. 底部悬浮导航栏层
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF2D3142),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3142).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_rounded, 0, '首页'),
          _buildNavItem(Icons.explore_rounded, 1, '发现'),
          _buildNavItem(Icons.menu_book_rounded, 2, '学习'),
          _buildNavItem(Icons.person_rounded, 3, '我的'),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFFF9F1C) : Colors.white.withOpacity(0.5),
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  // 数据源移动到这里
  final List<Map<String, dynamic>> _myProjects = [
    {'title': '新世界', 'icon': Icons.add, 'isNew': true},
    {'title': '我的卧室', 'icon': Icons.bed, 'isNew': false},
    {'title': '客厅', 'icon': Icons.weekend, 'isNew': false},
    {'title': '厨房', 'icon': Icons.kitchen, 'isNew': false},
  ];

  final List<Map<String, dynamic>> _dailyMissions = [
    {'title': '让台灯闪烁', 'status': 'completed', 'icon': Icons.lightbulb_outline},
    {'title': '向风扇问好', 'status': 'locked', 'icon': Icons.wind_power},
    {'title': '扫描新设备', 'status': 'active', 'icon': Icons.qr_code_scanner},
  ];

  @override
  Widget build(BuildContext context) {
    // 只有内容部分，不需要 Scaffold
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        // 底部留白，防止被悬浮导航栏遮挡
        padding: const EdgeInsets.only(bottom: 100),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 24),
              _buildHeroSection(context),
              const SizedBox(height: 32),
              _buildSectionTitle('我的世界'),
              const SizedBox(height: 16),
              _buildMyCreationsList(context),
              const SizedBox(height: 32),
              _buildSectionTitle('今日挑战'),
              const SizedBox(height: 16),
              _buildDailyMissionsList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF2EC4B6).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2EC4B6), width: 2),
              ),
              child: const Icon(Icons.face, color: Color(0xFF2EC4B6), size: 30),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '你好，小小创客！',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
                ),
                Text(
                  'Lv.3 探索家',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFF9F1C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: const [
              Icon(Icons.local_fire_department, color: Color(0xFFFF9F1C), size: 20),
              SizedBox(width: 4),
              Text(
                '5 天',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF9F1C)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF9F1C), Color(0xFFFFBF69)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9F1C).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20, bottom: -20,
            child: Icon(Icons.auto_fix_high, size: 180, color: Colors.white.withOpacity(0.2)),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('见证魔法时刻！', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                const Text('开始魔法扫描', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SmartScanPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF9F1C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text('出发！', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
    );
  }

  Widget _buildMyCreationsList(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _myProjects.length,
        itemBuilder: (context, index) {
          final project = _myProjects[index];
          final bool isNew = project['isNew'];

          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isNew ? const Color(0xFF2EC4B6).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: isNew ? Border.all(color: const Color(0xFF2EC4B6), width: 2, style: BorderStyle.solid) : null,
              boxShadow: isNew
                  ? []
                  : [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: InkWell(
              onTap: () {
                if (isNew) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SmartScanPage()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("正在打开 ${project['title']}...")));
                }
              },
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: isNew ? Colors.white : const Color(0xFFF0F4F8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      project['icon'],
                      color: isNew ? const Color(0xFF2EC4B6) : const Color(0xFF2D3142),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    project['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isNew ? const Color(0xFF2EC4B6) : const Color(0xFF2D3142),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyMissionsList() {
    return Column(
      children: _dailyMissions.map((mission) {
        final bool isCompleted = mission['status'] == 'completed';
        final bool isLocked = mission['status'] == 'locked';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey[200] : const Color(0xFFFF9F1C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                mission['icon'],
                color: isLocked ? Colors.grey : const Color(0xFFFF9F1C),
              ),
            ),
            title: Text(
              mission['title'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : const Color(0xFF2D3142),
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: isCompleted
                ? const Icon(Icons.check_circle, color: Color(0xFF2EC4B6))
                : isLocked
                    ? const Icon(Icons.lock, color: Colors.grey)
                    : const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFFF9F1C)),
          ),
        );
      }).toList(),
    );
  }
}