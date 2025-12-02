// lib/screens/church_admin/onsite_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/church_provider.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';

class OnsiteBookingScreen extends StatefulWidget {
  const OnsiteBookingScreen({super.key});

  @override
  State<OnsiteBookingScreen> createState() => _OnsiteBookingScreenState();
}

class _OnsiteBookingScreenState extends State<OnsiteBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  Service? _selectedService;
  User? _selectedParishioner;
  String _paymentMethod = 'CASH';
  bool _isProcessing = false;
  bool _searchingUser = false;
  List<User> _parishioners = [];
  List<Service> _services = [];
  bool _loadingServices = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    setState(() => _loadingServices = true);
    try {
      final churchProvider = context.read<ChurchProvider>();
      if (churchProvider.selectedChurch != null) {
        await churchProvider.loadServices(
          churchProvider.selectedChurch!.churchId,
        );
        setState(() {
          _services = churchProvider.services;
          _loadingServices = false;
        });
      }
    } catch (e) {
      setState(() => _loadingServices = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load services: $e')),
        );
      }
    }
  }

  Future<void> _searchParishioners(String query) async {
    if (query.length < 2) return;
    
    setState(() => _searchingUser = true);
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _parishioners = users
            .where((u) =>
                u.role == 'PARISHIONER' &&
                (u.name.toLowerCase().contains(query.toLowerCase()) ||
                    u.email.toLowerCase().contains(query.toLowerCase())))
            .toList();
        _searchingUser = false;
      });
    } catch (e) {
      setState(() => _searchingUser = false);
    }
  }

  Future<void> _createOnsiteBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      final user = context.read<AuthProvider>().user!;
      final churchProvider = context.read<ChurchProvider>();

      // Determine if user exists or create new
      int parishionerId;
      if (_selectedParishioner != null) {
        parishionerId = _selectedParishioner!.userId;
      } else {
        // Create new parishioner
        final newUserData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': 'temp123456', // Temporary password
          'church_id': churchProvider.selectedChurch!.churchId,
          'role_id': 1, // PARISHIONER
        };
        
        final userResponse = await ApiService.register(newUserData);
        parishionerId = userResponse['user']['user_id'];
      }

      final amountPaise = (double.parse(_amountController.text) * 100).toInt();

      // Create booking
      final bookingData = {
        'service_id': _selectedService!.serviceId,
        'parishioner_id': parishionerId,
        'church_id': churchProvider.selectedChurch!.churchId,
        'amount_paise': amountPaise,
      };

      final bookingResponse = await ApiService.createBooking(bookingData);
      final bookingId = bookingResponse['booking_id'];

      // Determine transaction status
      int statusId;
      if (_paymentMethod == 'CASH' && amountPaise > 100000) {
        // Over ₹1000 - needs review
        statusId = 4; // PENDING_REVIEW
      } else {
        statusId = 2; // COMPLETED
      }

      // Get method ID
      int methodId;
      switch (_paymentMethod) {
        case 'CASH':
          methodId = 2;
          break;
        case 'GPAY':
          methodId = 3;
          break;
        default:
          methodId = 2;
      }

      // Create transaction
      final transactionData = {
        'booking_id': bookingId,
        'church_id': churchProvider.selectedChurch!.churchId,
        'amount_paise': amountPaise,
        'method_id': methodId,
        'status_id': statusId,
        'recorded_by': user.userId,
      };

      await ApiService.createTransaction(transactionData);

      // Update booking status
      await ApiService.updateBookingStatus(
        bookingId,
        statusId == 2 ? 'PAID' : 'PENDING',
      );

      setState(() => _isProcessing = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(
              statusId == 2 ? Icons.check_circle : Icons.pending,
              color: statusId == 2 ? Colors.green : Colors.orange,
              size: 64,
            ),
            title: Text(
              statusId == 2 ? 'Booking Created' : 'Pending Review',
            ),
            content: Text(
              statusId == 2
                  ? 'Onsite booking created successfully.\nBooking ID: #$bookingId'
                  : 'Booking created but requires manager approval due to amount.\nBooking ID: #$bookingId',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetForm();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _amountController.clear();
    setState(() {
      _selectedService = null;
      _selectedParishioner = null;
      _paymentMethod = 'CASH';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onsite Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Onsite Booking',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Search existing parishioner
              Text(
                'Search Existing Parishioner',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search by name or email',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _searchParishioners,
              ),
              if (_searchingUser) const LinearProgressIndicator(),
              if (_parishioners.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _parishioners.take(5).length,
                    itemBuilder: (context, index) {
                      final parishioner = _parishioners[index];
                      return ListTile(
                        title: Text(parishioner.name),
                        subtitle: Text(parishioner.email),
                        onTap: () {
                          setState(() {
                            _selectedParishioner = parishioner;
                            _nameController.text = parishioner.name;
                            _emailController.text = parishioner.email;
                            _phoneController.text = parishioner.phone ?? '';
                            _parishioners.clear();
                          });
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // Manual entry
              Text(
                _selectedParishioner != null
                    ? 'Selected Parishioner'
                    : 'Or Enter New Parishioner',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Service selection
              Text(
                'Select Service',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              
              _loadingServices
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<Service>(
                      initialValue: _selectedService,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Choose a service',
                      ),
                      items: _services.map((service) {
                        return DropdownMenuItem(
                          value: service,
                          child: Text(
                            '${service.name} - ₹${service.amountRupees}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedService = value;
                          _amountController.text =
                              value?.amountRupees.toString() ?? '';
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a service' : null,
                    ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (₹) *',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (double.tryParse(value!) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Payment method
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Cash'),
                      value: 'CASH',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() => _paymentMethod = value!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('GPay/UPI'),
                      value: 'GPAY',
                      groupValue: _paymentMethod,
                      onChanged: (value) {
                        setState(() => _paymentMethod = value!);
                      },
                    ),
                  ),
                ],
              ),

              if (_paymentMethod == 'CASH')
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cash payments over ₹1,000 require manager approval',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _createOnsiteBooking,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Create Booking'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}