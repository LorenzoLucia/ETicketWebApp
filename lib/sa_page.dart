import 'package:eticket_web_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class SystemAdminPage extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> userData;

  SystemAdminPage({super.key, required this.apiService, required this.userData});
  @override
  _SystemAdminPageState createState() => _SystemAdminPageState();
}

class _SystemAdminPageState extends State<SystemAdminPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  final TextEditingController _zoneIdController = TextEditingController();
  final TextEditingController _zoneNameController = TextEditingController();
  final TextEditingController _zonePriceController = TextEditingController();

  void _addUser() async {
    final id = _idController.text;
    final username = _usernameController.text;
    final email = _emailController.text;
    final role = _roleController.text;

    try {
      final response = await widget.apiService.addUser(username, email, role);
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  void _removeUser() async {
    final id = _idController.text;

    try {
      final response = await widget.apiService.removeUser(id);
    } catch (e) {
      print('Error removing user: $e');
    }
  }

  void _modifyUser() async {
    final id = _idController.text;
    final username = _usernameController.text;
    final email = _emailController.text;
    final role = _roleController.text;

    // final body = jsonEncode({'username': username, 'email': email, 'role': role});

    try {
      final response = await widget.apiService.modifyUser(id, username, email, role);
    } catch (e) {
      print('Error modifying user: $e');
    }
  }

  void _addZone() async {
    final id = _zoneIdController.text;
    final zoneName = _zoneNameController.text;
    final zonePrice = _zonePriceController.text;

    try {
      final response = await widget.apiService.addZone(id, zoneName, double.tryParse(zonePrice));
    } catch (e) {
      print('Error adding zone: $e');
    }
  }

  void _removeZone() async {
    final id = _zoneIdController.text;
    final name = _zoneNameController.text;

    try {
      final response = await widget.apiService.removeZone(id);
    } catch (e) {
      print('Error removing zone: $e');
    }
  }

  void _modifyZone() async {
    final id = _zoneIdController.text;
    final zoneName = _zoneNameController.text;
    final zonePrice = _zonePriceController.text;

    try {
      final response = await widget.apiService.modifyZone(id, zoneName, double.tryParse(zonePrice));
    } catch (e) {
      print('Error modifying zone: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error modifying zone')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Administrator Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Users', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'User ID'),
            ),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Role'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addUser,
                  child: Text('Add User'),
                ),
                ElevatedButton(
                  onPressed: _removeUser,
                  child: Text('Remove User'),
                ),
                ElevatedButton(
                  onPressed: _modifyUser,
                  child: Text('Modify User'),
                ),
              ],
            ),
            Divider(height: 40, thickness: 2),
            Text('Manage Parking Zones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextField(
              controller: _zoneIdController,
              decoration: InputDecoration(labelText: 'Zone ID'),
            ),
            TextField(
              controller: _zoneNameController,
              decoration: InputDecoration(labelText: 'Zone Name'),
            ),
            TextField(
              controller: _zonePriceController,
              decoration: InputDecoration(labelText: 'Zone Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addZone,
                  child: Text('Add Zone'),
                ),
                ElevatedButton(
                  onPressed: _removeZone,
                  child: Text('Remove Zone'),
                ),
                ElevatedButton(
                  onPressed: _modifyZone,
                  child: Text('Modify Zone'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}