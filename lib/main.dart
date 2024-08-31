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
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
    _focusNode.addListener(_onFocusChange);
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
        _isFocused = false;
      });
    }
  }

  void _handleTap() {
    setState(() {
      _isFocused = true;
    });
  }

  void _handleOutsideTap() {
    if (_isFocused) {
      setState(() {
        _isFocused = false;
      });
    }
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
          boundaryMargin: const EdgeInsets.all(double.infinity),
          minScale: 0.1,
          maxScale: 5.0,
          transformationController: _transformationController,
          onInteractionUpdate: _onInteractionUpdate,
          onInteractionEnd: _onInteractionEnd,
          child: SizedBox(
            width: 2000,
            height: 2000,
            child: Stack(
              children: [
                Positioned(
                  left: 200,
                  top: 200,
                  child: GestureDetector(
                    onTap: () {
                      _handleTap();
                      _focusNode.requestFocus();
                    },
                    child: DialogueNodeComponent(
                      onTap: _handleTap,
                      isFocused: _isFocused,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
