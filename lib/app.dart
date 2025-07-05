import 'package:eticket_web_app/ca_page.dart';
import 'package:eticket_web_app/controller_page.dart';
import 'package:eticket_web_app/home.dart';
import 'package:eticket_web_app/pay_screen.dart';
import 'package:eticket_web_app/registration_page.dart';
import 'package:eticket_web_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eticket_web_app/services/app_state.dart';
import 'package:provider/provider.dart';

import 'auth_gate.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => AuthGate(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => CustomerAdminPage(
      ),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state){
        final extra = state.extra! as Map<String, dynamic>;

        return PayScreen(
        amount: extra['amount'],
        duration: extra['duration'],
        plate: extra['plate'] as String,
        id: extra['id'] ?? '',
        zone: extra['zone'],
      );
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(path: '/controller',
      builder: (context, state) => ParkingControllerPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => RegistrationPage(),
    ),
  ],
); // Replace with your actual base URL

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    // final appState = Provider.of<AppState>(context, listen: false);
    // appState.setApiService(ApiService(baseUrl));
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: router,
      // home: AuthGate(apiService: apiService),
    );
  }
}
