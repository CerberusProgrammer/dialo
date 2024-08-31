import 'package:flutter/material.dart';

class DialogueNodeComponent extends StatelessWidget {
  const DialogueNodeComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                  ],
                ),
                Text('This is a dialogue node.'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
