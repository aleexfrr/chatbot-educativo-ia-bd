import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'conversation_service.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ConversationService conversationService = ConversationService();

  // Función para crear un documento de usuario en Firestore
  Future<void> createUserDocument({
    required String nombre,
    required String apellido,
    required String email,

  }) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': nombre,
          'lastname': apellido,
          'email': email,
          'createdAt': Timestamp.now(),
          'disabled': false,
        });

        await user.updateDisplayName('$nombre $apellido');
      } catch (e) {
        throw Exception('Error al crear el documento de usuario: $e');
      }
    }
  }

  Future<void> updateUserDocument({
    required String nombre,
    required String apellido,
    required String email,
  }) async {
    final user = _auth.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': nombre,
          'lastname': apellido,
          'email': email,
        });
      } catch (e) {
        throw Exception('Error al actualizar el documento de usuario: $e');
      }
    }
  }

  // Función para obtener los datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return userDoc.exists ? userDoc.data() : null;
    } catch (e) {
      throw Exception('Error al obtener los datos del usuario: $e');
    }
  }

  // Eliminar cuenta y documento del usuario
  Future<void> deleteUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await conversationService.deleteAllConversations();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception('Debes volver a iniciar sesión para eliminar tu cuenta.');
      } else {
        throw Exception('Error al eliminar la cuenta: ${e.message}');
      }
    } catch (e) {
      throw Exception('Error general al eliminar la cuenta: $e');
    }
  }

  // Deshabilitar cuenta (solo actualiza campo en Firestore)
  Future<void> disableUserAccount() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'disabled': true,
      });
      // Cerrar sesión automáticamente
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error al deshabilitar la cuenta: $e');
    }
  }
}