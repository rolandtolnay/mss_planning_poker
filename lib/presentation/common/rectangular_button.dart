import 'package:flutter/material.dart';

class RectangularButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool enabled;

  const RectangularButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: Text(title),
    );
  }
}
