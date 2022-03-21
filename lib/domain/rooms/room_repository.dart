import 'dart:developer' as dev;

import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

import '../auth/user_entity.dart';
import '../domain_error.dart';
import '../fir_collection_reference.dart';
import 'models/room_entity.dart';
import 'models/room_model.dart';
import 'models/room_participant_entity.dart';
import 'models/room_participant_model.dart';

abstract class RoomRepository {
  Stream<RoomEntity?> onRoomUpdated({required String id});

  Future<Either<DomainError, RoomEntity>> createRoom({
    required UserEntity admin,
  });

  Future<Either<DomainError, RoomEntity>> joinRoomNamed(
    String roomName, {
    required UserEntity participant,
  });

  Future<Either<DomainError, RoomEntity?>> findRoomForUserId(String userId);

  Future<DomainError?> showCards(bool showingCards, {required String roomId});
}

@LazySingleton(as: RoomRepository)
class FirRoomRepository implements RoomRepository {
  final FirCollectionReference _ref;

  FirRoomRepository(this._ref);

  @override
  Future<Either<DomainError, RoomEntity>> createRoom(
      {required UserEntity admin}) async {
    try {
      _validateDisplayName(admin);

      final doc = _ref.rooms.doc();
      final pcp = RoomParticipantEntity.fromUser(admin);
      final room = RoomEntity(id: doc.id, participants: {pcp});
      await doc.set(RoomModel.fromEntity(room));
      _ref.participants(doc.id).doc(admin.id).set(
            RoomParticipantModel.fromEntity(pcp),
          );
      return Right(room);
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return Left(DomainError.unexpected('$e'));
    }
  }

  @override
  Future<Either<DomainError, RoomEntity>> joinRoomNamed(
    String roomName, {
    required UserEntity participant,
  }) async {
    try {
      _validateDisplayName(participant);

      final roomSnap = await _ref.rooms.whereName(isEqualTo: roomName).get();
      if (roomSnap.docs.isEmpty) {
        return Left(DomainError.noData('No room found.'));
      }
      assert(roomSnap.docs.length == 1);
      final roomDoc = roomSnap.docs.first;

      final pcpsSnap = await _ref.participants(roomDoc.id).get();
      final pcps = pcpsSnap.docs.map((e) => e.data);
      final pcpModel = participant.toRoomParticipantModel();
      await _ref.participants(roomDoc.id).doc(participant.id).set(pcpModel);

      final room = roomDoc.data.entity(
        participants: pcps.followedBy([pcpModel]),
      );
      await roomDoc.reference.update(participantIds: room.participantIds);

      return Right(room);
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return Left(DomainError.unexpected('$e'));
    }
  }

  @override
  Stream<RoomEntity?> onRoomUpdated({required String id}) =>
      _ref.rooms.doc(id).snapshots().combineLatest(
        _ref.participants(id).snapshots(),
        (roomSnap, RoomParticipantModelQuerySnapshot pcpsSnap) {
          if (roomSnap.data == null) return null;
          final pcps = pcpsSnap.docs.map((e) => e.data);
          return roomSnap.data!.entity(participants: pcps);
        },
      );

  @override
  Future<Either<DomainError, RoomEntity?>> findRoomForUserId(String id) async {
    try {
      final roomSnap =
          await _ref.rooms.whereParticipantIds(arrayContainsAny: [id]).get();
      if (roomSnap.docs.isEmpty) return Right(null);
      assert(roomSnap.docs.length == 1);
      final roomDoc = roomSnap.docs.first;

      final pcpsSnap = await _ref.participants(roomDoc.id).get();
      final pcps = pcpsSnap.docs.map((e) => e.data);
      return Right(roomDoc.data.entity(participants: pcps));
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
  Future<DomainError?> showCards(
    bool showingCards, {
    required String roomId,
  }) async {
    try {
      await _ref.rooms.doc(roomId).update(showingCards: showingCards);
      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }
}

extension on UserEntity {
  RoomParticipantModel toRoomParticipantModel() =>
      RoomParticipantModel.fromEntity(RoomParticipantEntity.fromUser(this));
}

extension on RoomEntity {
  List<String> get participantIds => participants.map((e) => e.userId).toList();
}
