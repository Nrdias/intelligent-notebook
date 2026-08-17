import 'package:flutter/material.dart';

import '../../features/notebooks/domain/entities/page.dart' as notebook_page;
import '../../features/notebooks/domain/entities/block.dart' as notebook_block;
import '../../core/utils/formatters.dart';

class NoteCardWidget extends StatelessWidget {
  final notebook_page.Page page;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCardWidget({
    super.key,
    required this.page,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.title.isEmpty ? 'Untitled' : page.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                _getPreviewContent(page.markdownContent),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    _getBlockIcon(page.blocks),
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${page.blocks.length} block${page.blocks.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.formatRelativeTime(page.updatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade400,
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

  String _getPreviewContent(String markdown) {
    // Strip markdown syntax for preview
    final plain = markdown
        .replaceAll(RegExp(r'#+\s*'), '')
        .replaceAll(RegExp(r'\*\*|\*|__|_'), '')
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        .replaceAll(RegExp(r'!\[[^\]]*\]\([^)]*\)'), '[image]')
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        .replaceAll(RegExp(r'[-*]\s'), '')
        .trim();
    return plain.isNotEmpty ? plain : 'Empty note';
  }

  IconData _getBlockIcon(List<notebook_block.Block> blocks) {
    if (blocks.isEmpty) return Icons.note;
    final firstType = blocks.first.type;
    switch (firstType) {
      case notebook_block.BlockType.drawing:
        return Icons.brush;
      case notebook_block.BlockType.image:
        return Icons.image;
      case notebook_block.BlockType.checklist:
        return Icons.checklist;
      case notebook_block.BlockType.code:
        return Icons.code;
      case notebook_block.BlockType.text:
        return Icons.text_fields;
    }
  }
}
