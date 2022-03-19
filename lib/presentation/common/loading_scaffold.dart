import 'package:flutter/material.dart';

class LoadingScaffold extends StatelessWidget {
  const LoadingScaffold({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
