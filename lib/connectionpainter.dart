import 'package:flutter/material.dart';

class ConnectionPainter extends CustomPainter {
  final List<Offset> positions;
  final List<MapEntry<int, int>> connections;
  final double nodeWidth;
  final double nodeHeight;

  ConnectionPainter(this.positions, this.connections,
      {this.nodeWidth = 200, this.nodeHeight = 100});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var connection in connections) {
      final start = positions[connection.key];
      final end = positions[connection.value];

      final startPoint = _getCenterPoint(start);
      final endPoint = _getCenterPoint(end);

      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  Offset _getCenterPoint(Offset position) {
    return Offset(
      position.dx + nodeWidth / 2,
      position.dy + nodeHeight / 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
