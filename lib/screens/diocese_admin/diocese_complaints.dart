// lib/screens/diocese_admin/diocese_complaints.dart
import 'package:flutter/material.dart';

class DioceseComplaints extends StatelessWidget {
  const DioceseComplaints({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints Management'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(0.1),
                child: const Icon(Icons.support_agent, color: Colors.orange),
              ),
              title: Text('Complaint #${index + 1}'),
              subtitle: const Text('From St. Mary\'s Church'),
              trailing: Chip(
                label: const Text('Open', style: TextStyle(fontSize: 11)),
                backgroundColor: Colors.orange.withOpacity(0.2),
              ),
              onTap: () {
                // Show complaint details
              },
            ),
          );
        },
      ),
    );
  }
}