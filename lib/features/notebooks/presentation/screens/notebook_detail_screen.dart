import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/page.dart' as domain_page;
import '../providers/notebook_detail_provider.dart';
import '../../../canvas/presentation/screens/canvas_screen.dart';
import 'pdf_viewer_screen.dart';

class NotebookDetailScreen extends ConsumerStatefulWidget {
  final String notebookId;

  const NotebookDetailScreen({super.key, required this.notebookId});

  @override
  ConsumerState<NotebookDetailScreen> createState() =>
      _NotebookDetailScreenState();
}

class _NotebookDetailScreenState
    extends ConsumerState<NotebookDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notebookDetailProvider(widget.notebookId));
    final notifier =
        ref.read(notebookDetailProvider(widget.notebookId).notifier);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.notebook?.name ?? l10n.notebooks),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.load(),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text('Error: ${state.error}'))
                : state.pages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.note_alt_outlined,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(l10n.noNotesFound),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add notes or upload PDFs',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: state.pages.length,
                        itemBuilder: (context, index) {
                          final page = state.pages[index];
                          return _NotebookItemCard(
                            page: page,
                            onTap: () {
                              if (page.isPdf) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PdfViewerScreen(page: page),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CanvasScreen(
                                      pageId: page.id,
                                    ),
                                  ),
                                );
                              }
                            },
                            onDelete: () => notifier.deletePage(page.id),
                          );
                        },
                      ),
      ),

      // Floating Action Button at Bottom-Right for New Note or Upload PDF
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: state.isUploading
          ? FloatingActionButton(
              onPressed: null,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          : FloatingActionButton.extended(
              onPressed: () => _showAddOptionsModal(context, notifier),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
    );
  }

  void _showAddOptionsModal(
      BuildContext context, NotebookDetailNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note, color: Colors.blue),
                  ),
                  title: const Text('Create New Note',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Add a handwritten or text note'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCreateNoteDialog(context, notifier);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                  title: const Text('Upload PDF',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Import a PDF and draw over it'),
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      final pdfPage = await notifier
                          .uploadPdfStreamed(result.files.first);
                      if (pdfPage != null && mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PdfViewerScreen(page: pdfPage),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateNoteDialog(
      BuildContext context, NotebookDetailNotifier notifier) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Note'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Note Title',
              hintText: 'Enter note title...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                Navigator.pop(context);
                final newPage = await notifier.createNote(title: title);
                if (newPage != null && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CanvasScreen(
                        pageId: newPage.id,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

class _NotebookItemCard extends StatelessWidget {
  final domain_page.Page page;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotebookItemCard({
    required this.page,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview Header / Icon Box
            Expanded(
              child: Container(
                color: page.isPdf
                    ? Colors.red.withOpacity(0.08)
                    : Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                child: Center(
                  child: page.isPdf
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf,
                              size: 40,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PDF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            if (page.markdownContent.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  page.markdownContent,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),

            // Card Footer Title & Actions
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${page.updatedAt.day}/${page.updatedAt.month}/${page.updatedAt.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (val) {
                      if (val == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                color: Colors.red, size: 18),
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
          ],
        ),
      ),
    );
  }
}
