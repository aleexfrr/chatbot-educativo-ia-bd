import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatgva/services/chat_service.dart';
import 'package:chatgva/web_service/agent_ws.dart';
import 'package:chatgva/models/chat_message.dart';
import 'package:chatgva/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;

  const ChatScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  bool _isBotTyping = false;

  /// El sessionId es el mismo que el conversationId
  /// Esto mantiene el contexto único por conversación
  String get _sessionId => widget.conversationId;


  

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    // Guardar mensaje del usuario en Firestore
    await _chatService.sendMessage(
      conversationId: widget.conversationId,
      text: text,
      sender: 'user',
    );

    setState(() => _isBotTyping = true);

    try {
      print('🔑 Usando sessionId: $_sessionId');
      
      // Llamada al backend con sessionId
      final botText = await AgentWebService.obtenerRespuestaAgente(
        text,
        _sessionId, // 👈 Pasa el sessionId único de esta conversación
      );

      // Guardar respuesta del bot en Firestore
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        text: botText,
        sender: 'assistant',
      );
      
    } catch (e) {
      print('❌ Error en _send: $e');
      
      // Guardar mensaje de error
      await _chatService.sendMessage(
        conversationId: widget.conversationId,
        text: 'Lo siento, hubo un error al obtener la respuesta: ${e.toString()}',
        sender: 'assistant',
      );

      // Mostrar snackbar al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBotTyping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Conversación'),
        actions: [
          // Mostrar el sessionId en debug (opcional)
          if (const bool.fromEnvironment('dart.vm.product') == false)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Session Info'),
                    content: Text('SessionID: $_sessionId'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_chat.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          // Contenido
          Column(
            children: [
              Expanded(child: _messages()),
              if (_isBotTyping) _botTypingIndicator(),
              _inputBar(theme),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Empieza la conversación',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final msg = ChatMessage.fromFirestore(docs[index]);
            return MessageBubble(message: msg);
          },
        );
      },
    );
  }

  Widget _inputBar(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Escribe un mensaje...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _send(), // Enviar con Enter
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                ),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: theme.colorScheme.primary,
                ),
                onPressed: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        children: const [
          Text(
            'XenoBOT está escribiendo...',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}