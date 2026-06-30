import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'tasks_screen.dart';
import 'plan_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  void _logout() {
    AuthService().signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final screens = [
      const TasksScreen(),
      const PlanScreen(),
      const _InsightsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowPlan AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Welcome, ${user?.email ?? 'User'}'),
          ),
          Expanded(child: screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
        ],
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  const _InsightsTab();
  @override
  Widget build(BuildContext context) => const Center(child: Text('Insights'));
}
