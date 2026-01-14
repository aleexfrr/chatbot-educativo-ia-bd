import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String uid;
  final String username;
  final bool isGuest;
  final Timestamp createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.uid,
    required this.username,
    required this.isGuest,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      uid: data['uid'] ?? '',
      username: data['username'] ?? 'Invitado',
      isGuest: data['isGuest'] ?? true,
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}