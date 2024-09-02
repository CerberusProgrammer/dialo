import 'package:dialo/interactive_screen/interactive_appbar.dart';
import 'package:dialo/interactive_screen/movable_square.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) => const MaterialApp(home: InfiniteCanvas());
}

class InfiniteCanvas extends StatefulWidget {
  const InfiniteCanvas({super.key});

  @override
  State<InfiniteCanvas> createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  List<MovableSquare> squares = [];
  final ScrollController _horizontalController = ScrollController();
  final ScrollController _verticalController = ScrollController();
  double _currentX = 0;
  double _currentY = 0;
  List<Offset> points = [];

  @override
  void initState() {
    super.initState();
    _horizontalController.addListener(_updatePosition);
    _verticalController.addListener(_updatePosition);
  }

  void _updatePosition() => setState(() {
        _currentX = _horizontalController.offset;
        _currentY = _verticalController.offset;
      });

  void _addSquare() => setState(() {
        squares.add(MovableSquare(
          id: squares.length,
          key: UniqueKey(),
          initialPosition: Offset(
            _currentX + MediaQuery.of(context).size.width / 2,
            _currentY + MediaQuery.of(context).size.height / 2,
          ),
          onDrawStart: _startDrawing,
          onDrawUpdate: _updateDrawing,
          onDrawEnd: _stopDrawing,
        ));
      });

  void _startDrawing(Offset position) => setState(() => points = [position]);

  void _updateDrawing(Offset position) => setState(() => points.add(position));

  void _stopDrawing() {
    setState(() {
      if (points.length > 1) {
        Offset start = points.first;
        Offset end = points.last;

        MovableSquare? startSquare;
        MovableSquare? endSquare;

        for (var square in squares) {
          if (_isPointInsideSquare(start, square)) {
            startSquare = square;
          }
          if (_isPointInsideSquare(end, square)) {
            endSquare = square;
          }
        }

        if (startSquare != null &&
            endSquare != null &&
            startSquare != endSquare) {
          startSquare.connections.add(endSquare);
          endSquare.connections.add(startSquare);
        }
      }
      points.clear();
    });
  }

  bool _isPointInsideSquare(Offset point, MovableSquare square) {
    return point.dx >= square.initialPosition.dx &&
        point.dx <= square.initialPosition.dx + 100 &&
        point.dy >= square.initialPosition.dy &&
        point.dy <= square.initialPosition.dy + 100;
  }

  @override
  void dispose() {
    _horizontalController.removeListener(_updatePosition);
    _verticalController.removeListener(_updatePosition);
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(100, 100),
          child: InteractiveAppbar(
            currentX: _currentX,
            currentY: _currentY,
            addSquare: _addSquare,
          ),
        ),
        body: GestureDetector(
          onPanUpdate: (details) {
            _horizontalController
                .jumpTo(_horizontalController.offset - details.delta.dx);
            _verticalController
                .jumpTo(_verticalController.offset - details.delta.dy);
          },
          child: SingleChildScrollView(
            controller: _horizontalController,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _verticalController,
              scrollDirection: Axis.vertical,
              child: SizedBox(
                width: 10000,
                height: 10000,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: const Size(10000, 10000),
                      painter: LinePainter(points, squares),
                    ),
                    ...squares,
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

class LinePainter extends CustomPainter {
  final List<Offset> points;
  final List<MovableSquare> squares;

  LinePainter(this.points, this.squares);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }

    for (var square in squares) {
      for (var connection in square.connections) {
        canvas.drawLine(
          square.initialPosition + Offset(50, 50),
          connection.initialPosition + Offset(50, 50),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
