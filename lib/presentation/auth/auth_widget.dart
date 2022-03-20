import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/loading_scaffold.dart';
import '../home/home_page.dart';
import 'auth_provider.dart';

class AuthWidget extends ConsumerStatefulWidget {
  const AuthWidget({Key? key}) : super(key: key);

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends ConsumerState<AuthWidget> {
  @override
  void initState() {
    super.initState();
    ref.read(authProvider.notifier).signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    if (user == null) return LoadingScaffold();
    return HomePage(userId: user.id);
  }
}
