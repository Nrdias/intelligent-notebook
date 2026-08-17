import 'package:http/http.dart' as http;

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/failures/chat_failure.dart';

class AiDatasource {
  final String apiKey;
  final String baseUrl;

  AiDatasource(
      {required this.apiKey,
      this.baseUrl = 'https://generativelanguage.googleapis.com'});

  Future<Result<String, ChatFailure>> sendMessage(
      String message, List<ContextAttachment> attachments) async {
    try {
      final prompt = _buildPrompt(message, attachments);

      final url = Uri.parse(
          '$baseUrl/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: '''
{
  "contents": [
    {
      "parts": [
        {
          "text": "$prompt"
        }
      ]
    }
  ]
}
''',
      );

      if (response.statusCode == 200) {
        return success('Response from AI');
      } else {
        final f = ChatFailure(
            message: 'Failed to get AI response: ${response.statusCode}');
        AppLoggerImpl.instance
            .failure('AiDatasource.sendMessage: ${f.message}');
        return failure(f);
      }
    } catch (e, stack) {
      AppLoggerImpl.instance.error('AiDatasource.sendMessage failed',
          error: e, stackTrace: stack);
      return failure(ChatFailure(message: e.toString()));
    }
  }

  String _buildPrompt(String message, List<ContextAttachment> attachments) {
    final buffer = StringBuffer();

    if (attachments.isNotEmpty) {
      buffer.writeln('Context information from user\'s notes and drawings:');
      for (final attachment in attachments) {
        buffer.writeln('- ${attachment.type}: ${attachment.content}');
      }
      buffer.writeln('');
    }

    buffer.writeln('User question: $message');
    return buffer.toString();
  }
}
