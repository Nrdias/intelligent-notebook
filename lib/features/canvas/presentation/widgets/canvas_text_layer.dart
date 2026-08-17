import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/canvas_provider.dart';

class CanvasTextLayer extends ConsumerStatefulWidget {
  final String pageId;

  const CanvasTextLayer({super.key, required this.pageId});

  @override
  ConsumerState<CanvasTextLayer> createState() => _CanvasTextLayerState();
}

class _CanvasTextLayerState extends ConsumerState<CanvasTextLayer> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    final state = ref.read(canvasStateProvider);
    _controller = TextEditingController(text: state.canvasText);
    _focusNode = FocusNode();

    _controller.addListener(() {
      final currentText = ref.read(canvasStateProvider).canvasText;
      if (_controller.text != currentText) {
        ref
            .read(canvasStateProvider.notifier)
            .updateCanvasText(_controller.text);
      }
    });

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        final currentTool = ref.read(canvasStateProvider).currentTool;
        if (currentTool == CanvasTool.text) {
          // Switch tool to pen when unfocused
          ref.read(canvasStateProvider.notifier).setTool(CanvasTool.pen);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(canvasStateProvider);

    // Sync controller text if updated externally
    if (_controller.text != state.canvasText) {
      _controller.value = _controller.value.copyWith(
        text: state.canvasText,
        selection: TextSelection.collapsed(offset: state.canvasText.length),
      );
    }

    // Auto-focus when keyboard tool is active
    if (state.currentTool == CanvasTool.text && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    } else if (state.currentTool != CanvasTool.text && _focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      });
    }

    // Construct TextDecorations
    final decorations = <TextDecoration>[];
    if (state.isUnderline) decorations.add(TextDecoration.underline);
    if (state.isStrikethrough) decorations.add(TextDecoration.lineThrough);

    final textStyle = TextStyle(
      fontSize: state.textFontSize,
      color: Color(state.textColor),
      fontWeight: state.isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: state.isItalic ? FontStyle.italic : FontStyle.normal,
      decoration: TextDecoration.combine(decorations),
      decorationColor: Color(state.textColor),
      height: 1.4,
    );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        maxLines: null,
        expands: true,
        textAlign: state.textAlign,
        style: textStyle,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        cursorColor: const Color(0xFF0D59F2),
        cursorWidth: 2.0,
      ),
    );
  }
}
