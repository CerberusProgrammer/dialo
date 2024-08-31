import 'package:dialo/components/dialogue_node.component.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: InteractiveViewerWidget(),
        ),
      ),
    );
  }
}

class InteractiveViewerWidget extends StatefulWidget {
  const InteractiveViewerWidget({super.key});

  @override
  _InteractiveViewerWidgetState createState() =>
      _InteractiveViewerWidgetState();
}

class _InteractiveViewerWidgetState extends State<InteractiveViewerWidget> {
  final TransformationController _transformationController =
      TransformationController();
  final FocusNode _focusNode = FocusNode();
  final List<DialogueNodeComponent> _nodes = [];
  final List<Offset> _positions = [];
  int? _focusedIndex;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _focusNode.addListener(_onFocusChange);
    _addNode(const Offset(200, 200));
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _focusNode.removeListener(_onFocusChange);
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {}

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    setState(() {});
  }

  void _onInteractionEnd(ScaleEndDetails details) {}

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      setState(() {
        _focusedIndex = null;
      });
    }
  }

  void _handleTap(int index) {
    setState(() {
      _focusedIndex = index;
    });
  }

  void _handleOutsideTap() {
    if (_focusedIndex != null) {
      setState(() {
        _focusedIndex = null;
      });
    }
  }

  void _addNode(Offset position) {
    setState(() {
      _positions.add(position);
      _nodes.add(
        DialogueNodeComponent(
          onTap: () => _handleTap(_nodes.length),
          onAdd: () => _addNode(position + const Offset(0, 150)),
          isFocused: false,
          position: position,
          onDrag: (newPosition) =>
              _updatePosition(_nodes.length - 1, newPosition),
        ),
      );
    });
  }

  void _updatePosition(int index, Offset delta) {
    setState(() {
      _positions[index] += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleOutsideTap,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: InteractiveViewer(
          constrained: false,
          boundaryMargin: const EdgeInsets.all(0),
          minScale: 0.1,
          maxScale: 5.0,
          transformationController: _transformationController,
          onInteractionUpdate: _onInteractionUpdate,
          onInteractionEnd: _onInteractionEnd,
          child: SizedBox(
            width: 5000,
            height: 5000,
            child: Stack(
              children: _nodes.asMap().entries.map((entry) {
                int index = entry.key;
                Offset position = _positions[index];
                return Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    onTap: () {
                      _handleTap(index);
                      _focusNode.requestFocus();
                    },
                    child: DialogueNodeComponent(
                      onTap: () => _handleTap(index),
                      onAdd: () => _addNode(position + const Offset(0, 150)),
                      isFocused: _focusedIndex == index,
                      position: position,
                      onDrag: (newPosition) =>
                          _updatePosition(index, newPosition),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
