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
  late final CanvasNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ref.read(canvasStateProvider.notifier);
    _notifier.resetAndLoadCanvas(widget.pageId);
  }

  @override
  void dispose() {
    _notifier.disposeCanvas();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _notifier.disposeCanvas();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121214),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121214),
          elevation: 0,
          leading: IconButton(
            icon: AppSvgIcon.chevron(size: 20, color: Colors.white),
            tooltip: l10n.back,
            onPressed: () {
              _notifier.autoSave(force: true);
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Canvas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              icon: AppSvgIcon.save(size: 20, color: Colors.white),
              tooltip: l10n.save,
              onPressed: () async {
                await _notifier.autoSave(force: true);
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
      ),
    );
  }
}
