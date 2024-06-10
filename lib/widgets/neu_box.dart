import 'package:flutter/material.dart';

class NeuBox extends StatelessWidget {
  final Widget? child;

  const NeuBox({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            // darker shadow on bottom right
            BoxShadow(
              color: Colors.black,
              blurRadius: 15,
              offset: Offset(4, 4),
            ),
            // lighter shadow on top left
            BoxShadow(
              color: Colors.black,
              blurRadius: 15,
              offset: Offset(-4, -4),
            ),
          ]),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
