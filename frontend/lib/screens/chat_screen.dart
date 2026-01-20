import 'package:chatgva/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    return Scaffold(
      drawer: _conversationDrawer(), // menu lateral
      appBar: AppBar(
        title: const Text('XenoBOT'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset(
              'assets/images/bg_chat.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Contenido
          Column(
            children: [
              Expanded(child: _messages()),
              _inputBar(),
            ],
          ),
        ],
      ),
    );
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

  /// Drawer provisional (lo conectaremos con ConversationService)
  Widget _conversationDrawer() {
    return Drawer(
      child: Column(
        children: [
          const DrawerHeader(
            child: Text(
              'Conversaciones',
              style: TextStyle(fontSize: 20),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nueva conversación'),
            onTap: () {
              // TODO: crear conversación y navegar
            },
          ),
          const Divider(),
          const Expanded(
            child: Center(
              child: Text('Listado de conversaciones'),
            ),
          ),
        ],
      ),
    );
  }
}