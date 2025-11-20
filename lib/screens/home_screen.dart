import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _boards = const [
    _BoardInfo(
      id: 'games',
      title: 'Games',
      gradient: [Color(0xFFFB7185), Color(0xFFF97316)],
      icon: Icons.videogame_asset_rounded,
    ),
    _BoardInfo(
      id: 'business',
      title: 'Business',
      gradient: [Color(0xFF22C55E), Color(0xFF0EA5E9)],
      icon: Icons.business_center_rounded,
    ),
    _BoardInfo(
      id: 'public_health',
      title: 'Public Health',
      gradient: [Color(0xFFF97316), Color(0xFF6366F1)],
      icon: Icons.local_hospital_rounded,
    ),
    _BoardInfo(
      id: 'study',
      title: 'Study',
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      icon: Icons.menu_book_rounded,
    ),
  ];

  void _openBoard(_BoardInfo board) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          boardId: board.id,
          boardTitle: board.title,
        ),
      ),
    );
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                accountName: Text(user?.email ?? 'User'),
                accountEmail: const Text('Chatboards'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: _openProfile,
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: _openSettings,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (_) => false);
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text('Chatboards'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _boards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent: 180,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final board = _boards[index];
            return GestureDetector(
              onTap: () => _openBoard(board),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: board.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  children: [
                    Icon(board.icon, size: 48, color: Colors.white),
                    const SizedBox(width: 16),
                    Text(
                      board.title,
                      style: const TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BoardInfo {
  final String id;
  final String title;
  final List<Color> gradient;
  final IconData icon;

  const _BoardInfo({
    required this.id,
    required this.title,
    required this.gradient,
    required this.icon,
  });
}
