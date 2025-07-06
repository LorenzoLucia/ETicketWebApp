// import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/services/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eticket_web_app/users_managment_page.dart';
import 'package:eticket_web_app/zones_management_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CustomerAdminPage extends StatefulWidget {


  const CustomerAdminPage({super.key,});
  @override
  _CustomerAdminPageState createState() => _CustomerAdminPageState();
}

class _CustomerAdminPageState extends State<CustomerAdminPage> {
  var selectedIndex = 0;

  // final TextEditingController _usernameController = TextEditingController();
  // final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _passwordController = TextEditingController();
  // String _selectedRole = 'User';
  // final List<String> _roles = ['User', 'Controller', 'Customer Administrator', 'System Administrator'];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final apiService = appState.apiService;
    final sa_flag = appState.userData!['role'] == 'SYSTEM_ADMINISTRATOR';
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = UsersManagementPage(apiService: apiService!,);
        break;
      case 1:
        page = ZonesManagementPage(apiService: apiService!,);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Administrator'),
            actions: [
                  IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      appState.clear();
                      context.go('/');
                    },
                  ),
                ],
          ),
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Users'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.map),
                      label: Text('Zones'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Column(
                    children: [
                      Expanded(child: page),
                      // Divider(),
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         'Add New User',
                      //         style: Theme.of(context).textTheme.headlineMedium,
                      //       ),
                      //       SizedBox(height: 16),
                      //       TextField(
                      //         controller: _usernameController,
                      //         decoration: InputDecoration(
                      //           labelText: 'Username',
                      //           border: OutlineInputBorder(),
                      //         ),
                      //       ),
                      //       SizedBox(height: 16),
                      //       TextField(
                      //         controller: _emailController,
                      //         decoration: InputDecoration(
                      //           labelText: 'Email',
                      //           border: OutlineInputBorder(),
                      //         ),
                      //       ),
                      //       SizedBox(height: 16),
                      //       TextField(
                      //         controller: _passwordController,
                      //         obscureText: true,
                      //         decoration: InputDecoration(
                      //           labelText: 'Password',
                      //           border: OutlineInputBorder(),
                      //         ),
                      //       ),
                      //       SizedBox(height: 16),
                      //       DropdownButtonFormField<String>(
                      //         value: _selectedRole,
                      //         items: _roles.map((role) {
                      //           return DropdownMenuItem(
                      //             value: role,
                      //             child: Text(role),
                      //           );
                      //         }).toList(),
                      //         onChanged: (value) {
                      //           setState(() {
                      //             _selectedRole = value!;
                      //           });
                      //         },
                      //         decoration: InputDecoration(
                      //           labelText: 'Role',
                      //           border: OutlineInputBorder(),
                      //         ),
                      //       ),
                      //       SizedBox(height: 16),
                      //       ElevatedButton(
                      //         onPressed: () {
                      //           // Handle user addition logic here
                      //           print('Username: ${_usernameController.text}');
                      //           print('Email: ${_emailController.text}');
                      //           print('Password: ${_passwordController.text}');
                      //           print('Role: $_selectedRole');
                      //         },
                      //         child: Text('Add User'),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}