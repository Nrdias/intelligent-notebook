import 'package:hive/hive.dart';

import '../../../../core/utils/constants.dart';
import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/block.dart' as domain_block;
import '../../domain/entities/notebook.dart';
import '../../domain/entities/page.dart';
import '../../domain/failures/notebook_failure.dart';
import '../models/block_model.dart';
import '../models/notebook_model.dart';
import '../models/page_model.dart';

// Extensions for Hive serialization
extension NotebookModelHiveExtension on NotebookModel {
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

extension PageModelHiveExtension on PageModel {
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

extension BlockModelHiveExtension on BlockModel {
  domain_block.Block toDomain() => domain_block.Block(
        id: id,
        type: domain_block.BlockType.values.byName(type.name),
        content: content,
        metadata: metadata,
        order: order,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension NotebookHiveExtension on Notebook {
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'color': color,
        'pages': pages.map((p) => p.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

extension PageHiveExtension on Page {
  Map<String, dynamic> toJson() => {
        'id': id,
        'notebookId': notebookId,
        'title': title,
        'markdownContent': markdownContent,
        'blocks': blocks.map((b) => b.toJson()).toList(),
        'thumbnailUrl': thumbnailUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isPinned': isPinned,
      };
}

extension BlockHiveExtension on domain_block.Block {
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'content': content,
        'metadata': metadata,
        'order': order,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class HiveNotebookDataSource {
  late final Box _notesBox;

  HiveNotebookDataSource._();

  static final HiveNotebookDataSource _instance = HiveNotebookDataSource._();
  static HiveNotebookDataSource get instance => _instance;

  void init() {
    _notesBox = Hive.box(Constants.notesBox);
  }

  // Notebooks
  Result<List<Notebook>, NotebookFailure> getAll() {
    try {
      final values = _notesBox.values.toList();
      final notebooks = values
          .map((v) => NotebookModel.fromJson(v as Map<String, dynamic>).toDomain())
          .toList();
      return success(notebooks);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.getAll failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Result<Notebook, NotebookFailure> getById(String id) {
    try {
      final value = _notesBox.get(id);
      if (value == null) {
        AppLoggerImpl.instance.failure(
            'HiveNotebookDataSource.getById: notebook $id not found');
        return failure(NotebookFailure.notFound);
      }
      final notebook = NotebookModel.fromJson(value as Map<String, dynamic>).toDomain();
      return success(notebook);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.getById failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> create(Notebook notebook) async {
    try {
      await _notesBox.put(notebook.id, notebook.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.create failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> update(Notebook notebook) async {
    try {
      await _notesBox.put(notebook.id, notebook.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.update failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> delete(String id) async {
    try {
      await _notesBox.delete(id);
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.delete failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  // Pages
  Result<List<Page>, NotebookFailure> getPages(String notebookId) {
    final allNotebooksResult = getAll();
    if (allNotebooksResult case Failure(:final failure)) {
      AppLoggerImpl.instance.failure(
          'HiveNotebookDataSource.getPages failure: ${failure.message}');
      return Failure(failure);
    }
    final allNotebooks = allNotebooksResult.unwrap();
    final index = allNotebooks.indexWhere((n) => n.id == notebookId);
    if (index == -1) {
      AppLoggerImpl.instance.failure(
          'HiveNotebookDataSource.getPages: notebook $notebookId not found');
      return failure(NotebookFailure.notFound);
    }
    return success(allNotebooks[index].pages);
  }

  Future<Result<void, NotebookFailure>> savePage(Page page) async {
    try {
      final notebooksResult = getAll();
      if (notebooksResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'HiveNotebookDataSource.savePage failure: ${failure.message}');
        return Failure(failure);
      }
      final notebooks = notebooksResult.unwrap();
      final index = notebooks.indexWhere((n) => n.id == page.notebookId);
      if (index == -1) {
        AppLoggerImpl.instance.failure(
            'HiveNotebookDataSource.savePage: notebook ${page.notebookId} not found');
        return failure(NotebookFailure.notFound);
      }

      final notebook = notebooks[index];
      final pageIndex = notebook.pages.indexWhere((p) => p.id == page.id);
      if (pageIndex == -1) {
        notebook.pages.add(page);
      } else {
        notebook.pages[pageIndex] = page;
      }

      await _notesBox.put(notebook.id, notebook.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.savePage failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }

  Future<Result<void, NotebookFailure>> deletePage(
      String notebookId, String pageId) async {
    try {
      final notebooksResult = getAll();
      if (notebooksResult case Failure(:final failure)) {
        AppLoggerImpl.instance.failure(
            'HiveNotebookDataSource.deletePage failure: ${failure.message}');
        return Failure(failure);
      }
      final notebooks = notebooksResult.unwrap();
      final index = notebooks.indexWhere((n) => n.id == notebookId);
      if (index == -1) {
        AppLoggerImpl.instance.failure(
            'HiveNotebookDataSource.deletePage: notebook $notebookId not found');
        return failure(NotebookFailure.notFound);
      }

      final notebook = notebooks[index];
      notebook.pages.removeWhere((p) => p.id == pageId);
      await _notesBox.put(notebook.id, notebook.toJson());
      return success(null);
    } catch (e, stack) {
      AppLoggerImpl.instance.error('HiveNotebookDataSource.deletePage failed',
          error: e, stackTrace: stack);
      return failure(NotebookFailure(message: e.toString()));
    }
  }
}
