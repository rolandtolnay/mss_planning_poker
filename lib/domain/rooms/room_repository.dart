import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_participant_entity.dart';

import '../auth/user_entity.dart';
import '../domain_error.dart';
import 'models/room_entity.dart';
import 'models/room_model.dart';
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
}

@Collection<RoomModel>('rooms')
final _ref = RoomModelCollectionReference();

@LazySingleton(as: RoomRepository)
class FirRoomRepository implements RoomRepository {
  @override
  Future<Either<DomainError, RoomEntity>> createRoom(
      {required UserEntity admin}) async {
    if (admin.displayName == null) {
      const message = 'Room admin must have non-null display name.';
      return Left(DomainError.unexpected(message));
    }

    final doc = _ref.doc();
    final room = RoomEntity(
      id: doc.id,
      participants: [RoomParticipantEntity.fromUser(admin)],
    );
    try {
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
  }) {
    throw UnimplementedError();
  }
}
