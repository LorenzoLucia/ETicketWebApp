import 'package:eticket_web_app/services/app_state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';

final baseUrl = 'http://172.20.10.6:5001';
// 'http://192.168.1.28:5001'; // Replace with your actual base URL
// 'http://10.17.188.119:5001';
// 'http://localhost:5001';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: "assets/.env"); // Debug print statement
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(baseUrl),
        child: MyApp(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Initialization failed: $e'))),
      ),
    );
  }
}
