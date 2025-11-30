import 'package:flutter/material.dart';


class ManageServicesScreen extends StatelessWidget {
  const ManageServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Services')),
      body: const Center(child: Text('Services management')),
    );
  }
}