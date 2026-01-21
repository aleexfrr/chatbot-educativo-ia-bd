import 'package:chatgva/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatgva/models/login_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  Future<LoginResult> loginAsGuest() async {
    try {
      final result = await _auth.signInAnonymously();
      final user = result.user;

      if (user != null) {
        final userRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userRef.get();

        // Crear documento si no existe
        if (!userDoc.exists) {
          await userRef.set({
            'name': 'Invitado',
            'email': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        // Comprobación por coherencia (aunque no debería pasar)
        if (userDoc.exists && userDoc.data()?['disabled'] == true) {
          return LoginResult(isDisabled: true);
        }

        return LoginResult(user: user);
      } else {
        throw Exception('No se pudo iniciar sesión como invitado.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }


  Future<LoginResult> loginWithEmail(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data()?['disabled'] == true) {
          // await _auth.signOut();
          return LoginResult(isDisabled: true);
        }

        return LoginResult(user: user);
      } else {
        throw Exception('No se pudo iniciar sesión.');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<User?> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> logout() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (user.isAnonymous) {
      await _userService.deleteUserAccount();
    } else {
      await _auth.signOut();
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'invalid-credential':
        return 'Contraseña incorrecta';
      case 'email-already-in-use':
        return 'El correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'Contraseña demasiado débil';
      default:
        return 'Error: ${e.code}';
    }
  }
}
