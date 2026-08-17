import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../entities/chat_message.dart';
import '../failures/chat_failure.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase(this.repository);

  Future<Result<String, ChatFailure>> call(
      String sessionId, String message, List<ContextAttachment> attachments) async {
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      content: message,
      timestamp: DateTime.now(),
      attachments: attachments,
    );
    final userMsgResult = await repository.addMessage(sessionId, userMessage);
    if (userMsgResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'SendMessageUseCase (user message) failure: ${failure.message}');
      return Failure(failure);
    }

    const response =
        'This is a placeholder response. AI integration will be implemented in a future step.';

    final assistantMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      role: MessageRole.assistant,
      content: response,
      timestamp: DateTime.now(),
    );
    final assistantMsgResult =
        await repository.addMessage(sessionId, assistantMessage);
    if (assistantMsgResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'SendMessageUseCase (assistant message) failure: ${failure.message}');
      return Failure(failure);
    }

    return success(response);
  }
}
