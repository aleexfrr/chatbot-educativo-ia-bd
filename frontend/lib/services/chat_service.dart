import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference _messagesRef(String conversationId) {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');
  }

  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _messagesRef(conversationId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required String sender, // 'user' | 'assistant'
  }) async {
    await _messagesRef(conversationId).add({
      'text': text,
      'sender': sender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // updatedAt de la conversación
    final uid = _auth.currentUser!.uid;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('conversations')
        .doc(conversationId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}