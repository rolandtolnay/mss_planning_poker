import 'package:flutter/material.dart';

class LoadableWidget extends StatelessWidget {
  final bool loading;
  final Widget child;

  final Color? indicatorColor;

  const LoadableWidget({
    Key? key,
    required this.loading,
    required this.child,
    this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !loading,
      replacement: Center(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircularProgressIndicator(color: indicatorColor),
        ),
      ),
      child: child,
    );
  }
}
