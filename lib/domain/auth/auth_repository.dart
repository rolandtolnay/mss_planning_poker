import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get onUserChanged;

  Future<void> signInAnonymously();

  Future<void> updateDisplayName(String name);
}

@LazySingleton(as: AuthRepository)
class FirAuthRepository implements AuthRepository {
  final _auth = FirebaseAuth.instance;

  @override
  Stream<UserEntity?> get onUserChanged {
    return _auth.userChanges().map((user) {
      if (user == null) return null;
      return UserEntity(id: user.uid, displayName: user.displayName);
    });
  }

  @override
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    assert(_auth.currentUser != null);

    await _auth.currentUser?.updateDisplayName(name);
  }
}
