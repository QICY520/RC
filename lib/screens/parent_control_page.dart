import 'package:flutter/material.dart';

class ParentControlPage extends StatefulWidget {
  const ParentControlPage({super.key});

  @override
  State<ParentControlPage> createState() => _ParentControlPageState();
}

class _ParentControlPageState extends State<ParentControlPage> {
  // 主页同款配色
  final Color primaryOrange = const Color(0xFFFF9E1B);
  final Color primaryGreen = const Color(0xFF00D09C);
  final Color textDark = const Color(0xFF2D3436);
  final Color bgGrey = const Color(0xFFF5F7FA);

  // 模拟状态
  bool _isAppLocked = false;
  double _timeLimit = 45;
  
  // 模拟审核列表
  final List<Map<String, dynamic>> _auditRequests = [
    {
      'id': 1,
      'device': '智能风扇 (客厅)',
      'action': '开启电源',
      'source': '自动场景: 温度>28°',
      'time': '上午 10:05',
      'status': 'pending', // pending, approved, rejected
    },
    {
      'id': 2,
      'device': '电暖器',
      'action': '设定 28°C',
      'source': '手动控制',
      'time': '昨天',
      'status': 'rejected',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      body: Column(
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  const BackButton(color: Colors.black),
                  const Expanded(
                    child: Text(
                      "家长管理后台",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance BackButton width
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 数据概览
            _buildSectionTitle("本周学习进度"),
            const SizedBox(height: 8),
            _buildStatsCards(),
            
            const SizedBox(height: 15),

            // 2. ✨ 核心功能：物理操作审核
            _buildSectionTitle("安全审核 (物理设备)", isWarning: true),
            const SizedBox(height: 8),
            _buildAuditList(),

            const SizedBox(height: 15),

            // 3. 限制设置
            _buildSectionTitle("安全与限制"),
            const SizedBox(height: 8),
            _buildSettingsCard(),
            
            const SizedBox(height: 20),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isWarning = false}) {
    return Row(
      children: [
        if (isWarning) ...[
          const Icon(Icons.shield_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title, 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.w900, 
            color: textDark
          )
        ),
      ],
    );
  }

  // --- 1. 数据卡片 (美化版) ---
  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "使用积木", 
            "142", 
            Icons.extension_rounded, 
            const Color(0xFF7C4DFF) // 紫色
          )
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            "活跃时长", 
            "3.5h", 
            Icons.timer_rounded, 
            primaryOrange // 橙色
          )
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE0E0E0).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textDark)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 2. 审核列表 (美化版) ---
  Widget _buildAuditList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _auditRequests.length,
      itemBuilder: (context, index) {
        final item = _auditRequests[index];
        bool isPending = item['status'] == 'pending';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            // 待审核状态显示橙色边框
            border: isPending ? Border.all(color: Colors.orangeAccent, width: 2) : null,
            boxShadow: [
              BoxShadow(color: const Color(0xFFE0E0E0).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部状态栏
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending ? Colors.orange[50] : (item['status']=='approved' ? Colors.green[50] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPending ? Icons.warning_amber_rounded : (item['status']=='approved' ? Icons.check_circle_rounded : Icons.cancel_rounded),
                          size: 14,
                          color: isPending ? Colors.orange : (item['status']=='approved' ? Colors.green : Colors.grey),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isPending ? "需家长批准" : (item['status'] == 'approved' ? "已批准" : "已驳回"),
                          style: TextStyle(
                            color: isPending ? Colors.orange[800] : (item['status']=='approved' ? Colors.green[800] : Colors.grey[600]),
                            fontWeight: FontWeight.bold,
                            fontSize: 11
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(item['time'], style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              
              // 内容详情
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.bolt_rounded, color: Colors.orangeAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: item['action'], style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                              const TextSpan(text: " -> "),
                              TextSpan(text: item['device'], style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
                            ]
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text("来源: ${item['source']}", style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
              
              // 操作按钮 (仅待审核显示)
              if (isPending) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => item['status'] = 'rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[600],
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("驳回"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => item['status'] = 'approved');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text("权限已授予！设备已启动。"),
                              backgroundColor: primaryGreen,
                              behavior: SnackBarBehavior.floating,
                            )
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("批准", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                )
              ]
            ],
          ),
        );
      },
    );
  }

  // --- 3. 设置卡片 (美化版) ---
  Widget _buildSettingsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFFE0E0E0).withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("一键锁定应用", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("立即暂停所有活动，显示休息画面", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            value: _isAppLocked,
            activeColor: Colors.white,
            activeTrackColor: Colors.redAccent,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline_rounded, color: Colors.redAccent),
            ),
            onChanged: (val) => setState(() => _isAppLocked = val),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.timer_rounded, color: Colors.blueAccent),
                        ),
                        const SizedBox(width: 16),
                        const Text("每日使用时长", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text("${_timeLimit.toInt()} 分钟", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6,
                    activeTrackColor: Colors.blueAccent,
                    inactiveTrackColor: Colors.blue[100],
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 4),
                    overlayColor: Colors.blueAccent.withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _timeLimit,
                    min: 15,
                    max: 120,
                    divisions: 7,
                    label: "${_timeLimit.toInt()} 分钟",
                    onChanged: (val) => setState(() => _timeLimit = val),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}