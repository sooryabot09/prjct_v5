import 'package:flutter/material.dart';

class GlobalServicesScreen extends StatefulWidget {
  const GlobalServicesScreen({super.key});

  @override
  State<GlobalServicesScreen> createState() => _GlobalServicesScreenState();
}

class _GlobalServicesScreenState extends State<GlobalServicesScreen> {
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Holy Mass Offering',
      'amount': 500.0,
      'active': true,
      'splits': {'PRIEST': 55, 'KAPYAR': 10, 'ALTAR': 10, 'CHOIR': 10, 'CHURCH': 15},
    },
    {
      'name': 'Wedding Ceremony',
      'amount': 5000.0,
      'active': true,
      'splits': {'PRIEST': 60, 'CHURCH': 40},
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Services'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(
                Icons.room_service,
                color: Theme.of(context).primaryColor,
              ),
              title: Text(service['name'] as String),
              subtitle: Text('₹${service['amount']}'),
              trailing: Switch(
                value: service['active'],
                onChanged: (value) {
                  setState(() {
                    service['active'] = value;
                  });
                },
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Default Split Configuration',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ...(service['splits'] as Map<String, int>).entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text('${entry.value}%'),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              child: const Text('Edit Splits'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}