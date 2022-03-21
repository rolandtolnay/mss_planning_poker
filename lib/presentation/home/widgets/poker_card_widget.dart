import 'package:flutter/material.dart';

class PokerCardWidget extends StatelessWidget {
  final String value;
  final ValueChanged<String> onTapped;
  final bool highlighted;

  const PokerCardWidget({
    required this.value,
    required this.onTapped,
    this.highlighted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 80,
      width: 56,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (_) => highlighted ? colorScheme.error : colorScheme.secondary,
          ),
        ),
        child: Text(
          value,
          style: textTheme.subtitle1?.copyWith(color: colorScheme.onSecondary),
        ),
        onPressed: () => onTapped(value),
      ),
    );
  }
}
