import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatgva/screens/login_screen.dart';
import 'package:chatgva/services/chat_service.dart';
import 'package:chatgva/models/chat_message.dart';
import 'package:chatgva/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _chatService.sendMessage(
      conversationId: widget.conversationId,
      text: text,
      sender: 'user',
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mientras se comprueba el login
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          // No está logueado
          return const LoginScreen();
        }

        // Usuario logueado
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chat'),
          ),
          body: Stack(
            children: [
              // Imagen de fondo
              SizedBox.expand(
                child: Image.asset(
                  'assets/images/bg_chat.jpeg', // tu imagen
                  fit: BoxFit.cover,
                ),
              ),

              // Contenido del chat
              Column(
                children: [
                  Expanded(child: _messages()),
                  _inputBar(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<User?> _checkLoginStatus() async {
    return FirebaseAuth.instance.currentUser;
  }

  Widget _messages() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(widget.conversationId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.only(top: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final msg = ChatMessage.fromFirestore(docs[index]);
            return MessageBubble(message: msg);
          },
        );
      },
    );
  }

  Widget _inputBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}