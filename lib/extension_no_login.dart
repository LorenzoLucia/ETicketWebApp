
import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/wheel_time_picker_widget.dart';

import 'package:eticket_web_app/services/app_state.dart';
import 'package:eticket_web_app/services/utils.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ExtensionNoLogin extends StatefulWidget {
  final String id;
  final ApiService apiService;

  const ExtensionNoLogin({
    super.key,
    required this.id,
    required this.apiService,
  });

  @override
  _ExtensionPageState createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionNoLogin> {
  String? selectedZone;
  int selectedTimeHours = 1; // Default to 1 hour
  int selectedTimeMinutes = 0; // Default to 0 minutes
  double price = 0.0;
  String? id;
  late Map<String,dynamic> ticket_info;
  DateTime expirationDateTime = DateTime.now();
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    id = widget.id;
    loadTicket();
  }

  Map<String, double> zonePrices = {};

  Future<void> loadTicket() async {
    try {
      final response = await widget.apiService.loadTicket(id!);
      final prices = await widget.apiService.fetchZonePrices();
      setState(() {
        expirationDateTime = DateTime.parse(response['end_time']);
        ticket_info = response;
        selectedZone = ticket_info['zone'];
        zonePrices = Map<String, double>.from(prices);
        calculatePrice();
      });
    } catch (e) {
      // Handle error
      print('Error loading plates: $e');
    }
  }

  void calculatePrice() {
    if (selectedZone != null) {
      setState(() {
        price = double.parse(
          (zonePrices[selectedZone]! *
                  (selectedTimeHours + selectedTimeMinutes / 60))
              .toStringAsFixed(1),
        );
      });
    }
  }

  String calculateTicketEndTime() {
    DateTime date = expirationDateTime.add(
      Duration(hours: selectedTimeHours, minutes: selectedTimeMinutes),
    );
    Map<int, String> months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December",
    };

    String month = months[date.month]!;
    int day = date.day;
    int hour = date.hour;
    int minutes = date.minute;

    return '$day of $month at ${hour.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select extension time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedZone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Select Extension Duration:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TimePickerTextField(
                    ticketEndTime: expirationDateTime,
                    title: "Select Extension Time",
                    initialTime: Duration(hours: now.hour, minutes: now.minute),
                    shortDurationWarning:
                        "Ticket extension time must be at least 5 minutes!",
                    onTimeChanged: (Duration value) {
                      setState(() {
                        selectedTimeHours = value.inHours;
                        selectedTimeMinutes = value.inMinutes.remainder(60);
                      });
                      calculatePrice();
                    },
                  ),
                  SizedBox(width: 25),
                  Text(
                    'New End Time: ${calculateTicketEndTime()}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            Text(
              selectedZone != null
                  ? 'Price: €${price.toStringAsFixed(2)}'
                  : 'Please select a zone to see the price',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
              onPressed: selectedZone != null
                ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => PayScreenNoLogin(
                      amount: price,
                      duration: selectedTimeHours + selectedTimeMinutes / 60,
                      plate: ticket_info['plate'],
                      id: id!,
                      zone: selectedZone!,
                      // expirationDateTime: expirationDateTime,
                    ),
                    ),
                  );
                  }
                : null,
              child: Text('Proceed to Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class PayScreenNoLogin extends StatefulWidget {
  final double amount;
  final double duration;
  final String zone;
  final String? id;
  final String? plate;

  const PayScreenNoLogin({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
  });

  @override
  _PayScreenNoLoginState createState() => _PayScreenNoLoginState();
}

class _PayScreenNoLoginState extends State<PayScreenNoLogin> {
  // final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  List<Map<String, String>> paymentMethods = [];
  late final String _hasRegisteredPaymentMethodsFuture = '';

  @override
  void initState() {
    super.initState();
  }


  Future<List<Map<String,String>>> hasRegisteredPaymentMethods(ApiService apiService) async {
      return [];
    try {
      return await apiService.fetchPaymentMethods();

    } catch (e) {
      print('Error loading plates: $e');
      return [];
    }

  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String,String>>>(
      future: hasRegisteredPaymentMethods(Provider.of<AppState>(context, listen: false).apiService!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Payment')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Payment')),
            body: Center(child: Text('Error loading payment methods')),
          );
        } else if (snapshot.hasData) {
          return NewPaymentMethodNoLogin(
            amount: widget.amount,
            duration: widget.duration,
            zone: widget.zone,
            id: widget.id,
            plate: widget.plate,
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('Payment')),
            body: Center(child: Text('No registered payment methods found')),
          );
        }
      },
    );
  }
}

class NewPaymentMethodNoLogin extends StatelessWidget {
  final double amount;
  final double duration;
  final String zone;
  final String? id;
  final String? plate;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController cardOwnerController = TextEditingController();
  // final ApiService apiService;

  NewPaymentMethodNoLogin({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    // required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final apiService = appState.apiService!;
    return Scaffold(
      appBar: AppBar(title: Text('Add Payment Method')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to Pay: €${amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cardOwnerController,
                decoration: InputDecoration(
                  labelText: 'Card Owner',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z\s]'),
                            ),
                          ],
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card owner name and surname';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]'),
                            ),
                            CardNumberFormatter(),
                          ],
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  if (value.length != 19) { // 16 digits + 3 spaces
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: expiryDateController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date (MM/YY)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9/]'),
                            ),
                            CardExpiryDateFormatter(),
                          ],
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the expiry date';
                  }
                  if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
                    return 'Enter a valid expiry date (MM/YY)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cvcController,
                decoration: InputDecoration(
                  labelText: 'CVC',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]'),
                            ),
                            CvcFormatter(),
                          ],
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the CVC';
                  }
                  if (value.length != 3) {
                    return 'CVC must be 3 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  child: Text('Pay Now'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => PayNowPageNoLogin(
                                    cardNumber: cardNumberController.text,
                                    cardOwner: cardOwnerController.text,
                                    expiryDate: expiryDateController.text,
                                    cvc: cvcController.text,
                                    amount: amount,
                                    duration: duration,
                                    zone: zone,
                                    id: id,
                                    plate: plate,
                                  ),
                            ),
                          );
                        
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error registering payment method: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PayNowPageNoLogin extends StatelessWidget {
  final double amount;
  final double duration;
  final String zone;
  final String? id;
  final String? plate;
  final String cardNumber;
  final String cardOwner;
  final String expiryDate;
  final String cvc;

  const PayNowPageNoLogin({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate, required this.cardNumber, required this.cardOwner, required this.expiryDate, required this.cvc,

  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final apiService = appState.apiService!;
    return Scaffold(
      appBar: AppBar(title: Text('Confirm Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount to Pay: €${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                child: Text('Confirm Payment'),
                onPressed: () async {
                  try {
                    final response = await apiService.payTicketNoLogin(
                      plate ?? '',
                      cardNumber,
                      cardOwner,
                      expiryDate,
                      cvc,
                      amount.toString(),
                      duration.toString(),
                      zone,
                      id ?? '',
                    );
                    if (response['success']) {
                      if (!context.mounted) return;
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Payment Successful'),
                          content: Text(
                            'Your ticket has been extended successfully.\nIt will be valid until ${response['end_time']}.\nYou can use the same link for further extensions.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                              GoRouter.of(context).go('/home');
                            },
                              child: Text('Go to Home'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment failed. Please try again.'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error processing payment: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}