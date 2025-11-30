import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/church_provider.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late Razorpay _razorpay;
  bool _isProcessing = false;
  int? _selectedPriestId;
  List<User> _priests = [];
  bool _loadingPriests = false;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadPriests();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _loadPriests() async {
    setState(() => _loadingPriests = true);
    try {
      final users = await ApiService.getUsers();
      setState(() {
        _priests = users.where((u) => u.role == 'PRIEST').toList();
        _loadingPriests = false;
      });
    } catch (e) {
      setState(() => _loadingPriests = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load priests: $e')),
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _createBookingAndTransaction(response.paymentId, response.orderId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  Future<void> _createBookingAndTransaction(String? paymentId, String? orderId) async {
    try {
      final user = context.read<AuthProvider>().user!;
      final churchProvider = context.read<ChurchProvider>();

      // Create booking
      final bookingData = {
        'service_id': widget.service.serviceId,
        'parishioner_id': user.userId,
        'church_id': churchProvider.selectedChurch!.churchId,
        'priest_id': _selectedPriestId,
        'amount_paise': (widget.service.amountRupees * 100).toInt(),
      };

      final bookingResponse = await ApiService.createBooking(bookingData);
      final bookingId = bookingResponse['booking_id'];

      // Create transaction
      final transactionData = {
        'booking_id': bookingId,
        'church_id': churchProvider.selectedChurch!.churchId,
        'amount_paise': (widget.service.amountRupees * 100).toInt(),
        'method_id': 1, // RAZORPAY
        'status_id': 2, // COMPLETED
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': orderId,
        'recorded_by': user.userId,
      };

      await ApiService.createTransaction(transactionData);

      // Update booking status to PAID
      await ApiService.updateBookingStatus(bookingId, 'PAID');

      setState(() => _isProcessing = false);

      if (mounted) {
        // Refresh bookings
        context.read<BookingProvider>().loadBookings();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Booking Successful'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your booking has been confirmed and payment received.',
                ),
                const SizedBox(height: 16),
                Text(
                  'Booking ID: #$bookingId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to services
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
            content: Text('Failed to complete booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startPayment() {
    final user = context.read<AuthProvider>().user!;
    
    var options = {
      'key': 'YOUR_RAZORPAY_KEY', // Replace with actual key
      'amount': (widget.service.amountRupees * 100).toInt(),
      'name': 'Church Management',
      'description': widget.service.name,
      'prefill': {
        'contact': user.phone ?? '',
        'email': user.email,
      },
      'theme': {
        'color': '#1565C0',
      }
    };

    try {
      setState(() => _isProcessing = true);
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                      'Service Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Service',
                      value: widget.service.name,
                    ),
                    if (widget.service.description != null)
                      _DetailRow(
                        label: 'Description',
                        value: widget.service.description!,
                      ),
                    _DetailRow(
                      label: 'Amount',
                      value: '₹${widget.service.amountRupees.toStringAsFixed(2)}',
                      valueColor: Theme.of(context).primaryColor,
                      valueWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Priest selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Priest (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (_loadingPriests)
                      const Center(child: CircularProgressIndicator())
                    else if (_priests.isEmpty)
                      const Text('No priests available')
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedPriestId,
                        decoration: const InputDecoration(
                          hintText: 'Choose a priest',
                          border: OutlineInputBorder(),
                        ),
                        items: _priests.map((priest) {
                          return DropdownMenuItem<int>(
                            value: priest.userId,
                            child: Text('Fr. ${priest.name}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedPriestId = value);
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Fee distribution
            if (widget.service.splits != null && widget.service.splits!.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Distribution',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.service.splits!.map((split) {
                        final amount = widget.service.amountRupees *
                            split.percentage /
                            100;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getBeneficiaryIcon(split.beneficiaryType),
                                    size: 16,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    split.beneficiaryType,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              Text(
                                '${split.percentage}% (₹${amount.toStringAsFixed(2)})',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _startPayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(_isProcessing ? 'Processing...' : 'Proceed to Payment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBeneficiaryIcon(String type) {
    switch (type.toUpperCase()) {
      case 'PRIEST':
        return Icons.person;
      case 'KAPYAR':
        return Icons.volunteer_activism;
      case 'ALTAR':
        return Icons.table_restaurant;
      case 'CHOIR':
        return Icons.music_note;
      case 'CHURCH':
        return Icons.church;
      default:
        return Icons.account_balance;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueWeight;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: valueWeight ?? FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}