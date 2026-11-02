import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'date_helpers.dart';
import 'plan_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const GymApp());
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forma',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: appBackground,
        colorScheme: const ColorScheme.dark(
          primary: appLime,
          surface: appSurface,
          onPrimary: appBackground,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const GymHomePage(),
    );
  }
}

class GymHomePage extends StatefulWidget {
  const GymHomePage({super.key});

  @override
  State<GymHomePage> createState() => _GymHomePageState();
}

class _GymHomePageState extends State<GymHomePage> {
  int _selectedTab = 0;
  final Set<DateTime> _completedWorkouts = {};
  DateTime _selectedDate = dateOnly(DateTime.now());

  int get _points => _completedWorkouts.length * 100;

  void _completeWorkout(DateTime date) {
    final normalizedDate = dateOnly(date);
    if (_completedWorkouts.contains(normalizedDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ten trening jest już zaliczony.')),
      );
      return;
    }

    setState(() => _completedWorkouts.add(normalizedDate));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trening zaliczony! +100 punktów')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final pages = [
      DashboardPage(
        today: today,
        points: _points,
        completedWorkouts: _completedWorkouts,
        isTodayCompleted: _completedWorkouts.contains(today),
        onCompleteWorkout: () => _completeWorkout(today),
        onOpenPlan: () => setState(() => _selectedTab = 1),
        onOpenCalendar: () => setState(() => _selectedTab = 2),
      ),
      PlanPage(
        isTodayCompleted: _completedWorkouts.contains(today),
        onCompleteWorkout: () => _completeWorkout(today),
      ),
      CalendarPage(
        selectedDate: _selectedDate,
        completedWorkouts: _completedWorkouts,
        onSelectDate: (date) => setState(() => _selectedDate = dateOnly(date)),
        onCompleteWorkout: _completeWorkout,
      ),
      ProfilePage(
        points: _points,
        completedWorkouts: _completedWorkouts,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedTab, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        backgroundColor: const Color(0xFF171B18),
        indicatorColor: appLime.withValues(alpha: 0.14),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.grid_view_rounded, color: appLime),
            label: 'Pulpit',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_rounded),
            selectedIcon: Icon(Icons.fitness_center_rounded, color: appLime),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            selectedIcon: Icon(Icons.calendar_month_rounded, color: appLime),
            label: 'Kalendarz',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: appLime),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
