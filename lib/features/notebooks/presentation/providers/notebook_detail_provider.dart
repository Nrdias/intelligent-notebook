import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../tools/logger.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/notebook.dart';
import '../../domain/entities/page.dart';
import '../../domain/repositories/notebook_repository.dart';

class NotebookDetailState {
  final Notebook? notebook;
  final List<Page> pages;
  final bool isLoading;
  final bool isUploading;
  final String? error;

  const NotebookDetailState({
    this.notebook,
    this.pages = const [],
    this.isLoading = true,
    this.isUploading = false,
    this.error,
  });

  NotebookDetailState copyWith({
    Notebook? notebook,
    List<Page>? pages,
    bool? isLoading,
    bool? isUploading,
    String? error,
  }) {
    return NotebookDetailState(
      notebook: notebook ?? this.notebook,
      pages: pages ?? this.pages,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
    );
  }
}

final notebookDetailProvider = StateNotifierProvider.family<
    NotebookDetailNotifier, NotebookDetailState, String>((ref, notebookId) {
  return NotebookDetailNotifier(
    notebookId: notebookId,
    repository: getIt<NotebookRepository>(),
  );
});

class NotebookDetailNotifier extends StateNotifier<NotebookDetailState> {
  final String notebookId;
  final NotebookRepository _repository;
  final _uuid = const Uuid();

  NotebookDetailNotifier({
    required this.notebookId,
    required NotebookRepository repository,
  })  : _repository = repository,
        super(const NotebookDetailState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);

    final notebookResult = await _repository.getById(notebookId);
    final pagesResult = await _repository.getPages(notebookId);

    Notebook? notebook;
    List<Page> pages = const [];

    if (notebookResult case Success(:final data)) {
      notebook = data;
    }

    if (pagesResult case Success(:final data)) {
      pages = data;
    } else if (notebook != null) {
      pages = notebook.pages;
    }

    // Self-healing for legacy PDF pages that lost pdfPath in Hive storage
    final healedPages = <Page>[];
    Directory? pdfDir;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      pdfDir = Directory('${appDir.path}/notebook_pdfs/$notebookId');
    } catch (_) {}

    for (final p in pages) {
      if (!p.isPdf && pdfDir != null && await pdfDir.exists()) {
        final pdfFiles = pdfDir.listSync().whereType<File>().toList();
        if (pdfFiles.isNotEmpty) {
          File? matched;
          for (final f in pdfFiles) {
            final filename = f.path.split('/').last;
            if (filename.contains(p.title) || p.title.contains(filename)) {
              matched = f;
              break;
            }
          }
          matched ??= pdfFiles.last;
          final updatedPage = Page(
            id: p.id,
            notebookId: p.notebookId,
            title: p.title,
            markdownContent: p.markdownContent,
            blocks: p.blocks,
            thumbnailUrl: p.thumbnailUrl,
            pdfPath: matched.path,
            createdAt: p.createdAt,
            updatedAt: p.updatedAt,
            isPinned: p.isPinned,
          );
          await _repository.savePage(updatedPage);
          healedPages.add(updatedPage);
          continue;
        }
      }
      healedPages.add(p);
    }
    pages = healedPages;

    state = state.copyWith(
      notebook: notebook,
      pages: pages,
      isLoading: false,
    );
  }

  Future<Page?> createNote({required String title}) async {
    final now = DateTime.now();
    final newPage = Page(
      id: _uuid.v4(),
      notebookId: notebookId,
      title: title.isEmpty ? 'Untitled Note' : title,
      markdownContent: '',
      blocks: const [],
      createdAt: now,
      updatedAt: now,
    );

    final result = await _repository.savePage(newPage);
    if (result case Success()) {
      await load();
      return newPage;
    }
    return null;
  }

  /// Uploads a PDF file using stream chunking to prevent loading full bytes in memory
  Future<Page?> uploadPdfStreamed(PlatformFile pickedFile) async {
    if (pickedFile.path == null) return null;

    state = state.copyWith(isUploading: true);
    try {
      final sourceFile = File(pickedFile.path!);
      if (!await sourceFile.exists()) {
        state = state.copyWith(isUploading: false, error: 'File not found');
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final pdfDir = Directory('${appDir.path}/notebook_pdfs/$notebookId');
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      final targetFileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
      final targetPath = '${pdfDir.path}/$targetFileName';
      final targetFile = File(targetPath);

      // Memory-optimized: stream chunks from source to target file
      final inputStream = sourceFile.openRead();
      final outputSink = targetFile.openWrite();

      await inputStream.pipe(outputSink);

      AppLoggerImpl.instance
          .log('PDF uploaded successfully via stream to $targetPath');

      final now = DateTime.now();
      final pdfPage = Page(
        id: _uuid.v4(),
        notebookId: notebookId,
        title: pickedFile.name.replaceAll('.pdf', '').replaceAll('.PDF', ''),
        markdownContent: '',
        blocks: const [],
        pdfPath: targetPath,
        createdAt: now,
        updatedAt: now,
      );

      final saveResult = await _repository.savePage(pdfPage);
      state = state.copyWith(isUploading: false);

      if (saveResult case Success()) {
        await load();
        return pdfPage;
      }
      return null;
    } catch (e, stack) {
      AppLoggerImpl.instance.error('uploadPdfStreamed failed',
          error: e, stackTrace: stack);
      state = state.copyWith(
        isUploading: false,
        error: 'Failed to upload PDF: $e',
      );
      return null;
    }
  }

  Future<bool> deletePage(String pageId) async {
    final result = await _repository.deletePage(notebookId, pageId);
    if (result case Success()) {
      await load();
      return true;
    }
    return false;
  }
}
