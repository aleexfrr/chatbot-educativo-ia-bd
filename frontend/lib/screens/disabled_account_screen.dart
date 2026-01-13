import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class DisabledAccountScreen extends StatefulWidget {
  const DisabledAccountScreen({super.key});

  @override
  State<DisabledAccountScreen> createState() => _DisabledAccountScreenState();
}

class _DisabledAccountScreenState extends State<DisabledAccountScreen> {
  bool isProcessing = false;

  Future<void> _reactivateAccount() async {
    setState(() => isProcessing = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'disabled': false});
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Future<void> _cancel() async {
    setState(() => isProcessing = true);

    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: isProcessing
              ? const CircularProgressIndicator()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'Tu cuenta está deshabilitada.',
                style:
                TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Puedes reactivarla si crees que ha sido un error, o cancelar para salir.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _reactivateAccount,
                icon: const Icon(Icons.refresh),
                label: const Text('Reactivar cuenta'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _cancel,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}