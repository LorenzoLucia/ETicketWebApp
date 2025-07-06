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
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:web/web.dart';

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
      builder: (context, state){
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.userData == null) {

          appState.setApiService(ApiService(appState.baseUrl));

          // if(appState.userData!['role'] != 'CONTROLLER') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GoRouter.of(context).go('/');
            });
            return const Center(child: CircularProgressIndicator());
        } else if(appState.userData!['role'] != 'CUSTOMER_ADMINISTRATOR' && appState.userData!['role'] != 'SYSTEM_ADMINISTRATOR') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/');
          });
          return const Center(child: CircularProgressIndicator());
        }

        return CustomerAdminPage();
        },
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state){
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.userData == null) {
      // Fetch user data if not already set
          // FirebaseAuth.instance.signOut();
          appState.setApiService(ApiService(appState.baseUrl));
          appState.apiService!.getMe().then((userData) {
            appState.setUserData(userData['user_data']);
          }).catchError((error) {
            print('Error fetching user data: $error');
            // Handle error appropriately, e.g., show a dialog or snackbar
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/home');
          });
           return const Center(child: CircularProgressIndicator());// Wait for user data to be fetched
        }
        try{
          final extra = state.extra! as Map<String, dynamic>;

        return PayScreen(
          amount: extra['amount'],
          duration: extra['duration'],
          plate: extra['plate'] as String,
          id: extra['id'] ?? '',
          zone: extra['zone'],
        );
        } catch (e) {
          print('Error in payment route: $e');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/home');
          });
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.userData == null) {
      // Fetch user data if not already set
          // FirebaseAuth.instance.signOut();
          appState.setApiService(ApiService(appState.baseUrl));
          // appState.apiService!.getMe().then((userData) {
          //   appState.setUserData(userData['user_data']);
          // }).catchError((error) {
          //   print('Error fetching user data: $error');
            // Handle error appropriately, e.g., show a dialog or snackbar
          // });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/');
          });
           return const Center(child: CircularProgressIndicator());// Wait for user data to be fetched
        }

        return HomeScreen();
        },
    ),
    GoRoute(path: '/controller',
      builder: (context, state){
        final appState = Provider.of<AppState>(context, listen: false);
        if (appState.userData == null) {
      // Fetch user data if not already set
          // FirebaseAuth.instance.signOut();
          appState.setApiService(ApiService(appState.baseUrl));
          // appState.setUserData(await appState.apiService!.getMe()['user_data']);
          // .then((userData) {
          //   appState.setUserData(userData['user_data']);
          // }).catchError((error) {
          //   print('Error fetching user data: $error');
          //   // Handle error appropriately, e.g., show a dialog or snackbar
          // });

          // if(appState.userData!['role'] != 'CONTROLLER') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GoRouter.of(context).go('/');
            });
            return const Center(child: CircularProgressIndicator());// Wait for user data to be fetched
          // }
          // return const Center(child: CircularProgressIndicator());// Wait for user data to be fetched
        }else if(appState.userData!['role'] != 'CONTROLLER') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/');
          });
          return const Center(child: CircularProgressIndicator());
        }

        return ParkingControllerPage();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final appState = Provider.of<AppState>(context, listen: false);
        if(appState.userData != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            GoRouter.of(context).go('/');
          });
          return const Center(child: CircularProgressIndicator());
        }

        return RegistrationPage();
        }  ,
    ),
  ],
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final appState = Provider.of<AppState>(context, listen: false);
    // print('Redirecting...');
    if (user == null) { // User is not logged in, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        GoRouter.of(context).go('/');
      });
      return '/';
    } 
    // if (appState.userData == null) {
    //   // Fetch user data if not already set
    //   FirebaseAuth.instance.signOut();
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     GoRouter.of(context).go('/');
    //   });
    //   return '/'; // Wait for user data to be fetched
    // }
    return null;
  },
); // Replace with your actual base URL


class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    // if(appState.userData == null) {
    //   appState.setUserData({});
    // }
    // appState.setApiService(ApiService(baseUrl));
    return MaterialApp.router(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // routerConfig: router,
      routerConfig: router,
      // home: AuthGate(apiService: apiService),
    );
  }
}
