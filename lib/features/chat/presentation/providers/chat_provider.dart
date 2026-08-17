import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';

// State
class ChatState {
  final List<ChatSession> sessions;
  final ChatSession? activeSession;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.sessions = const [],
    this.activeSession,
    this.isLoading = true,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatSession>? sessions,
    ChatSession? activeSession,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      sessions: sessions ?? this.sessions,
      activeSession: activeSession ?? this.activeSession,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
    );
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    loadSessions();
  }

  Future<void> loadSessions() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Temporary mock
      state = state.copyWith(
        sessions: _mockSessions(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> sendMessage(
      String message, List<ContextAttachment> attachments) async {
    state = state.copyWith(isSending: true, error: null);
    try {
      await Future.delayed(const Duration(seconds: 1));
      state = state.copyWith(isSending: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSending: false);
    }
  }

  List<ChatSession> _mockSessions() {
    return [
      ChatSession(
        id: '1',
        title: 'Welcome!',
        messages: [
          ChatMessage(
            id: '1',
            role: MessageRole.assistant,
            content: 'Hello! How can I help you today?',
            timestamp: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
