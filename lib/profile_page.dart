import 'package:eticket_web_app/services/app_state.dart';
import 'package:eticket_web_app/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> userData;
  const ProfilePage({
    super.key,
    required this.apiService,
    required this.userData,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, String>> paymentMethods = [];
  List<String> plates = [];
  String name = '';
  String surname = '';
  String dateOfBirth = '';
  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    name = widget.userData['name'];
    surname = widget.userData['surname'];
    dateOfBirth = widget.userData['birth_date'].toString();
    email = widget.userData['email'];
    _fetchPaymentMethods();
    _fetchPlates();
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final response = await widget.apiService.fetchPaymentMethods();
      print('Payment Methods: $response');
      setState(() {
        paymentMethods = response;
      });
      // setState(() {
      //   paymentMethods = ['Visa **** 1234', 'MasterCard **** 5678'];
      // });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch payment methods')),
      );
    }
  }

  Future<void> _fetchPlates() async {
    try {
      final response = await widget.apiService.fetchPlates();
      setState(() {
        plates = List<String>.from(response);
      });
      // Simulated data for demonstration
      // await Future.delayed(Duration(seconds: 1));
      // setState(() {
      //   plates = ['AB123CD', 'EF456GH'];
      // });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch plates')));
    }
  }

  void _removePaymentMethod(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Removal'),
            content: Text(
              'Are you sure you want to remove this payment method?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Remove'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      // Simulate sending an HTTP request to remove the payment method
      try {
        // Example: await http.delete(Uri.parse('https://api.example.com/payment-methods/$index'));
        await widget.apiService.removePaymentMethod(
          paymentMethods[index]['id'] ?? '',
        ); // Simulate network delay
        _fetchPaymentMethods();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment method removed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove payment method')),
        );
      }
    }
  }

  void _removePlate(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Removal'),
            content: Text('Are you sure you want to remove this plate?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Remove'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      // Simulate sending an HTTP request to remove the plate
      try {
        // Example: await http.delete(Uri.parse('https://api.example.com/plates/$index'));
        await widget.apiService.removePlate(
          plates[index],
        ); // Simulate network delay
        _fetchPlates();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Plate removed successfully')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to remove plate')));
      }
    }
  }

  void _addPlate(String plate) async {
    if (plate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Plate cannot be empty')));
      return;
    }

    // Simulate sending an HTTP request to add the plate
    try {
      // Example: await http.post(Uri.parse('https://api.example.com/plates'), body: {'plate': plate});
      await widget.apiService.addPlate(plate); // Simulate network delay
      _fetchPlates();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Plate added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add plate')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text('Profile Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListTile(title: Text('Name'), subtitle: Text(name)),
            ListTile(title: Text('Surname'), subtitle: Text(surname)),
            ListTile(title: Text('Date of Birth'), subtitle: Text(dateOfBirth)),
            ListTile(title: Text('Email'), subtitle: Text(email)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              },
              child: Text('Change Password'),
            ),
            SizedBox(height: 20),
            Text(
              'Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (paymentMethods.isEmpty) Text('No payment methods available'),
            ...paymentMethods.asMap().entries.map((entry) {
              int index = entry.key;
              String methodOwner = entry.value["owner_name"] ?? "Unknown Owner";
              String method = entry.value['name'] ?? 'Unknown Method';
              return ListTile(
                title: Text('$methodOwner - $method'),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removePaymentMethod(index),
                ),
              );
            }),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => RegisterPaymentMethodPage(
                          apiService: widget.apiService,
                        ),
                  ),
                );
                _fetchPaymentMethods(); // Refetch payment methods after returning from the page
              },
              child: Text('Register Payment Method'),
            ),
            SizedBox(height: 20),
            Text(
              'Registered Plates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            if (plates.isEmpty) Text('No registered plates available'),
            ...plates.asMap().entries.map((entry) {
              int index = entry.key;
              String plate = entry.value;
              return ListTile(
                title: Text(plate),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _removePlate(index),
                ),
              );
            }),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    TextEditingController plateController =
                        TextEditingController();
                    return AlertDialog(
                      title: Text('Add Plate'),
                      content: TextField(
                        controller: plateController,
                        decoration: InputDecoration(hintText: 'Enter plate'),
                        inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]'),
                            ),
                            UpperCaseTextFormatter(),
                          ],
                        textCapitalization: TextCapitalization.characters,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            _addPlate(plateController.text);
                            Navigator.of(context).pop();
                          },
                          child: Text('Add'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Add Plate'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    appState.clear();
                    context.go('/');
                  }
                });
                // Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Old Password'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'New Password'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String oldPassword = oldPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                try {
                  User? user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    // Reauthenticate the user
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: oldPassword,
                    );

                    await user.reauthenticateWithCredential(credential);

                    // Update the password
                    await user.updatePassword(newPassword);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Password changed successfully')),
                    );
                    Navigator.of(context).pop();
                  }
                } on FirebaseAuthException catch (e) {
                  String errorMessage = 'An error occurred';
                  if (e.code == 'wrong-password') {
                    errorMessage = 'The old password is incorrect';
                  } else if (e.code == 'weak-password') {
                    errorMessage = 'The new password is too weak';
                  }
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(errorMessage)));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('An unexpected error occurred')),
                  );
                }
              },
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPaymentMethodPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvcController = TextEditingController();
  final TextEditingController cardOwnerController = TextEditingController();
  final ApiService apiService;

  RegisterPaymentMethodPage({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Payment Method')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              TextFormField(
                controller: cardOwnerController,
                decoration: InputDecoration(
                  labelText: 'Card owner',
                  border: OutlineInputBorder(),
                ),
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
                  child: Text('Add Payment Method'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final methodId = await apiService.addPaymentMethod(
                          cardNumberController.text,
                          expiryDateController.text,
                          cvcController.text,
                          cardOwnerController.text,
                        );
                        if (methodId != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Payment method added successfully',
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to add payment method. Please try again.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error adding payment method: $e'),
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

class AddPlatePage extends StatelessWidget {
  final Function(String) onAddPlate;

  const AddPlatePage({super.key, required this.onAddPlate});

  @override
  Widget build(BuildContext context) {
    TextEditingController plateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Add Plate')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: plateController,
              decoration: InputDecoration(labelText: 'Enter Plate'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String plate = plateController.text;
                if (plate.isNotEmpty) {
                  onAddPlate(plate);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Plate cannot be empty')),
                  );
                }
              },
              child: Text('Add Plate'),
            ),
          ],
        ),
      ),
    );
  }
}
