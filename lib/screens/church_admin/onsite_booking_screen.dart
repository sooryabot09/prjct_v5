import 'package:flutter/material.dart';

class OnsiteBookingScreen extends StatelessWidget {
  const OnsiteBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onsite Booking')),
      body: const Center(child: Text('Create onsite bookings')),
    );
  }
}