import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/domain_error.dart';

import 'user_entity.dart';
import 'dart:developer' as dev;

abstract class AuthRepository {
  UserEntity? get currentUser;

  Stream<UserEntity?> get onAuthStateChanged;
  Stream<UserEntity?> get onUserChanged;

  Future<DomainError?> signInAnonymously();

  Future<DomainError?> updateDisplayName(String name);
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
  Future<DomainError?> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.authentication('$e');
    }
  }

  @override
  Future<DomainError?> updateDisplayName(String name) async {
    assert(_auth.currentUser != null);
    try {
      await _auth.currentUser?.updateDisplayName(name);
      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }
}
