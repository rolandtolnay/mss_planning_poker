import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

import '../auth/user_entity.dart';
import '../domain_error.dart';
import 'models/room_entity.dart';
import 'models/room_model.dart';
import 'models/room_participant_entity.dart';
import 'models/room_participant_model.dart';

part 'room_repository.g.dart';

abstract class RoomRepository {
  Future<Either<DomainError, RoomEntity>> createRoom({
    required UserEntity admin,
  });

  Future<Either<DomainError, RoomEntity>> joinRoom({
    required String roomName,
    required UserEntity participant,
  });

  Stream<RoomEntity?> onRoomUpdated({required String id});

  Future<RoomEntity?> findRoomForUserId(String userId);

  Future<DomainError?> leaveRoomWithId(
    String roomId, {
    required String participantId,
  });
}

@Collection<RoomModel>('rooms')
final _ref = RoomModelCollectionReference();

@LazySingleton(as: RoomRepository)
class FirRoomRepository implements RoomRepository {
  @override
  Future<Either<DomainError, RoomEntity>> createRoom(
      {required UserEntity admin}) async {
    try {
      _validateDisplayName(admin);

      final doc = _ref.doc();
      final room = RoomEntity(
        id: doc.id,
        participants: [RoomParticipantEntity.fromUser(admin)],
      );
      await doc.set(RoomModel.fromEntity(room));
      return Right(room);
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return Left(DomainError.unexpected('$e'));
    }
  }

  @override
  Future<Either<DomainError, RoomEntity>> joinRoom({
    required String roomName,
    required UserEntity participant,
  }) async {
    try {
      _validateDisplayName(participant);

      final snapshot = await _ref.whereName(isEqualTo: roomName).get();
      if (snapshot.docs.isEmpty) {
        return Left(DomainError.noData('No room found.'));
      }
      assert(snapshot.docs.length == 1);

      final room = snapshot.docs.first.data.entity;
      room.participants.add(RoomParticipantEntity.fromUser(participant));
      await _ref.doc(room.id).set(RoomModel.fromEntity(room));
      return Right(room);
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return Left(DomainError.unexpected('$e'));
    }
  }

  void _validateDisplayName(UserEntity user) {
    if (user.displayName == null) {
      throw Exception('Display name cannot be empty.');
    }
  }

  @override
  Stream<RoomEntity?> onRoomUpdated({required String id}) =>
      _ref.doc(id).snapshots().map((e) => e.data?.entity);

  @override
  Future<RoomEntity?> findRoomForUserId(String id) async {
    try {
      final snapshot =
          await _ref.whereParticipantIds(arrayContainsAny: [id]).get();
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data.entity;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return null;
    }
  }

  @override
  Future<DomainError?> leaveRoomWithId(
    String roomId, {
    required String participantId,
  }) async {
    try {
      final roomSnapshot = await _ref.doc(roomId).get();
      if (!roomSnapshot.exists) return null;
      final model = roomSnapshot.data!;
      model.participants.removeWhere((e) => e.id == participantId);
      model.participantIds.remove(participantId);
      if (model.participants.isEmpty) {
        await _ref.doc(roomId).delete();
      } else {
        await _ref.doc(roomId).set(model);
      }
      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }
}
