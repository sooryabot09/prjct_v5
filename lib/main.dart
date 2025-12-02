// lib/main.dart - Complete with all navigation
import 'package:flutter/material.dart';
import 'package:prjct_v5/screens/parishioner/my_booking_screen.dart';
import 'package:provider/provider.dart';

import 'screens/priest/send_notification_screen.dart';
import 'screens/priest/help_request_screen_complete.dart';
import 'screens/diocese_admin/diocese_home_complete.dart';
import 'screens/church_admin/approvals_queue_screen.dart';
import 'screens/church_admin/monthly_reports_screen.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/church_provider.dart';
import 'providers/booking_provider.dart';

// Auth Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

// Parishioner Screens
import 'screens/parishioner/parishioner_home.dart';
import 'screens/parishioner/profile_screen.dart';
import 'screens/parishioner/service_catalog_screen.dart';
// ignore: unused_import
import 'screens/parishioner/booking_screen.dart';
import 'screens/parishioner/events_screen.dart';
import 'screens/parishioner/complaints_screen.dart';
import 'screens/parishioner/search_directory_screen.dart';

// Priest Screens
// ignore: unused_import
import 'screens/priest/priest_home.dart';
import 'screens/priest/priest_calendar_screen.dart';
import 'screens/priest/priest_bookings_screen.dart';

// Church Admin Screens
import 'screens/church_admin/admin_home.dart';
import 'screens/church_admin/manage_services_screen.dart';
import 'screens/church_admin/onsite_booking_screen.dart';
import 'screens/church_admin/transactions_screen.dart';

// Diocese Admin Screens

// Super Admin Screens
import 'screens/super_admin/super_admin_home.dart';
import 'screens/super_admin/manage_structure_screen.dart';
import 'screens/super_admin/manage_users_screen.dart';
import 'screens/super_admin/audit_logs_screen.dart';
import 'screens/super_admin/global_services_screen.dart';

// Common Screens
import 'screens/common/notifications_screen.dart';
import 'screens/common/reports_screen.dart';

// Utils
import 'utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChurchProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Church Management System',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/reports': (context) => const ReportsScreen(),
          // Parishioner routes
          '/parishioner/home': (context) => const ParishionerHome(),
          '/parishioner/profile': (context) => const ProfileScreen(),
          '/parishioner/services': (context) => const ServiceCatalogScreen(),
          '/parishioner/bookings': (context) => const MyBookingsScreen(),
          '/parishioner/events': (context) => const EventsScreen(),
          '/parishioner/complaints': (context) => const ComplaintsScreen(),
          '/parishioner/search': (context) => const SearchDirectoryScreen(),
          // Priest routes
          '/priest/home': (context) => const PriestHome(),
          '/priest/calendar': (context) => const PriestCalendarScreen(),
          '/priest/notifications-send': (context) => const SendNotificationScreenComplete(),
          '/priest/help-complete': (context) => const HelpRequestScreenComplete(),
          '/priest/bookings': (context) => const PriestBookingsScreen(),
          // Church Admin routes
          '/admin/home': (context) => const AdminHome(),
          '/admin/services': (context) => const ManageServicesScreen(),
          '/admin/onsite-booking': (context) => const OnsiteBookingScreen(),
          '/admin/transactions': (context) => const TransactionsScreen(),
          '/admin/approvals': (context) => const ApprovalsQueueScreen(),
          '/admin/reports': (context) => const MonthlyReportsScreen(),

          // Diocese Admin routes
          '/diocese/home-complete': (context) => const DioceseHomeComplete(),

          // Super Admin routes
          '/super-admin/home': (context) => const SuperAdminHome(),
          '/super-admin/structure': (context) => const ManageStructureScreen(),
          '/super-admin/users': (context) => const ManageUsersScreen(),
          '/super-admin/audit': (context) => const AuditLogsScreen(),
          '/super-admin/services': (context) => const GlobalServicesScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        // Route based on user role
        switch (auth.user?.role) {
          case 'PARISHIONER':
            return const ParishionerHome();
          case 'PRIEST':
            return const PriestHome();
          case 'CHURCH_ADMIN':
            return const AdminHome();
          case 'DIOCESE_ADMIN':
            return const DioceseHomeComplete();
          case 'SUPER_ADMIN':
            return const SuperAdminHome();
          default:
            return const LoginScreen();
        }
      },
    );
  }
}

// lib/screens/priest/priest_home.dart - Updated with navigation
class PriestHome extends StatefulWidget {
  const PriestHome({super.key});

  @override
  State<PriestHome> createState() => _PriestHomeState();
}

class _PriestHomeState extends State<PriestHome> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const PriestDashboard(),
    const PriestCalendarScreen(),
    const PriestBookingsScreen(),
    const PriestProfile(),
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
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class PriestDashboard extends StatelessWidget {
  const PriestDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    // ignore: deprecated_member_use
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Fr. ${user?.name ?? ""}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (user?.churchName != null)
                    Text(
                      user!.churchName!,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.event,
                          title: 'Today\'s Events',
                          value: '3',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.book,
                          title: 'Bookings',
                          value: '12',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.send,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Send Notification'),
                      subtitle: const Text('Notify your parishioners'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, '/priest/notifications');
                      },
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Request Help'),
                      subtitle: const Text('Get assistance from nearby priests'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, '/priest/help');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PriestProfile extends StatelessWidget {
  const PriestProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    // ignore: deprecated_member_use
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      user?.name[0] ?? 'F',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Fr. ${user?.name ?? ""}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (user?.motto != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${user!.motto!}"',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (user?.email != null)
                    _InfoCard(
                      icon: Icons.email,
                      label: 'Email',
                      value: user!.email,
                    ),
                  if (user?.phone != null)
                    _InfoCard(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: user!.phone!,
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.read<AuthProvider>().logout(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}