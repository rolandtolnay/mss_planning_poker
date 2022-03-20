import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/auth/auth_repository.dart';

import '../../injectable/injectable.dart';

final displayNameProvider = StateNotifierProvider<DisplayNameProvider, String?>(
  (ref) => getIt<DisplayNameProvider>(),
);

@Injectable()
class DisplayNameProvider extends StateNotifier<String?> {
  final AuthRepository _repository;
  late final StreamSubscription _listener;

  DisplayNameProvider(this._repository)
      : super(_repository.currentUser?.displayName) {
    _listener = _repository.onUserChanged.listen((user) {
      if (user == null) return;
      if (user.displayName != state) state = user.displayName;
    });
  }

  Future<void> updateDisplayName(String name) =>
      _repository.updateDisplayName(name);

  @override
  void dispose() {
    _listener.cancel();
    super.dispose();
  }
}
