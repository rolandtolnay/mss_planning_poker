import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/auth/auth_repository.dart';
import 'package:mss_planning_poker/domain/auth/user_entity.dart';

import '../../injectable/injectable.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserEntity?>(
  (ref) => getIt<UserNotifier>(),
);

@Injectable()
class UserNotifier extends StateNotifier<UserEntity?> {
  final AuthRepository _repository;
  late final StreamSubscription _listener;

  UserNotifier(this._repository) : super(null) {
    _listener = _repository.onAuthStateChanged.listen((user) {
      state = user;
    });
  }

  Future<void> signInAnonymously() => _repository.signInAnonymously();

  Future<void> updateDisplayName(String name) async {
    await _repository.updateDisplayName(name);
    state = _repository.currentUser;
  }

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }
}
