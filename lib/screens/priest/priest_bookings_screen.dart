import 'package:flutter/material.dart';

class PriestBookingsScreen extends StatelessWidget {
  const PriestBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: Center(
        child: Text(
          'No bookings assigned',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}