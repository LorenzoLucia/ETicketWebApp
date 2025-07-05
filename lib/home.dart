// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:eticket_web_app/controller_page.dart';
import 'package:eticket_web_app/profile_page.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/services/app_state.dart';
import 'package:eticket_web_app/ticket_page.dart';
import 'package:eticket_web_app/purchased_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:eticket_web_app/ca_page.dart';

class HomeScreen extends StatelessWidget {
  // final ApiService apiService;
  // final Map<String, dynamic> userData;
  // final String uid;

  const HomeScreen({
    super.key,
    // required this.apiService,
    // required this.userData,
    // required this.uid,
  });


  @override
  Widget build(BuildContext context) {
    Widget homePage;

    final appState = Provider.of<AppState>(context, listen: false);
    // final apiService = appState.apiService!;
    final userData = appState.userData!;
    print('User data: $userData');

    switch (userData['role']) {
      case 'CUSTOMER_ADMINISTRATOR':
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/admin');
          }
        });
         // Replace with your CA page widget
        break;
      case 'SYSTEM_ADMINISTRATOR':
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/admin');
          }
        });
        // Replace with your SA page widget
        break;
      case 'CONTROLLER':
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/controller');
          }
        });
         // Replace with your controller page widget
        break;
      case 'CUSTOMER':
      default:
        homePage = MyHomePage();
        return Scaffold(
          appBar: AppBar(
            title: Text('eTicket Web App'),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () {
                  // Handle logout logic here
                  appState.clear();
                  context.go('/');
                },
              ),
            ],
          ),
          body: homePage,
        ); // Show the homepage using MaterialPage builder
    }

    return Center(
              child: CircularProgressIndicator(),
            );
    
  }
}

// class MyAppState extends ChangeNotifier {
//   // var current = WordPair.random();

//   // void getNext() {
//   //   current = WordPair.random();
//   //   notifyListeners();
//   // }

//   // var favorites = <WordPair>[];
//   // void toggleFavorite() {
//   //   if (favorites.contains(current)) {
//   //     favorites.remove(current);
//   //   } else {
//   //     favorites.add(current);
//   //   }
//   //   notifyListeners();
//   // }
// }

class MyHomePage extends StatefulWidget {

  const MyHomePage({super.key, });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final apiService = appState.apiService!;
    final userData = appState.userData!;
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = TicketPage(apiService: apiService);
        break;
      case 1:
        page = PurchasedPage(apiService: apiService);
        break;
      case 2:
        page = ProfilePage(apiService: apiService, userData: userData);
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.euro),
                      label: Text('Buy eTickets'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.document_scanner),
                      label: Text('My eTickets'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Profile'),
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
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
