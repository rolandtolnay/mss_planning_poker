import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'user_entity.dart';

abstract class AuthRepository {
  UserEntity? get currentUser;

  Stream<UserEntity?> get onAuthStateChanged;
  Stream<UserEntity?> get onUserChanged;

  Future<void> signInAnonymously();

  Future<void> updateDisplayName(String name);
}

@LazySingleton(as: AuthRepository)
class FirAuthRepository implements AuthRepository {
  final _auth = FirebaseAuth.instance;

  @override
  UserEntity? get currentUser {
    final firUser = _auth.currentUser;
    if (firUser == null) return null;
    return UserEntity(id: firUser.uid, displayName: firUser.displayName);
  }

  @override
  Stream<UserEntity?> get onAuthStateChanged {
    return _auth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserEntity(id: user.uid, displayName: user.displayName);
    });
  }

  @override
  Stream<UserEntity?> get onUserChanged {
    return _auth.userChanges().map((user) {
      if (user == null) return null;
      return UserEntity(id: user.uid, displayName: user.displayName);
    });
  }

  @override
  Future<void> signInAnonymously() async {
    // TODO: Add error handling
    await _auth.signInAnonymously();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    assert(_auth.currentUser != null);
    // TODO: Add error handling
    await _auth.currentUser?.updateDisplayName(name);
  }
}
