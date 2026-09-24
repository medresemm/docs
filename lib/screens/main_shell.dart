import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'weekly_screen.dart';
import 'tasks_screen.dart';
import 'stats_screen.dart';
import 'add_plan_screen.dart';
import '../services/plan_service.dart';
import '../l10n/tr.dart';
import 'premium_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    WeeklyScreen(),
    TasksScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    context.watch<PlanService>();
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final service = context.read<PlanService>();
          if (!service.canAddPlan) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            );
            return;
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPlanScreen()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.calendar_today_rounded, tr(context, 'Cədvəl', 'Schedule')),
              _navItem(1, Icons.view_week_rounded, tr(context, 'Həftə', 'Week')),
              const SizedBox(width: 48),
              _navItem(2, Icons.task_alt_rounded, tr(context, 'Tapşırıq', 'Tasks')),
              _navItem(3, Icons.bar_chart_rounded, tr(context, 'Statistika', 'Stats')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
