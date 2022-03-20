import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import '../../injectable/injectable.dart';
import 'user_entity.dart';

final authRepository = getIt<AuthRepository>();

abstract class AuthRepository {
  UserEntity? get currentUser;

  Stream<UserEntity?> get onAuthStateChanged;

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
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    assert(_auth.currentUser != null);

    await _auth.currentUser?.updateDisplayName(name);
  }
}
