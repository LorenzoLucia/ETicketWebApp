import 'package:eticket_web_app/services/api_service.dart';
import 'package:eticket_web_app/services/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// import 'registration_page.dart';
// import 'home.dart';

class AuthGate extends StatelessWidget {
  // final ApiService apiService;

  const AuthGate({super.key});

  Future<Map<String, dynamic>> getUserData(ApiService? apiService) async {
    try {
      return await apiService!.getMe().timeout(
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
    final appState = Provider.of<AppState>(context, listen: false);
    final apiService = appState.apiService;

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
          future: getUserData(apiService),
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

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/register');
                }
              });
            } else {
              // User registered but no payment methods
              print('User registered');
              appState.setUserData(data["user_data"]);
              apiService?.setUserId(data["user_id"]);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go('/home');
                }
              });
            }
            return Center(
              child: CircularProgressIndicator(),
            );

            // if (user.metadata.creationTime == user.metadata.lastSignInTime) {
            //   // User just registered
            //   return RegistrationPage(
            //     apiService: apiService,
            //     userData: data["user_data"],
            //   );
            // } else {r
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
