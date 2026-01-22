import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  late final User _user;
  late final bool _isGuest;
  late Future<DocumentSnapshot<Map<String, dynamic>>> _userDocFuture;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser!;
    _isGuest = _user.isAnonymous;

    _userDocFuture =
        _firestore.collection('users').doc(_user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        actions: !_isGuest
            ? [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          )
        ]
            : null,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userDocFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ===== AVATAR =====
                CircleAvatar(
                  radius: 52,
                  backgroundColor: theme.colorScheme.primary.withAlpha(30),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== NOMBRE =====
                Text(
                  _user.displayName ??
                      data?['name'] ??
                      (_isGuest ? 'Invitado' : 'Usuario'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                // ===== TIPO DE CUENTA =====
                Chip(
                  label: Text(
                    _isGuest ? 'Cuenta de invitado' : 'Usuario registrado',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  backgroundColor: _isGuest
                      ? Colors.orange.withAlpha(30)
                      : Colors.green.withAlpha(30),
                  side: BorderSide(
                    color: _isGuest ? Colors.orange : Colors.green,
                  ),
                ),

                const SizedBox(height: 30),

                // ===== INFORMACIÓN =====
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Column(
                    children: [
                      if (!_isGuest) ...[
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Correo electrónico'),
                          subtitle: Text(
                            _user.email ?? 'No disponible',
                          ),
                        ),
                        const Divider(height: 1),
                      ],

                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Cuenta creada'),
                        subtitle: Text(
                          _formatDate(
                            data?['createdAt'],
                          ),
                        ),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(Icons.security),
                        title: const Text('Tipo de autenticación'),
                        subtitle: Text(
                          _isGuest
                              ? 'Sesión anónima (se elimina al cerrar sesión)'
                              : 'Email y contraseña',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ===== INFO INVITADO =====
                if (_isGuest)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Estás usando una cuenta de invitado. '
                                  'Tus conversaciones y datos se eliminarán '
                                  'automáticamente al cerrar sesión.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'No disponible';

    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('d MMMM yyyy', 'es_ES').format(date);
    } catch (_) {
      return 'Fecha inválida';
    }
  }
}