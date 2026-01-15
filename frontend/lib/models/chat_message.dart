import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String text;
  final String sender; // 'user' | 'assistant'
  final Timestamp createdAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ChatMessage(
      id: doc.id,
      text: data['text'] ?? '',
      sender: data['sender'] == 'user' ? 'user' : 'assistant',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}