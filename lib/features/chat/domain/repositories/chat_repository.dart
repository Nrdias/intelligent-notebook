import '../../../../tools/result.dart';
import '../entities/chat_message.dart';
import '../entities/chat_session.dart';
import '../failures/chat_failure.dart';

abstract class ChatRepository {
  Future<Result<List<ChatSession>, ChatFailure>> getAllSessions();
  Future<Result<ChatSession, ChatFailure>> getSession(String id);
  Future<Result<void, ChatFailure>> createSession(ChatSession session);
  Future<Result<void, ChatFailure>> addMessage(
      String sessionId, ChatMessage message);
  Future<Result<void, ChatFailure>> deleteSession(String id);
}
