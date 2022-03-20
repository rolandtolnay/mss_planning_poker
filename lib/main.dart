import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'injectable/injectable.dart';
import 'presentation/auth/auth_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final options = DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: options);

  configureDependencies();

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mss Planning Poker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWidget(),
    );
  }
}
