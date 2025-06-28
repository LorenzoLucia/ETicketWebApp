import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eticket_web_app/services/api_service.dart';

// Future<bool> hasRegisteredPaymentMethods() async {
//   final url = Uri.parse('https://your-server.com/api/payment-methods');
//   try {
//     final response = await http.get(url);
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['hasPaymentMethods'] ?? false;
//     } else {
//       throw Exception('Failed to load payment methods');
//     }
//   } catch (e) {
//     print('Error: $e');
//     // return false;
//     return true; // For debug purposes, always return true
//   }
// }

class PayScreen extends StatefulWidget{
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  PayScreen({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService
  });

  @override
  _PayScreenState createState() => _PayScreenState();

}



class _PayScreenState extends State<PayScreen> {

  // final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  List<Map<String, String>> paymentMethods = [];

  // Fake registered payment methods for debug purposes
  // List<Map<String, String>> paymentMethods = [
  //   {'name': 'Visa **** 1234', 'id': '1'},
  //   {'name': 'MasterCard **** 5678', 'id': '2'},
  //   {'name': 'Amex **** 9012', 'id': '3'},
  // ];


  Future<bool> hasRegisteredPaymentMethods() async {
    // return true; // For debug purposes, always return true
    try {
      final methods = await widget.apiService.fetchPaymentMethods();
      if (methods.isNotEmpty) {
        // Fetch the registered payment methods from the server
        setState(() {
          paymentMethods = List<Map<String, String>>.from(methods);
        });
        return true;
      }
      return false;
    } catch (e) {
      // Handle error
      print('Error loading plates: $e');
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasRegisteredPaymentMethods(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Payment'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Payment'),
            ),
            body: Center(
              child: Text('Error loading payment methods'),
            ),
          );
        } else {
          // Always show the payment methods page, allowing the user to add a new method if needed
          return PaymentMethodsPage(
            paymentMethods: paymentMethods,
            onPaymentMethodSelected: (selectedMethod) {
              // Handle the selected payment method
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected ${selectedMethod['name']}')),
              );
            },
            amount: widget.amount,
            duration: widget.duration,
            zone: widget.zone,
            id: widget.id,
            plate: widget.plate,
            apiService: widget.apiService,
          );
        }
      },
    );
  }
}

class NewPaymentMethodPage extends StatelessWidget {
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final ApiService apiService;

  NewPaymentMethodPage({
    super.key,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to Pay: \$${amount.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your card number';
                  }
                  if (value.length != 16) {
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
                        final methodId = await apiService.addPaymentMethod(
                          cardNumberController.text,
                          expiryDateController.text,
                          cvcController.text,
                        );
                        if (methodId != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PayNowPage(
                                methodId: methodId,
                                amount: amount,
                                duration: duration,
                                zone: zone,
                                id: id,
                                plate: plate,
                                apiService: apiService,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to register payment method. Please try again.')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error registering payment method: $e')),
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

class PayNowPage extends StatelessWidget {
  final String methodId;
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  PayNowPage({
    super.key,
    required this.methodId,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount to Pay: \$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                child: Text('Confirm Payment'),
                onPressed: () async {
                  try {
                    final success = await apiService.payTicket(
                      plate ?? '',
                      methodId,
                      amount.toString(),
                      duration.toString(),
                      zone,
                      id,
                    );
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment successful!')),
                      );
                      Navigator.of(context).popUntil((route) => route.isFirst); // Navigate back to the home page
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment failed. Please try again.')),
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

class PaymentMethodsPage extends StatelessWidget {
  final List<Map<String, String>> paymentMethods;
  final Function(Map<String, String>) onPaymentMethodSelected;

  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final ApiService apiService;

  const PaymentMethodsPage({super.key, 
    required this.paymentMethods,
    required this.onPaymentMethodSelected,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
    required this.apiService
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Select Payment Method'),
      ),
      body: ListView.builder(
      itemCount: paymentMethods.length + 1, // Add one for the "Add New Payment Method" option
      itemBuilder: (context, index) {
        if (index == paymentMethods.length) {
        // Add New Payment Method option
        return ListTile(
          title: Text('Add New Payment Method'),
          leading: Icon(Icons.add),
          onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
            builder: (context) => NewPaymentMethodPage(
              amount: amount,
              duration: duration,
              zone: zone,
              id: id,
              plate: plate,
              apiService: apiService,
            ),
            ),
          );
          },
        );
        } else {
        final method = paymentMethods[index];
        return ListTile(
          title: Text(method['name']!),
          onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
            title: Text('Confirm Payment Method'),
            content: Text('Are you sure you want to use ${method['name']}?'),
            actions: [
              TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
              ),
              TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PayNowPage(
                  methodId: method['id']!,
                  amount: amount,
                  duration: duration,
                  zone: zone,
                  id: id,
                  plate: plate,
                  apiService: apiService,
                  ),
                ),
                );
              },
              child: Text('Yes'),
              ),
            ],
            
            ),
          );
          },
        );
        }
      },
      ),
    );
  }
}
