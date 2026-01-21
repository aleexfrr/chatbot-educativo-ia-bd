import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatgva/models/conversation.dart';

class ConversationService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference get _conversationsRef =>
      _firestore.collection('users').doc(_uid).collection('conversations');

  bool get isGuest => _auth.currentUser?.isAnonymous ?? true;

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
    return createConversation();
  }

  /// Crear nueva conversación
  Future<String> createConversation() async {
    final doc = await _conversationsRef.add({
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isGuest': isGuest,
    });

    return doc.id;
  }

  /// Obtener conversaciones del usuario
  Stream<List<Conversation>> getUserConversations() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Conversation.fromFirestore(doc.id, doc.data()))
          .toList();
    });
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