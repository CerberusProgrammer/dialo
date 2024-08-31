import 'package:flutter/material.dart';

class DialogueNodeComponent extends StatelessWidget {
  final VoidCallback onTap;
  final bool isFocused;

  const DialogueNodeComponent({
    super.key,
    required this.onTap,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused ? Colors.black : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 1,
                spreadRadius: 0.1,
                offset: const Offset(2, 3),
              ),
            ]),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  child: Icon(Icons.person),
                ),
                SizedBox(width: 20),
                Text(
                  'This is a dialogue node',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
