import 'package:flutter/material.dart';
import 'screens/ar_coding_page_3d.dart';

void main() {
  runApp(const ARSmartHomeApp());
}

class ARSmartHomeApp extends StatelessWidget {
  const ARSmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR-SmartHome Link',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Round', // Assuming a rounded font is available or calling back to default
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _myProjects = [
    {'title': 'New World', 'icon': Icons.add, 'isNew': true},
    {'title': 'My Bedroom', 'icon': Icons.bed, 'isNew': false, 'image': 'assets/images/bedroom_placeholder.png'},
    {'title': 'Living Room', 'icon': Icons.weekend, 'isNew': false, 'image': 'assets/images/living_placeholder.png'},
    {'title': 'Kitchen', 'icon': Icons.kitchen, 'isNew': false, 'image': 'assets/images/kitchen_placeholder.png'},
  ];

  final List<Map<String, dynamic>> _dailyMissions = [
    {'title': 'Make the lamp blink', 'status': 'completed', 'icon': Icons.lightbulb_outline},
    {'title': 'Say hello to the fan', 'status': 'locked', 'icon': Icons.wind_power},
    {'title': 'Scan a new device', 'status': 'active', 'icon': Icons.qr_code_scanner},
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
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    const SizedBox(height: 24),
                    _buildHeroSection(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('My Worlds'),
                    const SizedBox(height: 16),
                    _buildMyCreationsList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Today\'s Challenges'),
                    const SizedBox(height: 16),
                    _buildDailyMissionsList(),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: _buildBottomNavigationBar(),
            ),
          ],
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
              width: 50,
              height: 50,
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
                  'Hi, Little Maker!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142),
                  ),
                ),
                Text(
                  'Level 3 Explorer',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
                '5 Days',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF9F1C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
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
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.auto_fix_high,
              size: 180,
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Time to Magic!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start Magic Scan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ARCodingPage3D()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFFF9F1C),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'GO!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
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
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildMyCreationsList() {
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
                  : [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
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
            borderRadius: BorderRadius.circular(20), // 'Claymorphism' rounded feel
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
          _buildNavItem(Icons.home_rounded, 0, 'Home'),
          _buildNavItem(Icons.explore_rounded, 1, 'Discover'),
          _buildNavItem(Icons.menu_book_rounded, 2, 'Learn'),
          _buildNavItem(Icons.person_rounded, 3, 'Profile'),
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
