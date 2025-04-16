import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/home.dart';

class RegistrationPage extends StatefulWidget {
  final ApiService apiService;

  const RegistrationPage({Key? key, required this.apiService}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _ssnController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _billingAddressController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'ssn': _ssnController.text,
        'birthdate': _birthdateController.text,
        'billingAddress': _billingAddressController.text,
      };

      try {
        await widget.apiService.sendRegistrationData(data);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(apiService: widget.apiService),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(labelText: 'Surname'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your surname';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ssnController,
                decoration: const InputDecoration(labelText: 'SSN'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your SSN';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9]{16}$').hasMatch(value)) {
                    return 'SSN must be 16 alphanumeric characters';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _birthdateController,
                decoration: const InputDecoration(labelText: 'Birthdate'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your birthdate';
                  }
                  try {
                    DateTime.parse(value);
                  } catch (_) {
                    return 'Please enter a valid date (YYYY-MM-DD)';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'State'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your state';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Province'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your province';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Municipality'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your municipality';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CAP'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your CAP';
                  }
                  if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                    return 'CAP must be 5 numeric digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}