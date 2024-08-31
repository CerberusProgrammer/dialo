import 'package:flutter/material.dart';

class InteractivePanel extends StatefulWidget {
  const InteractivePanel({super.key});

  @override
  State<InteractivePanel> createState() => _InteractivePanelState();
}

class _InteractivePanelState extends State<InteractivePanel> {
  final TransformationController _transformationController =
      TransformationController();
  final FocusNode _focusNode = FocusNode();
  final List<Offset> _positions = [];
  final List<MapEntry<int, int>> _connections = [];
  int? _focusedIndex;
  List<Offset> _dragPoints = [];
  int? _dragStartNodeIndex;

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
    setState(() {
      if (_dragPoints.isNotEmpty) {
        _dragPoints
            .add(_transformationController.toScene(details.localFocalPoint));
      }
    });
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_dragStartNodeIndex != null && _dragPoints.isNotEmpty) {
      for (int i = 0; i < _positions.length; i++) {
        if (i != _dragStartNodeIndex &&
            _isPointInsideNode(_dragPoints.last, _positions[i])) {
          _connections.add(MapEntry(_dragStartNodeIndex!, i));
          break;
        }
      }
    }
    setState(() {
      _dragPoints.clear();
      _dragStartNodeIndex = null;
    });
  }

  bool _isPointInsideNode(Offset point, Offset nodePosition) {
    return point.dx >= nodePosition.dx &&
        point.dx <= nodePosition.dx + 200 &&
        point.dy >= nodePosition.dy &&
        point.dy <= nodePosition.dy + 100;
  }

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

  void _addNode(Offset position, [int? parentIndex]) {
    setState(() {
      _positions.add(position);
      if (parentIndex != null) {
        _connections.add(MapEntry(parentIndex, _positions.length - 1));
      }
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
          minScale: 0.5,
          maxScale: 1.0,
          transformationController: _transformationController,
          onInteractionUpdate: _onInteractionUpdate,
          onInteractionEnd: _onInteractionEnd,
          child: SizedBox(
            width: 5000,
            height: 5000,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(2000, 2000),
                  painter: ConnectionPainter(_positions, _connections,
                      nodeWidth: 200, nodeHeight: 100),
                ),
                if (_dragPoints.isNotEmpty)
                  CustomPaint(
                    size: const Size(2000, 2000),
                    painter: _InProgressConnectionPainter(_dragPoints),
                  ),
                ..._positions.asMap().entries.map((entry) {
                  int index = entry.key;
                  Offset position = entry.value;
                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Row(
                      children: [
                        GestureDetector(
                          onPanStart: (details) {
                            setState(() {
                              _dragPoints = [
                                _transformationController
                                    .toScene(details.localPosition + position)
                              ];
                              _dragStartNodeIndex = index;
                            });
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _dragPoints.add(_transformationController
                                  .toScene(details.localPosition + position));
                            });
                          },
                          onPanEnd: (details) {
                            _onInteractionEnd(ScaleEndDetails());
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        DialogueNodeComponent(
                          onTap: () => _handleTap(index),
                          onAdd: () =>
                              _addNode(position + const Offset(0, 150), index),
                          isFocused: _focusedIndex == index,
                          position: position,
                          onDrag: (newPosition) {
                            _updatePosition(index, newPosition);
                            _updateDragPoints(index);
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateDragPoints(int index) {
    if (_dragStartNodeIndex == index && _dragPoints.isNotEmpty) {
      setState(() {
        _dragPoints = [_positions[index]];
      });
    }
  }
}

class _InProgressConnectionPainter extends CustomPainter {
  final List<Offset> points;

  _InProgressConnectionPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ConnectionPainter extends CustomPainter {
  final List<Offset> positions;
  final List<MapEntry<int, int>> connections;
  final double nodeWidth;
  final double nodeHeight;

  ConnectionPainter(this.positions, this.connections,
      {required this.nodeWidth, required this.nodeHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var connection in connections) {
      final start =
          positions[connection.key] + Offset(nodeWidth / 2, nodeHeight / 2);
      final end =
          positions[connection.value] + Offset(nodeWidth / 2, nodeHeight / 2);
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DialogueNodeComponent extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final bool isFocused;
  final Offset position;
  final ValueChanged<Offset> onDrag;

  const DialogueNodeComponent({
    required this.onTap,
    required this.onAdd,
    required this.isFocused,
    required this.position,
    required this.onDrag,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (details) {
        onDrag(details.delta);
      },
      child: Container(
        width: 200,
        height: 100,
        decoration: BoxDecoration(
          color: isFocused ? Colors.yellow : Colors.grey,
          border: Border.all(color: Colors.black),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Node'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
