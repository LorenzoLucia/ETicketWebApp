import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<bool> hasRegisteredPaymentMethods() async {
  final url = Uri.parse('https://your-server.com/api/payment-methods');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hasPaymentMethods'] ?? false;
    } else {
      throw Exception('Failed to load payment methods');
    }
  } catch (e) {
    print('Error: $e');
    // return false;
    return true; // For debug purposes, always return true
  }
}

class PayScreen extends StatelessWidget {
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;

  // final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();

  // Fake registered payment methods for debug purposes
  final List<Map<String, String>> fakePaymentMethods = [
    {'name': 'Visa **** 1234', 'id': '1'},
    {'name': 'MasterCard **** 5678', 'id': '2'},
    {'name': 'Amex **** 9012', 'id': '3'},
  ];

  PayScreen({super.key, required this.amount, required this.duration, required this.zone, this.id, this.plate});

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
        } else if (snapshot.hasData && snapshot.data == true) {
          // If payment methods are available, let the user select one
            return PaymentMethodsPage(
            paymentMethods: fakePaymentMethods,
            onPaymentMethodSelected: (selectedMethod) {
              // Handle the selected payment method
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected ${selectedMethod['name']}')),
              );
            },
            amount: amount,
            duration: duration,
            zone: zone,
            id: id,
            plate: plate,
            );
        } else {
          // If no payment methods are available, show the normal pay screen
            return NewPaymentMethodPage(
            amount: amount,
            duration: duration,
            zone: zone,
            id: id,
            plate: plate,
            );
        }
      },
    );
  }
}

class NewPaymentMethodPage extends StatelessWidget{
  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  
  NewPaymentMethodPage({super.key, required this.amount, required this.duration, required this.zone, this.id, this.plate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text('Payment'),
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
                            final url = Uri.parse('https://your-server.com/api/register-payment-method');
                            try {
                              final response = await http.post(
                                url,
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'cardNumber': cardNumberController.text,
                                  'expiryDate': expiryDateController.text,
                                  'cvc': cvcController.text,
                                  'amount': amount,
                                  'duration': duration,
                                  'zone': zone,
                                  'ticket_id': id!,
                                  'plate': plate,
                                }),
                              );

                              if (response.statusCode == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Payment method registered successfully. Processing payment...')),
                                );
                                // Proceed with payment logic here
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to register payment method. Please try again.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: impossible connection to the server')),
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

class PaymentMethodsPage extends StatelessWidget {
  final List<Map<String, String>> paymentMethods;
  final Function(Map<String, String>) onPaymentMethodSelected;

  final double amount;
  final int duration;
  final String zone;
  final String? id;
  final String? plate;

  const PaymentMethodsPage({super.key, 
    required this.paymentMethods,
    required this.onPaymentMethodSelected,
    required this.amount,
    required this.duration,
    required this.zone,
    this.id,
    this.plate,
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
              onPressed: () async {
                Navigator.of(context).pop();
                final url = Uri.parse('https://your-server.com/api/process-payment');
                try {
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                  'paymentMethodId': method['id'],
                  'amount': (context.findAncestorWidgetOfExactType<PayScreen>() as PayScreen).amount,
                  'duration': (context.findAncestorWidgetOfExactType<PayScreen>() as PayScreen).duration,
                  'zone': (context.findAncestorWidgetOfExactType<PayScreen>() as PayScreen).zone,
                  'ticket_id': (context.findAncestorWidgetOfExactType<PayScreen>() as PayScreen).id,
                  'plate': (context.findAncestorWidgetOfExactType<PayScreen>() as PayScreen).plate,
                  }),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment processed successfully.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to process payment. Please try again.')),
                  );
                }
                } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
                }
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
