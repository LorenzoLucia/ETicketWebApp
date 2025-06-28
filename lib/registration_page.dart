import 'package:eticket_web_app/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/home.dart';
import 'package:intl/intl.dart';

class RegistrationPage extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> userData;

  const RegistrationPage({Key? key, required this.apiService, required this.userData}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  DateTime? _selectedBirthdate;
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() async {
      if (_focusNode.hasFocus) {
        await _pickDate(context);
        // _focusNode.unfocus();
        _focusNode.nextFocus();
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'birthdate': _selectedBirthdate?.toIso8601String(),
      };

      try {
        await widget.apiService.sendRegistrationData(data);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            // builder: (context) => HomeScreen(apiService: widget.apiService, userData: widget.userData),
            builder: (context) => AuthGate(
              apiService: widget.apiService,
            ),
          )
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthdate) {
      setState(() {
        _selectedBirthdate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      print('Selected birthdate: ${_selectedBirthdate!.toIso8601String()}');
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
                  controller: _dateController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Birthdate',
                  ),
                  readOnly: true,
                  validator: (value) {
                    if (_selectedBirthdate == null) {
                      return 'Please select your birthdate';
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
