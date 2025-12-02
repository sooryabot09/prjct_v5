import 'package:flutter/material.dart';
import 'diocese_dashboard.dart';
import 'diocese_notifications.dart';
import 'diocese_complaints.dart';
import 'diocese_reports.dart';

class DioceseHomeComplete extends StatefulWidget {
  const DioceseHomeComplete({super.key});

  @override
  State<DioceseHomeComplete> createState() => _DioceseHomeCompleteState();
}

class _DioceseHomeCompleteState extends State<DioceseHomeComplete> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DioceseDashboard(),
    const DioceseNotifications(),
    const DioceseComplaints(),
    const DioceseReports(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment_outlined),
            activeIcon: Icon(Icons.assessment),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}