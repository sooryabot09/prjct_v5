import 'package:flutter/material.dart';

class HelpRequestScreen extends StatelessWidget {
  const HelpRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Help'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Request assistance from nearby priests',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Send Help Request'),
            ),
          ],
        ),
      ),
    );
  }
}