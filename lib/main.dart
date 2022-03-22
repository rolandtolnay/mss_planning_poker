import 'package:firebase_core/firebase_core.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final flexSchemeColor = FlexSchemeColor.from(
      primary: Color(0xff0075c5),
      secondary: Color(0xffE57C4A),
      primaryVariant: Color(0xff005792),
      secondaryVariant: Color(0xff0094f8),
    );
    return MaterialApp(
      title: 'Scrum Planning Poker',
      theme: FlexThemeData.light(
        colors: flexSchemeColor,
        textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: FlexThemeData.dark(
        colors: flexSchemeColor,
        textTheme: GoogleFonts.ubuntuTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.dark,
      home: const AuthWidget(),
    );
  }
}
