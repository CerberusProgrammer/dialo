import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InfiniteCanvas(),
    );
  }
}

class InfiniteCanvas extends StatefulWidget {
  @override
  _InfiniteCanvasState createState() => _InfiniteCanvasState();
}

class _InfiniteCanvasState extends State<InfiniteCanvas> {
  List<Widget> squares = [];
  ScrollController _horizontalController = ScrollController();
  ScrollController _verticalController = ScrollController();
  double _currentX = 5000;
  double _currentY = 5000;

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
      ));
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
                children: squares,
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

  MovableSquare({Key? key, required this.initialPosition}) : super(key: key);

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
    return Positioned(
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
        ),
      ),
    );
  }
}
