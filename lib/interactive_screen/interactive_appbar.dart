import 'package:flutter/material.dart';

class InteractiveAppbar extends StatelessWidget {
  const InteractiveAppbar(
      {super.key,
      required this.currentX,
      required this.currentY,
      required this.addSquare});

  final double currentX;
  final double currentY;
  final void Function() addSquare;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              Text('Position: ${currentX.toInt()}px x ${currentY.toInt()}px'),
              IconButton(
                  icon: const Icon(Icons.add, size: 10), onPressed: addSquare),
            ],
          )
        ],
      );
}
