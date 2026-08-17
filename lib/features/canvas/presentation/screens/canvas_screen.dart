import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/design_system/widgets/app_svg_icon.dart';
import '../../../../l10n/app_localizations.dart';

import '../providers/canvas_provider.dart';
import '../widgets/drawing_canvas.dart';
import '../widgets/toolbar.dart';

class CanvasScreen extends ConsumerStatefulWidget {
  final String pageId;

  const CanvasScreen({super.key, required this.pageId});

  @override
  ConsumerState<CanvasScreen> createState() => _CanvasScreenState();
}

class _CanvasScreenState extends ConsumerState<CanvasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(canvasStateProvider.notifier).loadCanvas(widget.pageId);
    });
  }

  @override
  void dispose() {
    ref.read(canvasStateProvider.notifier).disposeCanvas();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canvasState = ref.watch(canvasStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121214),
        elevation: 0,
        leading: IconButton(
          icon: AppSvgIcon.chevron(size: 20, color: Colors.white),
          tooltip: l10n.back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Canvas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (canvasState.isSaving)
              const Text(
                'Saving...',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              )
            else if (canvasState.lastSavedAt != null && !canvasState.isDirty)
              Text(
                'Auto-saved at ${_formatTime(canvasState.lastSavedAt!)}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              )
            else if (canvasState.isDirty)
              const Text(
                'Unsaved changes',
                style: TextStyle(fontSize: 11, color: Colors.orangeAccent),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: AppSvgIcon.save(size: 20, color: Colors.white),
            tooltip: l10n.save,
            onPressed: () async {
              await ref
                  .read(canvasStateProvider.notifier)
                  .autoSave(force: true);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.drawingSaved),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: l10n.moreOptions,
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Toolbar(),
            Expanded(
              child: DrawingCanvas(pageId: widget.pageId),
            ),
          ],
        ),
      ),
    );
  }
}
