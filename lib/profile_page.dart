import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eticket_web_app/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final ApiService apiService;
  const ProfilePage({super.key, required this.apiService});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> paymentMethods = [];
  List<String> plates = [];
  String name = '';
  String surname = '';
  String dateOfBirth = '';
  String email = '';
  String username = '';

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _fetchPaymentMethods();
    _fetchPlates();
  }

  Future<void> _fetchProfileData() async {
    try {
      // final response = await widget.apiService.fetchProfileData();
      // setState(() {
      //   name = response['name'] as String;
      //   surname = response['surname'] ?? '';
      //   dateOfBirth = response['dateOfBirth'] ?? '';
      //   email = response['email'] ?? '';
      //   username = response['username'] ?? '';
      // });
      setState(() {
        name = 'John';
        surname = 'Doe';
        dateOfBirth = '01/01/1990';
        email = 'john.doe@example.com';
        username = 'johndoe';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch profile data')),
      );
    }
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      // final response = await widget.apiService.fetchPaymentMethods();
      // setState(() {
      //   paymentMethods = List<String>.from(response);
      // });
      setState(() {
        paymentMethods = ['Visa **** 1234', 'MasterCard **** 5678'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch payment methods')),
      );
    }
  }

  Future<void> _fetchPlates() async {
    try {
      // final response = await widget.apiService.fetchPlates(); 
      // setState(() {
      //   plates = List<String>.from(response);
      // });
      // Simulated data for demonstration
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        plates = ['AB123CD', 'EF456GH'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch plates')),
      );
    }
  }

  void _removePaymentMethod(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Removal'),
        content: Text('Are you sure you want to remove this payment method?'),
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
        await Future.delayed(Duration(seconds: 1)); // Simulate network delay
        setState(() {
          paymentMethods.removeAt(index);
        });
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
      builder: (context) => AlertDialog(
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
        await Future.delayed(Duration(seconds: 1)); // Simulate network delay
        setState(() {
          plates.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plate removed successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove plate')),
        );
      }
    }
  }

  void _addPlate(String plate) async {
    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plate cannot be empty')),
      );
      return;
    }

    // Simulate sending an HTTP request to add the plate
    try {
      // Example: await http.post(Uri.parse('https://api.example.com/plates'), body: {'plate': plate});
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      setState(() {
        plates.add(plate);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plate added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add plate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: Text('Profile Page'),
      ),
      body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
        Text(
          'Personal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ListTile(
          title: Text('Name'),
          subtitle: Text(name),
        ),
        ListTile(
          title: Text('Surname'),
          subtitle: Text(surname),
        ),
        ListTile(
          title: Text('Date of Birth'),
          subtitle: Text(dateOfBirth),
        ),
        ListTile(
          title: Text('Email'),
          subtitle: Text(email),
        ),
        ListTile(
          title: Text('Username'),
          subtitle: Text(username),
        ),
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
        ...paymentMethods.asMap().entries.map((entry) {
          int index = entry.key;
          String method = entry.value;
          return ListTile(
          title: Text(method),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _removePaymentMethod(index),
          ),
          );
        }),
        SizedBox(height: 20),
        Text(
          'Registered Plates',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
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
          Navigator.of(context).pushReplacementNamed('/login');
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
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Old Password',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
              ),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
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

class AddPlatePage extends StatelessWidget {
  final Function(String) onAddPlate;

  const AddPlatePage({super.key, required this.onAddPlate});

  @override
  Widget build(BuildContext context) {
    TextEditingController plateController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Plate'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: plateController,
              decoration: InputDecoration(
                labelText: 'Enter Plate',
              ),
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