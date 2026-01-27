import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AulesService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtiene la información de Aules del usuario actual
  Future<Map<String, dynamic>?> getAulesData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    return data?['aules'] as Map<String, dynamic>?;
  }

  /// Guarda o actualiza la información de Aules del usuario actual
  Future<void> setAulesData({
    required String provincia,
    required String poble,
    required String institut,
    required String tipo,
    required String username,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no logueado');

    final aulesData = {
      'provincia': provincia,
      'poble': poble,
      'institut': institut,
      'tipo': tipo,
      'username': username,
      'password': password,
    };

    await _firestore.collection('users').doc(user.uid).set({
      'aules': aulesData,
    }, SetOptions(merge: true));
  }

  /// Elimina la información de Aules del usuario actual
  Future<void> deleteAulesData() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no logueado');

    await _firestore.collection('users').doc(user.uid).update({
      'aules': FieldValue.delete(),
    });
  }
}