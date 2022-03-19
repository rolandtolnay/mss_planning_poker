import 'package:flutter/material.dart';

import '../domain/auth/auth_repository.dart';
import '../domain/auth/user_entity.dart';
import '../injectable/injectable.dart';
import 'common/loading_scaffold.dart';
import 'home/home_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  final _authRepository = getIt<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _authRepository.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserEntity?>(
      stream: _authRepository.onAuthStateChanged,
      builder: (_, snapshot) {
        if (!snapshot.hasData) return LoadingScaffold();
        return HomePage(userId: snapshot.data!.id);
      },
    );
  }
}
