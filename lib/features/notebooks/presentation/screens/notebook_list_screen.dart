import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notebook.dart';
import '../providers/notebook_provider.dart';
import 'notebook_detail_screen.dart';

class NotebookListScreen extends ConsumerWidget {
  const NotebookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notebookListProvider);
    final notifier = ref.read(notebookListProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(l10n.notebooks),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadNotebooks(),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : state.notebooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_stories_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(l10n.noNotesFound),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create a notebook',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.notebooks.length,
                        itemBuilder: (context, index) {
                          final notebook = state.notebooks[index];
                          return NotebookCard(notebook: notebook);
                        },
                      ),
      ),

      // FAB to create a new notebook with a custom title
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNotebookDialog(context, notifier),
        icon: const Icon(Icons.add),
        label: const Text('New Notebook'),
      ),
    );
  }

  void _showCreateNotebookDialog(
      BuildContext context, NotebookListNotifier notifier) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedColor = '#6750A4';

    final colors = [
      '#6750A4',
      '#00695C',
      '#C2185B',
      '#1976D2',
      '#F57C00',
      '#7B1FA2',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Notebook'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Notebook Title',
                      hintText: 'e.g. Work, School, Math',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cover Color:',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: colors.map((hexColor) {
                      final isSelected = selectedColor == hexColor;
                      final colorInt =
                          int.parse(hexColor.replaceFirst('#', '0xFF'));
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = hexColor),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color(colorInt),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.pop(context);
                    await notifier.createNotebook(
                      name: title,
                      description: descController.text.trim(),
                      color: selectedColor,
                    );
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class NotebookCard extends ConsumerWidget {
  final Notebook notebook;

  const NotebookCard({super.key, required this.notebook});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(notebookListProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NotebookDetailScreen(notebookId: notebook.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(
                      int.parse(notebook.color.replaceFirst('#', '0xFF'))),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notebook.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    if (notebook.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notebook.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (notebook.pages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${notebook.pages.length} items',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) {
                  if (val == 'delete') {
                    notifier.deleteNotebook(notebook.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
