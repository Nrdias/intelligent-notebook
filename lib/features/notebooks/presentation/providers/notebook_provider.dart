import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../tools/result.dart';
import '../../domain/entities/notebook.dart';
import '../../domain/repositories/notebook_repository.dart';

// State
class NotebookListState {
  final List<Notebook> notebooks;
  final bool isLoading;
  final String? error;

  const NotebookListState({
    this.notebooks = const [],
    this.isLoading = true,
    this.error,
  });

  NotebookListState copyWith({
    List<Notebook>? notebooks,
    bool? isLoading,
    String? error,
  }) {
    return NotebookListState(
      notebooks: notebooks ?? this.notebooks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Providers
final notebookListProvider =
    StateNotifierProvider<NotebookListNotifier, NotebookListState>((ref) {
  return NotebookListNotifier(repository: getIt<NotebookRepository>());
});

class NotebookListNotifier extends StateNotifier<NotebookListState> {
  final NotebookRepository _repository;
  final _uuid = const Uuid();

  NotebookListNotifier({required NotebookRepository repository})
      : _repository = repository,
        super(const NotebookListState()) {
    loadNotebooks();
  }

  Future<void> loadNotebooks() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getAll();
    switch (result) {
      case Success(:final data):
        state = state.copyWith(
          notebooks: data,
          isLoading: false,
        );
      case Failure(:final failure):
        state = state.copyWith(
          error: failure.message,
          isLoading: false,
        );
    }
  }

  Future<bool> createNotebook({
    required String name,
    String description = '',
    String color = '#6750A4',
  }) async {
    final now = DateTime.now();
    final newNotebook = Notebook(
      id: _uuid.v4(),
      name: name,
      description: description,
      color: color,
      pages: const [],
      createdAt: now,
      updatedAt: now,
    );

    final result = await _repository.create(newNotebook);
    if (result case Success()) {
      await loadNotebooks();
      return true;
    }
    return false;
  }

  Future<bool> deleteNotebook(String id) async {
    final result = await _repository.delete(id);
    if (result case Success()) {
      await loadNotebooks();
      return true;
    }
    return false;
  }
}
