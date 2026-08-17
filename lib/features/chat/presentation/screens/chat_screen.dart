import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final messageController = TextEditingController();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.aiChat),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              // Start new chat session
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Messages list
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(child: Text('Error: ${state.error}'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.activeSession?.messages.length ?? 0,
                          itemBuilder: (context, index) {
                            final messages =
                                state.activeSession?.messages ?? [];
                            final message = messages[index];
                            return MessageBubble(message: message);
                          },
                        ),
            ),

            // Attachments bar
            if (state.activeSession != null) const _AttachmentsBar(),

            // Input area
            _MessageInput(
              controller: messageController,
              onSend: (text) {
                if (text.trim().isNotEmpty) {
                  notifier.sendMessage(text.trim(), []);
                  messageController.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentsBar extends StatelessWidget {
  const _AttachmentsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.note),
            onPressed: () {
              // Attach a note
            },
            tooltip: 'Attach note',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              // Attach an image
            },
            tooltip: 'Attach image',
          ),
          IconButton(
            icon: const Icon(Icons.draw),
            onPressed: () {
              // Attach a drawing
            },
            tooltip: 'Attach drawing',
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;

  const _MessageInput({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.typeMessage,
                border: InputBorder.none,
              ),
              onSubmitted: (text) => onSend(text),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            tooltip: l10n.send,
            onPressed: () => onSend(controller.text),
          ),
        ],
      ),
    );
  }
}
