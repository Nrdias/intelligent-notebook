import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/failures/chat_failure.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_message_model.dart' as model_message;
import '../models/chat_session_model.dart' as model_session;

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  ChatRepositoryImpl(this._firestore, this.userId);

  CollectionReference get _chatsRef =>
      _firestore.collection('users').doc(userId).collection('chats');

  @override
  Future<Result<List<ChatSession>, ChatFailure>> getAllSessions() async {
    try {
      final snapshot =
          await _chatsRef.orderBy('updatedAt', descending: true).get();
      final sessions = snapshot.docs
          .map((doc) => model_session.ChatSessionModel.fromJson(
                  doc.data() as Map<String, dynamic>)
              .toDomain())
          .toList();
      return success(sessions);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('ChatRepositoryImpl.getAllSessions failed',
          error: e, stackTrace: stack);
      return failure(ChatFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<ChatSession, ChatFailure>> getSession(String id) async {
    try {
      final doc = await _chatsRef.doc(id).get();
      if (!doc.exists) {
        AppLoggerImpl.instance.failure(
            'ChatRepositoryImpl.getSession: session $id not found');
        return failure(ChatFailure.sessionNotFound);
      }
      final session = model_session.ChatSessionModel.fromJson(
              doc.data() as Map<String, dynamic>)
          .toDomain();
      return success(session);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('ChatRepositoryImpl.getSession failed',
          error: e, stackTrace: stack);
      return failure(ChatFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, ChatFailure>> createSession(ChatSession session) async {
    try {
      await _chatsRef.doc(session.id).set(session.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('ChatRepositoryImpl.createSession failed',
          error: e, stackTrace: stack);
      return failure(ChatFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, ChatFailure>> addMessage(
      String sessionId, ChatMessage message) async {
    try {
      final sessionDoc = await _chatsRef.doc(sessionId).get();
      if (!sessionDoc.exists) {
        const f = ChatFailure(message: 'Session does not exist');
        AppLoggerImpl.instance
            .failure('ChatRepositoryImpl.addMessage: ${f.message}');
        return failure(f);
      }

      final data = sessionDoc.data()! as Map<String, dynamic>;
      final messages = (data['messages'] as List<dynamic>?)
              ?.map((m) => model_message.ChatMessageModel.fromJson(
                  m as Map<String, dynamic>))
              .toList() ??
          [];

      messages.add(model_message.ChatMessageModel(
        id: message.id,
        role: model_message.MessageRole.user,
        content: message.content,
        timestamp: message.timestamp,
        attachments: message.attachments
            .map((a) => model_message.ContextAttachment(
                  type: a.type,
                  content: a.content,
                  thumbnailUrl: a.thumbnailUrl,
                ))
            .toList(),
      ));

      await _chatsRef.doc(sessionId).update({
        'messages': messages.map((m) => m.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
        'title': messages.length == 1
            ? message.content.substring(0, 50)
            : (data['title'] ?? ''),
      });
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('ChatRepositoryImpl.addMessage failed',
          error: e, stackTrace: stack);
      return failure(ChatFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void, ChatFailure>> deleteSession(String id) async {
    try {
      await _chatsRef.doc(id).delete();
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('ChatRepositoryImpl.deleteSession failed',
          error: e, stackTrace: stack);
      return failure(ChatFailure(message: e.toString()));
    }
  }
}

// Extensions for serialization
extension ChatSessionModelExtension on model_session.ChatSessionModel {
  ChatSession toDomain() => ChatSession(
        id: id,
        title: title,
        messages: messages.map((m) => m.toDomain()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension ChatMessageModelExtension on model_message.ChatMessageModel {
  ChatMessage toDomain() => ChatMessage(
        id: id,
        role: MessageRole.user,
        content: content,
        timestamp: timestamp,
        attachments: attachments
            .map((a) => ContextAttachment(
                  type: a.type,
                  content: a.content,
                  thumbnailUrl: a.thumbnailUrl,
                ))
            .toList(),
      );
}
