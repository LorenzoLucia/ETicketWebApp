import 'package:eticket_web_app/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'registration_page.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  final ApiService apiService;

  const AuthGate({super.key, required this.apiService});

  Future<Map<String, dynamic>> getUserData() async {
    try {
      return await apiService.getMe().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Handle timeout appropriately
          throw Exception('Request timed out');
        },
      );
    } catch (e) {
      // Handle other errors appropriately
      return Map<String, dynamic>.from({
        'error': 'Error fetching user data: $e',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              // GoogleProvider(clientId: clientId),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/flutterfire_300x.png'),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child:
                    action == AuthAction.signIn
                        ? const Text('Welcome to FlutterFire, please sign in!')
                        : const Text('Welcome to Flutterfire, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        }

        final user = snapshot.data!;
        return FutureBuilder<Map<String, dynamic>>(
          future: getUserData(),
          builder: (context, userDataSnapshot) {
            if (userDataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userDataSnapshot.hasError) {
              return SignInScreen(
                providers: [
                  EmailAuthProvider(),
                  // GoogleProvider(clientId: clientId),
                ],
                headerBuilder: (context, constraints, shrinkOffset) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Image.asset('assets/flutterfire_300x.png'),
                    ),
                  );
                },
                subtitleBuilder: (context, action) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: const Text(
                      'An error occurred. Please try signing in again.',
                    ),
                  );
                },
                footerBuilder: (context, action) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'By signing in, you agree to our terms and conditions.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              );
            }

            final data = userDataSnapshot.data!;
            print(data);
            if (data['is_registered'] == false) {
              // User not registered
              print('User not registered');
              return RegistrationPage(
                apiService: apiService,
                userData: data["user_data"],
              );
            } else {
              // User registered but no payment methods
              print('User registered');
              return HomeScreen(
                apiService: apiService,
                userData: data["user_data"],
                uid: data["user_id"],
              );
            }

            // if (user.metadata.creationTime == user.metadata.lastSignInTime) {
            //   // User just registered
            //   return RegistrationPage(
            //     apiService: apiService,
            //     userData: data["user_data"],
            //   );
            // } else {
            //   // User logged in
            //   return HomeScreen(
            //     apiService: apiService,
            //     userData: data["user_data"],
            //   );
            // }
          },
        );
      },
    );
  }
}
