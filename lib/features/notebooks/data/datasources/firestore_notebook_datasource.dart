import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/block.dart' as entity_block;
import '../../domain/entities/notebook.dart';
import '../../domain/entities/page.dart';
import '../../domain/failures/notebook_failure.dart';
import '../models/block_model.dart';
import '../models/notebook_model.dart';
import '../models/page_model.dart';

class FirestoreNotebookDataSource {
  final FirebaseFirestore _firestore;
  final String userId;

  FirestoreNotebookDataSource(this._firestore, this.userId);

  CollectionReference get _notebooksRef =>
      _firestore.collection('users').doc(userId).collection('notebooks');

  // Notebooks
  Future<Result<List<Notebook>, NotebookFailure>> getAll() async {
    try {
      final snapshot =
          await _notebooksRef.orderBy('updatedAt', descending: true).get();
      final notebooks = snapshot.docs
          .map((doc) => NotebookModel.fromJson(doc.data() as Map<String, dynamic>)
              .toDomain())
          .toList();
      return success(notebooks);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.getAll failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<Notebook, NotebookFailure>> getById(String id) async {
    try {
      final doc = await _notebooksRef.doc(id).get();
      if (!doc.exists) {
        AppLoggerImpl.instance.failure(
            'FirestoreNotebookDataSource.getById: notebook $id not found');
        return failure(NotebookFailure.notFound);
      }
      final notebook = NotebookModel.fromJson(doc.data() as Map<String, dynamic>)
          .toDomain();
      return success(notebook);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.getById failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> create(Notebook notebook) async {
    try {
      await _notebooksRef.doc(notebook.id).set(notebook.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.create failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> update(Notebook notebook) async {
    try {
      await _notebooksRef.doc(notebook.id).update({
        'name': notebook.name,
        'description': notebook.description,
        'color': notebook.color,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.update failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> delete(String id) async {
    try {
      await _notebooksRef.doc(id).delete();
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.delete failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  // Pages
  CollectionReference _pagesRef(String notebookId) =>
      _notebooksRef.doc(notebookId).collection('pages');

  Future<Result<List<Page>, NotebookFailure>> getPages(String notebookId) async {
    try {
      final snapshot = await _pagesRef(notebookId)
          .orderBy('updatedAt', descending: false)
          .get();
      final pages = snapshot.docs
          .map((doc) =>
              PageModel.fromJson(doc.data() as Map<String, dynamic>).toDomain())
          .toList();
      return success(pages);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.getPages failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> savePage(Page page) async {
    try {
      await _pagesRef(page.notebookId).doc(page.id).set(page.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.savePage failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> deletePage(
      String notebookId, String pageId) async {
    try {
      await _pagesRef(notebookId).doc(pageId).delete();
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error(
          'FirestoreNotebookDataSource.deletePage failed',
          error: e,
          stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }
}

// Extensions for serialization
extension NotebookModelExtension on NotebookModel {
  Notebook toDomain() => Notebook(
        id: id,
        name: name,
        description: description,
        color: color,
        pages: pages.map((p) => p.toDomain()).toList(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension PageModelExtension on PageModel {
  Page toDomain() => Page(
        id: id,
        notebookId: notebookId,
        title: title,
        markdownContent: markdownContent,
        blocks: blocks.map((b) => b.toDomain()).toList(),
        thumbnailUrl: thumbnailUrl,
        pdfPath: pdfPath,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isPinned: isPinned,
      );
}

extension BlockModelExtension on BlockModel {
  entity_block.Block toDomain() => entity_block.Block(
        id: id,
        type: entity_block.BlockType.values.byName(type.name),
        content: content,
        metadata: metadata,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
