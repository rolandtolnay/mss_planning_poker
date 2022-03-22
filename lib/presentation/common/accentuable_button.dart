// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AccentuableButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool hasAccent;
  final String label;
  final IconData icon;

  const AccentuableButton({
    Key? key,
    required this.label,
    required this.icon,
    this.onPressed,
    this.hasAccent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final side = hasAccent
        ? BorderSide(width: 2.0, color: colorScheme.primaryVariant)
        : null;
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: side,
        fixedSize: Size.fromHeight(44),
        primary: colorScheme.secondaryVariant,
      ),
      label: Text(label),
      icon: Icon(icon),
    );
  }
}
