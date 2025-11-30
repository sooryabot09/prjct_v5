import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  String _selectedFilter = 'ALL';
  final _searchController = TextEditingController();

  // Mock data for now - replace with actual API call
  final List<Map<String, dynamic>> _logs = [
    {
      'action': 'USER_CREATED',
      'user': 'admin@church.com',
      'target': 'john@church.com',
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
      'details': 'Created new priest account',
    },
    {
      'action': 'SERVICE_MODIFIED',
      'user': 'admin@church.com',
      'target': 'Holy Mass Offering',
      'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
      'details': 'Updated service amount to ₹500',
    },
    {
      'action': 'PAYMENT_APPROVED',
      'user': 'manager@church.com',
      'target': 'Transaction #1234',
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
      'details': 'Approved cash payment of ₹2000',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getActionColor(String action) {
    if (action.contains('CREATE')) return Colors.green;
    if (action.contains('DELETE')) return Colors.red;
    if (action.contains('MODIFY') || action.contains('UPDATE')) return Colors.orange;
    if (action.contains('APPROVE')) return Colors.blue;
    return Colors.grey;
  }

  IconData _getActionIcon(String action) {
    if (action.contains('CREATE')) return Icons.add_circle_outline;
    if (action.contains('DELETE')) return Icons.delete_outline;
    if (action.contains('MODIFY') || action.contains('UPDATE')) return Icons.edit_outlined;
    if (action.contains('APPROVE')) return Icons.check_circle_outline;
    if (action.contains('PAYMENT')) return Icons.payment;
    if (action.contains('USER')) return Icons.person_outline;
    return Icons.history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Exporting audit logs...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search logs...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedFilter == 'ALL',
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'ALL');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('User Actions'),
                        selected: _selectedFilter == 'USER',
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'USER');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Financial'),
                        selected: _selectedFilter == 'FINANCIAL',
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'FINANCIAL');
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('System'),
                        selected: _selectedFilter == 'SYSTEM',
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'SYSTEM');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No audit logs found',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _getActionColor(log['action']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getActionIcon(log['action']),
                              color: _getActionColor(log['action']),
                            ),
                          ),
                          title: Text(
                            log['action'].replaceAll('_', ' '),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(log['details']),
                              const SizedBox(height: 4),
                              Text(
                                'By: ${log['user']} • ${DateFormat('dd MMM yyyy, hh:mm a').format(log['timestamp'])}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'details',
                                child: Text('View Details'),
                              ),
                              const PopupMenuItem(
                                value: 'export',
                                child: Text('Export'),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'details') {
                                _showLogDetails(log);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(log['action'].replaceAll('_', ' ')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'User', value: log['user']),
            _DetailRow(label: 'Target', value: log['target']),
            _DetailRow(
              label: 'Timestamp',
              value: DateFormat('dd MMM yyyy, hh:mm:ss a').format(log['timestamp']),
            ),
            _DetailRow(label: 'Details', value: log['details']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}