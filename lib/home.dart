// import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:eticket_web_app/profile_page.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/ticket_page.dart';
import 'package:eticket_web_app/purchased_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:english_words/english_words.dart';
import 'package:eticket_web_app/ca_page.dart';

class HomeScreen extends StatelessWidget {
  final ApiService apiService;
  final Map<String, dynamic> userData;

  const HomeScreen({super.key, required this.apiService, required this.userData});

  @override
  Widget build(BuildContext context) {
    Widget homePage;

    switch (userData['authority']) {
      case 'ca':
        homePage = CustomerAdminPage(apiService: apiService, userData: userData); // Replace with your CA page widget
        break;
      case 'sa':
        homePage = CustomerAdminPage(apiService: apiService, userData: userData); // Replace with your SA page widget
        break;
      case 'user':
      default:
        homePage = MyHomePage(apiService: apiService);
        // homePage = CustomerAdminPage(apiService: apiService, userData: userData);
        break;
    }

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'eTickets App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: homePage,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext(){
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}


class MyHomePage extends StatefulWidget {
  final ApiService apiService; 

  const MyHomePage({super.key, required this.apiService});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = TicketPage(apiService: widget.apiService,);
        break;
      case 1:
        page = PurchasedPage(apiService:  widget.apiService,);
        break;
      case 2:
        page = ProfilePage(apiService: widget.apiService,);
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
      }
    );
  }
}
