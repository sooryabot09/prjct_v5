import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyReportsScreen extends StatefulWidget {
  const MonthlyReportsScreen({super.key});

  @override
  State<MonthlyReportsScreen> createState() => _MonthlyReportsScreenState();
}

class _MonthlyReportsScreenState extends State<MonthlyReportsScreen> {
  DateTime _selectedMonth = DateTime.now();
  
  // Mock data
  final Map<String, dynamic> _reportData = {
    'totalRevenue': 125000.0,
    'cashTransactions': 45000.0,
    'onlineTransactions': 80000.0,
    'totalBookings': 156,
    'completedBookings': 142,
    'pendingBookings': 14,
    'topServices': [
      {'name': 'Holy Mass', 'count': 45, 'revenue': 45000.0},
      {'name': 'Wedding', 'count': 8, 'revenue': 40000.0},
      {'name': 'Baptism', 'count': 25, 'revenue': 25000.0},
    ],
    'splitBreakdown': {
      'PRIEST': 55000.0,
      'CHURCH': 45000.0,
      'KAPYAR': 12500.0,
      'ALTAR': 7500.0,
      'CHOIR': 5000.0,
    },
  };

  Future<void> _selectMonth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedMonth = date;
      });
    }
  }

  Future<void> _exportReport(String format) async {
    // Simulate export
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as $format...'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported successfully as $format'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Reports'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            onSelected: _exportReport,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
              const PopupMenuItem(value: 'CSV', child: Text('Export as CSV')),
              const PopupMenuItem(value: 'Excel', child: Text('Export as Excel')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Selector
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.calendar_month,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Report Period'),
                subtitle: Text(DateFormat('MMMM yyyy').format(_selectedMonth)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _selectMonth,
              ),
            ),
            const SizedBox(height: 16),

            // Revenue Summary
            Text(
              'Revenue Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Total Revenue',
                    value: '₹${_formatCurrency(_reportData['totalRevenue'])}',
                    icon: Icons.account_balance_wallet,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Bookings',
                    value: '${_reportData['totalBookings']}',
                    icon: Icons.book,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Cash',
                    value: '₹${_formatCurrency(_reportData['cashTransactions'])}',
                    icon: Icons.money,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Online',
                    value: '₹${_formatCurrency(_reportData['onlineTransactions'])}',
                    icon: Icons.payment,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Top Services
            Text(
              'Top Services',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < _reportData['topServices'].length; i++) ...[
                    if (i > 0) const Divider(height: 1),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(_reportData['topServices'][i]['name']),
                      subtitle: Text('${_reportData['topServices'][i]['count']} bookings'),
                      trailing: Text(
                        '₹${_formatCurrency(_reportData['topServices'][i]['revenue'])}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Split Breakdown
            Text(
              'Revenue Distribution',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var entry in (_reportData['splitBreakdown'] as Map<String, double>).entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                entry.key,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: entry.value / _reportData['totalRevenue'],
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getColorForBeneficiary(entry.key),
                                ),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 80,
                              child: Text(
                                '₹${_formatCurrency(entry.value)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Booking Status
            Text(
              'Booking Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            '${_reportData['completedBookings']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const Text('Completed', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey[300],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          const Icon(Icons.pending, color: Colors.orange, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            '${_reportData['pendingBookings']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          const Text('Pending', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  Color _getColorForBeneficiary(String beneficiary) {
    switch (beneficiary) {
      case 'PRIEST':
        return Colors.blue;
      case 'CHURCH':
        return Colors.green;
      case 'KAPYAR':
        return Colors.orange;
      case 'ALTAR':
        return Colors.purple;
      case 'CHOIR':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
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