import 'package:eticket_web_app/services/api_service.dart';
import 'package:flutter/material.dart';

import 'auth_gate.dart';

final baseUrl = 'https://example.com/api'; // Replace with your actual base URL

class MyApp extends StatelessWidget {
  final ApiService apiService = ApiService(baseUrl);

  MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(apiService: apiService,),
    );
  }
}
