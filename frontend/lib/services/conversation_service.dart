import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConversationService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _conversationsRef =>
      _firestore.collection('users').doc(_uid).collection('conversations');

  /// Obtener o crear la primera conversación
  Future<String> getOrCreateInitialConversation() async {
    final snapshot = await _conversationsRef
        .orderBy('updatedAt', descending: true)
        .limit(1)
        .get();

    // Si existe una conversación se usa
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id;
    }

    // Si no existe se crea una nueva
    final user = _auth.currentUser!;
    return createConversation(isGuest: user.isAnonymous);
  }

  /// Crear nueva conversación
  Future<String> createConversation({required bool isGuest}) async {
    final doc = await _conversationsRef.add({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isGuest': isGuest,
    });

    return doc.id;
  }

  /// Obtener conversaciones del usuario
  Stream<QuerySnapshot> getConversations() {
    return _conversationsRef
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  /// Borrar una conversación completa (mensajes incluidos)
  Future<void> deleteConversation(String conversationId) async {
    final convRef = _conversationsRef.doc(conversationId);
    final messages = await convRef.collection('messages').get();

    for (final msg in messages.docs) {
      await msg.reference.delete();
    }

    await convRef.delete();
  }

  /// Borrar TODAS las conversaciones (para invitados)
  Future<void> deleteAllConversations() async {
    final convs = await _conversationsRef.get();
    for (final conv in convs.docs) {
      await deleteConversation(conv.id);
    }
  }
}