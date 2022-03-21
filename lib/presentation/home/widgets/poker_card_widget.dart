import 'package:flutter/material.dart';

import '../../../domain/rooms/models/poker_card.dart';

class PokerCardWidget extends StatelessWidget {
  final PokerCard card;
  final ValueChanged<PokerCard> onTapped;
  final bool highlighted;

  const PokerCardWidget({
    required this.card,
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
          card,
          style: textTheme.subtitle1?.copyWith(color: colorScheme.onSecondary),
        ),
        onPressed: () => onTapped(card),
      ),
    );
  }
}
