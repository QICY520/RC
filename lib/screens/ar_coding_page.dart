import 'package:flutter/material.dart';

class ARCodingPage extends StatefulWidget {
  const ARCodingPage({super.key});

  @override
  State<ARCodingPage> createState() => _ARCodingPageState();
}

class _ARCodingPageState extends State<ARCodingPage> {
  // Theme Colors
  final Color primaryOrange = const Color(0xFFFF9F1C);
  final Color secondaryTeal = const Color(0xFF2EC4B6);
  final Color bgOffWhite = const Color(0xFFFBFBFB);
  final Color textDarkBlue = const Color(0xFF2D3142);

  // Mock State
  String _selectedTab = 'Events';
  bool _isPythonView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgOffWhite,
      body: Stack(
        children: [
          Column(
            children: [
              // 1. Top Section: AR Simulation (60%)
              Expanded(
                flex: 6,
                child: _buildARView(),
              ),
              
              // 2. Middle: Resizable Handle Visual
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: bgOffWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // 3. Bottom Section: Coding Workshop (40%)
              Expanded(
                flex: 4,
                child: _buildCodingPanel(),
              ),
            ],
          ),

          // 4. Floating Action Button (The Trigger)
          Positioned(
            right: 24,
            bottom: MediaQuery.of(context).size.height * 0.4 - 28, // Position at junction
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.large(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Simulating Magic... ✨')),
                  );
                },
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                elevation: 0,
                child: const Icon(Icons.play_arrow_rounded, size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildARView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Placeholder (Living Room)
        Container(
          color: Colors.grey[900],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_rounded, size: 60, color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 12),
              Text(
                'Camera Feed Simulation',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontFamily: 'Round',
                ),
              ),
            ],
          ),
        ),

        // Overlay UI
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                // Top Left: Back Button (Glassmorphism)
                Positioned(
                  left: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),

                // Center: Scanning Reticle
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      children: [
                        // Corners
                        Align(alignment: Alignment.topLeft, child: _buildCorner(0)),
                        Align(alignment: Alignment.topRight, child: _buildCorner(1)),
                        Align(alignment: Alignment.bottomLeft, child: _buildCorner(2)),
                        Align(alignment: Alignment.bottomRight, child: _buildCorner(3)),
                        
                        // Tag Label
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 140),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: secondaryTeal,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Smart Lamp',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Right: AI Helper
                Positioned(
                  right: 0,
                  top: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          'Try turning on the lamp!',
                          style: TextStyle(
                            color: textDarkBlue,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: primaryOrange.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(int index) {
    // 0: TL, 1: TR, 2: BL, 3: BR
    final isTop = index < 2;
    final isLeft = index % 2 == 0;
    
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.white, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCodingPanel() {
    return Container(
      color: bgOffWhite,
      child: Column(
        children: [
          // Category Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildTab('Events', const Color(0xFFFFD166), true),
                    const SizedBox(width: 12),
                    _buildTab('Actions', const Color(0xFF118AB2), false),
                    const SizedBox(width: 12),
                    _buildTab('Control', const Color(0xFFEF476F), false),
                  ],
                ),
                
                // View Toggle
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      _buildViewToggleIcon(Icons.extension_rounded, !_isPythonView),
                      _buildViewToggleIcon(Icons.code_rounded, _isPythonView),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Workspace Canvas
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Block 1: Event
                  _buildCodeBlock(
                    color: const Color(0xFFFFD166),
                    icon: Icons.access_time_filled_rounded,
                    content: RichText(
                      text: TextSpan(
                        style: TextStyle(color: textDarkBlue, fontWeight: FontWeight.bold, fontFamily: 'Round'),
                        children: const [
                          TextSpan(text: 'When '),
                          TextSpan(text: ' [Mom] ', style: TextStyle(backgroundColor: Colors.white54)),
                          TextSpan(text: ' Arrives'),
                        ],
                      ),
                    ),
                    hasConnector: true,
                  ),
                  
                  // Connector Line
                  Container(
                    margin: const EdgeInsets.only(left: 24),
                    width: 4,
                    height: 12,
                    color: Colors.grey[300],
                  ),

                  // Block 2: Action
                  _buildCodeBlock(
                    color: const Color(0xFF118AB2),
                    icon: Icons.lightbulb_rounded,
                    content: RichText(
                      text: const TextSpan(
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Round'),
                        children: [
                          TextSpan(text: 'Set '),
                          TextSpan(text: ' [Lamp] ', style: TextStyle(color: Colors.black87, backgroundColor: Colors.white)),
                          TextSpan(text: ' to '),
                          TextSpan(text: ' [Warm Light] ', style: TextStyle(color: Colors.black87, backgroundColor: Colors.white)),
                        ],
                      ),
                    ),
                    hasConnector: false,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, Color color, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildViewToggleIcon(IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPythonView = icon == Icons.code_rounded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: isActive
            ? const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                   BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              )
            : null,
        child: Icon(
          icon,
          size: 18,
          color: isActive ? textDarkBlue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCodeBlock({
    required Color color,
    required IconData icon,
    required Widget content,
    required bool hasConnector,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8)),
          const SizedBox(width: 12),
          Expanded(child: content),
        ],
      ),
    );
  }
}
