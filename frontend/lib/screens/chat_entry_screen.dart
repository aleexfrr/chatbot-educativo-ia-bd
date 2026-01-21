import 'package:flutter/material.dart';
import '../services/conversation_service.dart';
import '../models/conversation.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class ChatEntryScreen extends StatefulWidget {
  const ChatEntryScreen({super.key});

  @override
  State<ChatEntryScreen> createState() => _ChatEntryScreenState();
}

class _ChatEntryScreenState extends State<ChatEntryScreen> {
  final ConversationService _conversationService = ConversationService();

  String? selectedConversationId;
  bool _loadingInitialConversation = true;

  @override
  void initState() {
    super.initState();
    _loadInitialConversation();
  }

  Future<void> _loadInitialConversation() async {
    final convId = await _conversationService.getOrCreateInitialConversation();

    if (!mounted) return;

    setState(() {
      selectedConversationId = convId;
      _loadingInitialConversation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loadingInitialConversation) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),

      /// DRAWER
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Conversaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // LISTADO
              Expanded(
                child: StreamBuilder<List<Conversation>>(
                  stream: _conversationService.getUserConversations(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final conversations = snapshot.data!;

                    if (conversations.isEmpty) {
                      return const Center(
                        child: Text('No hay conversaciones'),
                      );
                    }

                    return ListView.separated(
                      itemCount: conversations.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final conv = conversations[index];

                        return ListTile(
                          leading: const Icon(Icons.chat_bubble_outline),
                          title: Text(
                            conv.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          selected:
                          conv.id == selectedConversationId,
                          selectedTileColor:
                          theme.colorScheme.primary.withAlpha(20),
                          onTap: () {
                            setState(() {
                              selectedConversationId = conv.id;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              const Divider(),

              // NUEVA CONVERSACIÓN
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Nueva conversación',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      final newConvId =
                      await _conversationService.createConversation();

                      if (!mounted) return;

                      setState(() {
                        selectedConversationId = newConvId;
                      });

                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /// CHAT
      body: ChatScreen(
        conversationId: selectedConversationId!,
      ),
    );
  }
}