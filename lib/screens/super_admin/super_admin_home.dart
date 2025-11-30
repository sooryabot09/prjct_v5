import 'package:flutter/material.dart';

class SuperAdminHome extends StatelessWidget {
  const SuperAdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _AdminCard(
            icon: Icons.account_tree,
            title: 'Manage Structure',
            onTap: () => Navigator.pushNamed(context, '/super-admin/structure'),
          ),
          _AdminCard(
            icon: Icons.people,
            title: 'Manage Users',
            onTap: () => Navigator.pushNamed(context, '/super-admin/users'),
          ),
          _AdminCard(
            icon: Icons.room_service,
            title: 'Global Services',
            onTap: () => Navigator.pushNamed(context, '/super-admin/services'),
          ),
          _AdminCard(
            icon: Icons.history,
            title: 'Audit Logs',
            onTap: () => Navigator.pushNamed(context, '/super-admin/audit'),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
