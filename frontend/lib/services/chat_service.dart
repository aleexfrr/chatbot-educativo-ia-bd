import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _messagesRef =>
      _firestore.collection('chats').doc('global').collection('messages');

  Stream<QuerySnapshot> getMessages() {
    return _messagesRef
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage(String text) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _messagesRef.add({
      'text': text,
      'uid': user.uid,
      'username': user.isAnonymous ? 'Invitado' : (user.email ?? 'Usuario'),
      'isGuest': user.isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}