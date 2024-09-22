import 'package:flutter/material.dart';
import 'package:flutterproject/analytics.dart';
import 'package:flutterproject/app_state.dart';
import 'package:flutterproject/categories.dart';
import 'package:flutterproject/profile.dart';
import 'package:flutterproject/profileimage.dart';
import 'package:provider/provider.dart';
import 'signup.dart';
import 'login.dart';
import 'home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "MoneyTracker",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) =>
            Consumer<AppState>(builder: (context, appState, child) {
              return appState.isLoggedIn ? const HomePage() : const LoginPage();
            }),
        '/profile': (context) =>
            Consumer<AppState>(builder: (context, appState, child) {
              return appState.isLoggedIn
                  ? const ProfilePage()
                  : const LoginPage();
            }),
        '/categories': (context) =>
            Consumer<AppState>(builder: (context, appState, child) {
              return appState.isLoggedIn
                  ? const CategoriesPage()
                  : const LoginPage();
            }),
        '/analytics': (context) =>
            Consumer<AppState>(builder: (context, appState, child) {
              return appState.isLoggedIn
                  ? const AnalyticsPage()
                  : const LoginPage();
            }),
        '/profileimage': (context) =>
            Consumer<AppState>(builder: (context, appState, child) {
              return appState.isLoggedIn
                  ? const ProfileImagePage()
                  : const LoginPage();
            })
      },
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // login.dart after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, '/login');
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 300,
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to MoneyTracker',
              style: TextStyle(
                fontSize: 24, // Font size 24px
                fontWeight: FontWeight.bold, // Bold text
                color: Colors.black, // Black font color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
