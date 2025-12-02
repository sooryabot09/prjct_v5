// lib/screens/diocese_admin/diocese_notifications.dart
import 'package:flutter/material.dart';

class DioceseNotifications extends StatefulWidget {
  const DioceseNotifications({super.key});

  @override
  State<DioceseNotifications> createState() => _DioceseNotificationsState();
}

class _DioceseNotificationsState extends State<DioceseNotifications> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _targetType = 'CHURCH';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Target Audience',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _targetType,
                        decoration: const InputDecoration(
                          labelText: 'Send to',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'CHURCH', child: Text('All Churches')),
                          DropdownMenuItem(value: 'PRIEST', child: Text('All Priests')),
                          DropdownMenuItem(value: 'FORANE', child: Text('Specific Forane')),
                          DropdownMenuItem(value: 'DIOCESE', child: Text('Entire Diocese')),
                        ],
                        onChanged: (value) => setState(() => _targetType = value!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 5,
                        validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification sent')),
                      );
                    }
                  },
                  child: const Text('Send Notification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
