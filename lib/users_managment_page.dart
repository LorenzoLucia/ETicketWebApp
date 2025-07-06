import 'package:eticket_web_app/services/app_state.dart';
import 'package:flutter/material.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:provider/provider.dart';

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
    return users.where((user) => _getRoleLabel(user['role']) == selectedFilterRole).toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final fetchedUsers = await widget.apiService.getUsers();
      print('Fetched users: $fetchedUsers');
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      // Handle error
      print('Error fetching users: $e');
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'CUSTOMER':
        return 'User';
      case 'CONTROLLER':
        return 'Controller';
      case 'CUSTOMER_ADMINISTRATOR':
        return 'Customer Administrator';
      case 'SYSTEM_ADMINISTRATOR':
        return 'System Administrator';
      
      default:
        return 'Unknown Role';
    }
  }

  String _getRoleValue(String role) {
    switch (role) {
      case 'User':
        return 'CUSTOMER';
      case 'Controller':
        return 'CONTROLLER';
      case 'Customer Administrator':
        return 'CUSTOMER_ADMINISTRATOR';
      case 'System Administrator':
        return 'SYSTEM_ADMINISTRATOR';
      default:
        return 'Unknown Role';
    }
  }

  void _modifyUser(int index) {
    final user = filteredUsers[index];
    // TextEditingController usernameController = TextEditingController(text: user['name'] + ' ' + user['surname']);
    TextEditingController emailController = TextEditingController(text: user['email']);
    String selectedRole = _getRoleLabel(user['role']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TextField(
              //   controller: usernameController,
              //   decoration: InputDecoration(labelText: 'Username'),
              // ),
                Text(
                'Email: ${emailController.text}',
                style: TextStyle(fontSize: 16),
                ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: ['User', 'Controller', 'Customer Administrator', 'System Administrator']
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
                  await widget.apiService.modifyUser(
                    user['id'], 
                    emailController.text,
                    _getRoleValue(selectedRole),
                  );
                  _fetchUsers();
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
          content: Text('Are you sure you want to delete ${user['email']}?'),
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
                  _fetchUsers();
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

  void _addUser(sa_flag) {
    TextEditingController emailController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController surnameController = TextEditingController();
    String selectedRole = 'User';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
              controller: surnameController,
              decoration: InputDecoration(labelText: 'Surname'),
              ),
              DropdownButtonFormField<String>(
              value: selectedRole,
              items: (sa_flag
                  ? ['User', 'Controller', 'Customer Administrator', 'System Administrator']
                  : ['User', 'Controller'])
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
                  await widget.apiService.addUser(
                    emailController.text,
                    nameController.text,
                    surnameController.text,
                    _getRoleValue(selectedRole),
                  );
                  _fetchUsers();
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle error
                  print('Error adding user: $e');
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    // final apiService = appState.apiService;
    final sa_flag = appState.userData!['role'] == 'SYSTEM_ADMINISTRATOR';

    return Scaffold(
      appBar: AppBar(
        title: Text('Users Management'),
        actions: [
          ElevatedButton.icon(
            icon: Icon(Icons.add, size: 24),
            label: Text(
              'Add User',
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () => _addUser(sa_flag),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              value: selectedFilterRole,
              items: ['All', 'User', 'Controller', 'Customer Administrator', 'System Administrator']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilterRole = value;
                    filteredUsers; // Trigger rebuild with new filter
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
                  title: Text(user['name'] + ' ' + user['surname']),
                  subtitle: Text('${user['email']} - ${_getRoleLabel(user['role'])}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: sa_flag || user['role'] != 'SYSTEM_ADMINISTRATOR'? () => _modifyUser(index) : null,
                      ),
                      IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: sa_flag || user['role'] != 'SYSTEM_ADMINISTRATOR'? () => _deleteUser(index) : null,
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