import 'package:chatgva/web_service/aules_ws.dart';
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

  /// Guarda Aules + hace login en el servidor
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

    // Login en el servidor Node
    await AulesWebService.login(
      nia: username,
      password: password,
      modalidad: tipo,
      provincia: provincia,
    );

    // Si el login va OK, guardamos en Firebase
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

  /// Comprueba / descarga los PDFs del usuario en el backend
  Future<void> ensurePdfsAvailable() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no logueado');

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();
    final aules = data?['aules'];

    if (aules == null) {
      throw Exception('El usuario no tiene datos de Aules');
    }

    await AulesWebService.downloadPdfs(
      instituto: aules['institut'],
      modalidad: aules['tipo'],
      provincia: aules['provincia'],
    );
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