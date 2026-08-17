import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../canvas/presentation/widgets/drawing_canvas.dart';
import '../../../canvas/presentation/widgets/toolbar.dart';
import '../../domain/entities/page.dart' as domain_page;

class PdfViewerScreen extends ConsumerStatefulWidget {
  final domain_page.Page page;

  const PdfViewerScreen({super.key, required this.page});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isDrawingMode = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pdfFile = File(widget.page.pdfPath ?? '');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.page.title),
        actions: [
          // Toggle Drawing Mode vs Scroll Mode
          IconButton(
            icon: Icon(
              _isDrawingMode ? Icons.edit : Icons.pan_tool_outlined,
              color: _isDrawingMode
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: _isDrawingMode ? 'Mode: Drawing' : 'Mode: Scroll PDF',
            onPressed: () {
              setState(() {
                _isDrawingMode = !_isDrawingMode;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. PDF Viewer
          if (widget.page.pdfPath != null && pdfFile.existsSync())
            PdfViewer.file(
              widget.page.pdfPath!,
              controller: _pdfController,
              params: PdfViewerParams(
                maxScale: 4.0,
                minScale: 1.0,
                enableTextSelection: !_isDrawingMode,
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.picture_as_pdf, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l10n.noNotesFound),
                ],
              ),
            ),

          // 2. Drawing Layer Overlay (active in Drawing mode)
          if (_isDrawingMode)
            Positioned.fill(
              child: DrawingCanvas(pageId: widget.page.id),
            ),

          // 3. Floating Toolbar (Top-Center)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Toolbar(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
