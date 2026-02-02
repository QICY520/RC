import 'package:flutter/material.dart';
import 'parent_control_page.dart'; // 引入家长页

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // 主页同款配色
  final Color primaryOrange = const Color(0xFFFF9E1B);
  final Color primaryGreen = const Color(0xFF00D09C);
  final Color textDark = const Color(0xFF2D3436);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA), // 与主页背景一致
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              // 1. 顶部橙色卡片
              _buildOrangeHeader(),
              
              const SizedBox(height: 30),
              
              // 2. 数据统计
              Text("我的成就", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
              const SizedBox(height: 16),
              _buildStatsGrid(),

              const SizedBox(height: 30),

              // 3. 菜单列表
              Text("账户设置", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textDark)),
              const SizedBox(height: 16),
              _buildMenuSection(context),
              
              // 底部留白，防止被悬浮导航栏遮挡
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. 头部橙色卡片 ---
  Widget _buildOrangeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, const Color(0xFFFFB74D)], 
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 头像框
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
            ),
            child: Icon(Icons.face_retouching_natural_rounded, size: 40, color: primaryOrange),
          ),
          const SizedBox(width: 16),
          // 文字信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Hi, 小小创客!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Lv.3 探索家", 
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // 签到天数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded, color: primaryOrange, size: 16),
                const SizedBox(width: 4),
                Text("5 天", style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- 2. 数据方块组 ---
  Widget _buildStatsGrid() {
    return Row(
      children: [
        // 获得勋章 (金色)
        Expanded(child: _buildStatCard("获得勋章", "8", Icons.emoji_events_rounded, const Color(0xFFFFD54F))),
        const SizedBox(width: 12),
        // 完成作品 (绿色 - 主页同款)
        Expanded(child: _buildStatCard("完成作品", "12", Icons.folder_special_rounded, primaryGreen)), 
        const SizedBox(width: 12),
        // 学习时长 (浅橙色)
        Expanded(child: _buildStatCard("学习时长", "3h", Icons.timer_rounded, const Color(0xFFFF8A65))), 
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      height: 130, // 固定高度保持整齐
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE0E0E0).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: textDark)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 3. 菜单列表  ---
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          context,
          icon: Icons.rocket_launch_rounded,
          title: "我的作品库",
          color: const Color(0xFF448AFF), // 科技蓝
          onTap: () {},
        ),
        const SizedBox(height: 12),
        // ✨ 家长监管 (橙色高亮)
        _buildMenuItem(
          context,
          icon: Icons.admin_panel_settings_rounded,
          title: "家长监管模式",
          subtitle: "应用锁 / 安全审核",
          color: primaryOrange, // 使用主色调
          onTap: () => _showSecurityCheck(context),
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          context,
          icon: Icons.settings_rounded,
          title: "系统设置",
          color: Colors.grey,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required IconData icon, 
    required String title, 
    required Color color, 
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: const Color(0xFFE0E0E0).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1), // 浅色背景
                  borderRadius: BorderRadius.circular(14), // 圆角方形
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8), fontWeight: FontWeight.w600)),
                    ]
                  ],
                ),
              ),
              if (subtitle == null) // 如果没有副标题，显示对勾或箭头，这里模仿 Challenge 显示箭头
                 Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[300]),
              if (subtitle != null) // 特殊项显示锁图标或箭头
                 Icon(Icons.lock_outline_rounded, size: 18, color: color.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  // --- 安全验证弹窗 ---
  void _showSecurityCheck(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.shield_rounded, color: primaryOrange),
            const SizedBox(width: 10),
            const Text("家长验证", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("进入管理后台需要验证身份。", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                textAlign: TextAlign.center,
                maxLength: 4,
                style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                decoration: const InputDecoration(
                  hintText: "1234",
                  hintStyle: TextStyle(color: Colors.black12, letterSpacing: 2),
                  border: InputBorder.none,
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("取消", style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryOrange,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (pinController.text == "1234") {
                Navigator.pop(context); 
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ParentControlPage())); 
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("密码错误"), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating)
                );
              }
            },
            child: const Text("确认进入", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}