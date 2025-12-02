// lib/screens/church_admin/manage_services_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/church_provider.dart';
import '../../models/user.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final churchProvider = context.read<ChurchProvider>();
      if (churchProvider.selectedChurch != null) {
        await churchProvider.loadServices(
          churchProvider.selectedChurch!.churchId,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load services: $e')),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  void _showServiceDialog({Service? service}) {
    showDialog(
      context: context,
      builder: (context) => ServiceDialog(
        service: service,
        onSaved: () {
          Navigator.pop(context);
          _loadServices();
        },
      ),
    );
  }

  Future<void> _deleteService(Service service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Call delete API here
      _loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ChurchProvider>(
              builder: (context, provider, _) {
                if (provider.services.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.room_service, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No services yet',
                          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.services.length,
                  itemBuilder: (context, index) {
                    final service = provider.services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: Icon(
                          Icons.room_service,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '₹${service.amountRupees.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showServiceDialog(service: service);
                            } else if (value == 'delete') {
                              _deleteService(service);
                            }
                          },
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (service.description != null) ...[
                                  const Text(
                                    'Description',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(service.description!),
                                  const SizedBox(height: 16),
                                ],
                                if (service.splits != null &&
                                    service.splits!.isNotEmpty) ...[
                                  const Text(
                                    'Fee Distribution',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...service.splits!.map((split) {
                                    final amount = service.amountRupees *
                                        split.percentage /
                                        100;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(split.beneficiaryType),
                                          Text(
                                            '${split.percentage}% (₹${amount.toStringAsFixed(2)})',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ServiceDialog extends StatefulWidget {
  final Service? service;
  final VoidCallback onSaved;

  const ServiceDialog({super.key, this.service, required this.onSaved});

  @override
  State<ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  final Map<String, int> _splits = {
    'PRIEST': 0,
    'KAPYAR': 0,
    'ALTAR': 0,
    'CHOIR': 0,
    'CHURCH': 0,
  };
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description ?? '';
      _amountController.text = widget.service!.amountRupees.toString();
      
      // Load existing splits
      for (var split in widget.service!.splits ?? []) {
        _splits[split.beneficiaryType] = split.percentage;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  int get _totalPercentage => _splits.values.reduce((a, b) => a + b);

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_totalPercentage != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Split percentages must total 100%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final churchProvider = context.read<ChurchProvider>();
      final serviceData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'amount_paise': (double.parse(_amountController.text) * 100).toInt(),
        'church_id': churchProvider.selectedChurch!.churchId,
        'splits': _splits.entries
            .where((e) => e.value > 0)
            .map((e) => {
                  'beneficiary_type': e.key,
                  'percentage': e.value,
                })
            .toList(),
      };

      // Call API to create service
      // For now, just show success
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service saved successfully')),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null ? 'Add Service' : 'Edit Service'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Service Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹)',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(v!) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              const Text(
                'Split Percentages',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              ..._splits.keys.map((beneficiary) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(beneficiary),
                      ),
                      Expanded(
                        child: Slider(
                          value: _splits[beneficiary]!.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 20,
                          label: '${_splits[beneficiary]}%',
                          onChanged: (value) {
                            setState(() {
                              _splits[beneficiary] = value.toInt();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text('${_splits[beneficiary]}%'),
                      ),
                    ],
                  ),
                );
              }),
              
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _totalPercentage == 100
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:'),
                    Text(
                      '$_totalPercentage%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _totalPercentage == 100
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveService,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}