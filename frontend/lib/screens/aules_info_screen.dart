import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/aules_service.dart';

class AulesInfoScreen extends StatefulWidget {
  const AulesInfoScreen({super.key});

  @override
  State<AulesInfoScreen> createState() => _AulesInfoScreenState();
}

class _AulesInfoScreenState extends State<AulesInfoScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final aulesService = AulesService();
  late final User _user;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDocFuture;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _userDocFuture = _firestore.collection('users').doc(_user.uid).get();

    aulesService.ensurePdfsAvailable();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuenta Aules'),
        centerTitle: true,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();
          final aules = data?['aules'];

          if (aules == null) {
            return const Center(
              child: Text('No has registrado tu cuenta de Aules aún.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ===== AVATAR =====
                CircleAvatar(
                  radius: 52,
                  backgroundColor: theme.colorScheme.primary.withAlpha(30),
                  child: Icon(
                    Icons.school,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== INFORMACIÓN DE AULES =====
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Usuario Aules'),
                        subtitle: Text(aules['username'] ?? 'No disponible'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_city),
                        title: const Text('Provincia'),
                        subtitle: Text(aules['provincia'] ?? 'No disponible'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('Pueblo'),
                        subtitle: Text(aules['poble'] ?? 'No disponible'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.school),
                        title: const Text('Instituto'),
                        subtitle: Text(aules['institut'] ?? 'No disponible'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: const Text('Tipo de Aules'),
                        subtitle: Text(aules['tipo'] ?? 'No disponible'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}