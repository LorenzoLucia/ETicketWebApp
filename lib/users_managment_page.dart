import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';

class UsersManagementPage extends StatefulWidget {
  final ApiService apiService;

  const UsersManagementPage({super.key, required this.apiService});
  @override
  _UsersManagementPageState createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<Map<String, dynamic>> users = [];
  String selectedFilterRole = 'All';

  List<Map<String, dynamic>> get filteredUsers {
    if (selectedFilterRole == 'All') {
      return users;
    }
    return users.where((user) => user['role'] == selectedFilterRole).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final fetchedUsers = await widget.apiService.getUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      // Handle error
      print('Error fetching users: $e');
    }
  }

  void _modifyUser(int index) {
    final user = filteredUsers[index];
    TextEditingController usernameController = TextEditingController(text: user['username']);
    TextEditingController emailController = TextEditingController(text: user['email']);
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['Admin', 'User', 'Moderator', 'CNT', 'CA', 'SA']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
                decoration: InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await widget.apiService.modifyUser(user['id'], 
                    usernameController.text,
                    emailController.text,
                    selectedRole,
                  );
                  setState(() {
                    users[users.indexWhere((u) => u['id'] == user['id'])] = {
                      'id': user['id'],
                      'username': usernameController.text,
                      'email': emailController.text,
                      'role': selectedRole,
                    };
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                  print('Error updating user: $e');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int index) {
    final user = filteredUsers[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete ${user['username']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await widget.apiService.removeUser(user['id']);
                  setState(() {
                    users.removeWhere((u) => u['id'] == user['id']);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                  print('Error deleting user: $e');
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedFilterRole,
              items: ['All', 'Admin', 'User', 'Moderator', 'CNT', 'CA', 'SA']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilterRole = value;
                  });
                }
              },
              decoration: InputDecoration(labelText: 'Filter by Role'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return ListTile(
                  title: Text(user['username']),
                  subtitle: Text('${user['email']} - ${user['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _modifyUser(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteUser(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}