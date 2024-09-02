import 'package:flutter/material.dart';

class MovableSquare extends StatefulWidget {
  final int id;
  Offset initialPosition;
  final MovableSquare? movableSquareFather;
  final List<MovableSquare>? movableSquareChildren;
  final Function(Offset) onDrawStart;
  final Function(Offset) onDrawUpdate;
  final Function() onDrawEnd;
  final List<MovableSquare> connections = [];

  MovableSquare({
    super.key,
    required this.initialPosition,
    required this.onDrawStart,
    required this.onDrawUpdate,
    required this.onDrawEnd,
    required this.id,
    this.movableSquareFather,
    this.movableSquareChildren,
  });
  @override
  State<MovableSquare> createState() => _MovableSquareState();
}

class _MovableSquareState extends State<MovableSquare> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  position += details.delta;
                });
                widget.initialPosition = position;
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.green,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Square ${widget.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${position.dx.toStringAsFixed(2)}, ${position.dy.toStringAsFixed(2)})',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Father: ${widget.connections.map((connection) => connection.id) ?? 'None'}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: position.dx + 100,
            top: position.dy + 40,
            child: GestureDetector(
              onPanStart: (details) =>
                  widget.onDrawStart(position + const Offset(100, 40)),
              onPanUpdate: (details) => widget.onDrawUpdate(position +
                  Offset(100 + details.localPosition.dx,
                      40 + details.localPosition.dy)),
              onPanEnd: (details) {
                setState(() {});
                widget.onDrawEnd();
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      );
}
