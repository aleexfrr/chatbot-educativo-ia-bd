import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final String title;
  final Timestamp updatedAt;

  Conversation({
    required this.id,
    required this.title,
    required this.updatedAt,
  });

  factory Conversation.fromFirestore(String id, Map<String, dynamic> data) {
    return Conversation(
      id: id,
      title: data['title'] ?? 'Conversación',
      updatedAt: data['updatedAt'],
    );
  }
}