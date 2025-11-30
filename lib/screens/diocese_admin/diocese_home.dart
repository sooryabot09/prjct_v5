import 'package:flutter/material.dart';

class DioceseHome extends StatelessWidget {
  const DioceseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diocese Admin'),
      ),
      body: const Center(
        child: Text('Diocese administration dashboard'),
      ),
    );
  }
}