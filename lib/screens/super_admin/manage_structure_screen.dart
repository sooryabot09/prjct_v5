import 'package:flutter/material.dart';

class ManageStructureScreen extends StatefulWidget {
  const ManageStructureScreen({super.key});

  @override
  State<ManageStructureScreen> createState() => _ManageStructureScreenState();
}

class _ManageStructureScreenState extends State<ManageStructureScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Structure'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dioceses'),
            Tab(text: 'Foranes'),
            Tab(text: 'Churches'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DiocesesTab(),
          ForanesTab(),
          ChurchesTab(),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final types = ['Diocese', 'Forane', 'Church'];
    final currentIndex = _tabController.index;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${types[currentIndex]}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '${types[currentIndex]} Name',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (currentIndex > 0)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select ${types[currentIndex - 1]}',
                  border: const OutlineInputBorder(),
                ),
                items: const [],
                onChanged: (value) {},
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${types[currentIndex]} added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class DiocesesTab extends StatelessWidget {
  const DiocesesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final dioceses = [
      {'name': 'Diocese of Malappuram', 'code': 'MAL', 'foranes': 12, 'churches': 67},
      {'name': 'Diocese of Kozhikode', 'code': 'KOZ', 'foranes': 15, 'churches': 89},
      {'name': 'Diocese of Thalassery', 'code': 'THA', 'foranes': 10, 'churches': 54},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dioceses.length,
      itemBuilder: (context, index) {
        final diocese = dioceses[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.location_city, color: Colors.blue),
            ),
            title: Text(diocese['name'] as String),
            subtitle: Text(
              '${diocese['foranes']} Foranes • ${diocese['churches']} Churches',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ForanesTab extends StatelessWidget {
  const ForanesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final foranes = [
      {'name': 'Malappuram Forane', 'diocese': 'Malappuram', 'churches': 8},
      {'name': 'Manjeri Forane', 'diocese': 'Malappuram', 'churches': 6},
      {'name': 'Perinthalmanna Forane', 'diocese': 'Malappuram', 'churches': 7},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foranes.length,
      itemBuilder: (context, index) {
        final forane = foranes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.account_tree, color: Colors.green),
            ),
            title: Text(forane['name'] as String),
            subtitle: Text(
              '${forane['diocese']} • ${forane['churches']} Churches',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ChurchesTab extends StatelessWidget {
  const ChurchesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final churches = [
      {'name': 'St. Mary\'s Church', 'forane': 'Malappuram', 'priests': 2},
      {'name': 'Sacred Heart Church', 'forane': 'Manjeri', 'priests': 3},
      {'name': 'St. Joseph\'s Church', 'forane': 'Perinthalmanna', 'priests': 1},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: churches.length,
      itemBuilder: (context, index) {
        final church = churches[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.1),
              child: const Icon(Icons.church, color: Colors.orange),
            ),
            title: Text(church['name'] as String),
            subtitle: Text(
              '${church['forane']} Forane • ${church['priests']} Priests',
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'assign', child: Text('Assign Priests')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}