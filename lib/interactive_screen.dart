import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(context) => MaterialApp(home: InfiniteCanvas());
}

class InfiniteCanvas extends StatefulWidget {
  @override
  _InfiniteCanvasState createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  List<Widget> squares = [];
  ScrollController _horizontalController = ScrollController();
  ScrollController _verticalController = ScrollController();
  double _currentX = 0;
  double _currentY = 0;
  List<Offset> points = [];

  @override
  void initState() {
    super.initState();
    _horizontalController.addListener(_updatePosition);
    _verticalController.addListener(_updatePosition);
  }

  void _updatePosition() {
    setState(() {
      _currentX = _horizontalController.offset;
      _currentY = _verticalController.offset;
    });
  }

  void _addSquare() {
    setState(() {
      squares.add(MovableSquare(
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
  }

  void _startDrawing(Offset position) {
    setState(() {
      points = [position];
    });
  }

  void _updateDrawing(Offset position) {
    setState(() {
      points.add(position);
    });
  }

  void _stopDrawing() {
    setState(() {
      points.clear();
    });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Figma Clone - Position: ${_currentX.toInt()}px x ${_currentY.toInt()}px'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addSquare,
          ),
        ],
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
            child: Container(
              width: 10000,
              height: 10000,
              child: Stack(
                children: [
                  CustomPaint(
                    size: Size(10000, 10000),
                    painter: LinePainter(points),
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
}

class MovableSquare extends StatefulWidget {
  final Offset initialPosition;
  final Function(Offset) onDrawStart;
  final Function(Offset) onDrawUpdate;
  final Function() onDrawEnd;

  MovableSquare({
    Key? key,
    required this.initialPosition,
    required this.onDrawStart,
    required this.onDrawUpdate,
    required this.onDrawEnd,
  }) : super(key: key);

  @override
  _MovableSquareState createState() => _MovableSquareState();
}

class _MovableSquareState extends State<MovableSquare> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                position += details.delta;
              });
            },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: Center(
                child: Text(
                  '(${position.dx.toStringAsFixed(2)}, ${position.dy.toStringAsFixed(2)})',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: position.dx + 100,
          top: position.dy + 40,
          child: GestureDetector(
            onPanStart: (details) =>
                widget.onDrawStart(position + Offset(100, 40)),
            onPanUpdate: (details) => widget.onDrawUpdate(position +
                Offset(100 + details.localPosition.dx,
                    40 + details.localPosition.dy)),
            onPanEnd: (details) => widget.onDrawEnd(),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LinePainter extends CustomPainter {
  final List<Offset> points;

  LinePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
