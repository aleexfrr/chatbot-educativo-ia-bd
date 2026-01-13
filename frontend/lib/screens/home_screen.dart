import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mientras se comprueba el login
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          // No está logueado
          return const LoginScreen();
        }

        // Usuario logueado
        return Scaffold(
          appBar: AppBar(title: const Text('Home (pruebas)')),
          body: const Center(
            child: Text('Pantalla de pruebas'),
          ),
        );
      },
    );
  }

  Future<User?> _checkLoginStatus() async {
    return FirebaseAuth.instance.currentUser;
  }
}