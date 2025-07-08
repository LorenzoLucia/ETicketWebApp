// import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/services/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eticket_web_app/users_managment_page.dart';
import 'package:eticket_web_app/zones_management_page.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:eticket_web_app/fines_page.dart';

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
      case 2:
        if (!sa_flag) {
          page = FinesPage(apiService: apiService!,);
        } else {
          page = Center(child: Text('You do not have permission to access this page. Here Customer Administrator can see emitted fines.'));
        }
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    if (!sa_flag)
    {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Customer Administrator Page'),
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
                      NavigationRailDestination(
                        icon: Icon(Icons.money),
                        label: Text('Fines'),
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            appBar: AppBar(
              title: Text('System Administrator Page'),
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
}