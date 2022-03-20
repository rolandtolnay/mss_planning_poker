import 'dart:developer' as dev;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_odm/cloud_firestore_odm.dart';
import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';
import 'package:stream_transform/stream_transform.dart';

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

  Future<DomainError?> setValue(
    String? value, {
    required String roomId,
    required String participantId,
  });
}

@Collection<RoomModel>('rooms')
@Collection<RoomParticipantModel>('rooms/*/participants')
final _roomsRef = RoomModelCollectionReference();

RoomParticipantModelCollectionReference _participantsRef(String roomId) =>
    _roomsRef.doc(roomId).participants;

@LazySingleton(as: RoomRepository)
class FirRoomRepository implements RoomRepository {
  @override
  Future<Either<DomainError, RoomEntity>> createRoom(
      {required UserEntity admin}) async {
    try {
      _validateDisplayName(admin);

      final doc = _roomsRef.doc();
      final pcp = RoomParticipantEntity.fromUser(admin);
      final room = RoomEntity(id: doc.id, participants: {pcp});
      await doc.set(RoomModel.fromEntity(room));
      _participantsRef(doc.id).doc(admin.id).set(
            RoomParticipantModel.fromEntity(pcp),
          );
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

      final roomSnap = await _roomsRef.whereName(isEqualTo: roomName).get();
      if (roomSnap.docs.isEmpty) {
        return Left(DomainError.noData('No room found.'));
      }
      assert(roomSnap.docs.length == 1);
      final roomDoc = roomSnap.docs.first;

      final pcpsSnap = await _participantsRef(roomDoc.id).get();
      final pcps = pcpsSnap.docs.map((e) => e.data);
      final pcpModel = participant.toRoomParticipantModel();
      await _participantsRef(roomDoc.id).doc(participant.id).set(pcpModel);

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
      _roomsRef.doc(id).snapshots().combineLatest(
        _participantsRef(id).snapshots(),
        (roomSnap, RoomParticipantModelQuerySnapshot pcpsSnap) {
          if (roomSnap.data == null) return null;
          final pcps = pcpsSnap.docs.map((e) => e.data);
          return roomSnap.data!.entity(participants: pcps);
        },
      );

  @override
  Future<RoomEntity?> findRoomForUserId(String id) async {
    try {
      final roomSnap =
          await _roomsRef.whereParticipantIds(arrayContainsAny: [id]).get();
      if (roomSnap.docs.isEmpty) return null;
      assert(roomSnap.docs.length == 1);
      final roomDoc = roomSnap.docs.first;

      final pcpsSnap = await _participantsRef(roomDoc.id).get();
      final pcps = pcpsSnap.docs.map((e) => e.data);
      return roomDoc.data.entity(participants: pcps);
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
      final roomSnap = await _roomsRef.doc(roomId).get();
      if (roomSnap.data == null) return DomainError.noData('No room found.');

      final pcpSnap = await _participantsRef(roomId).doc(participantId).get();
      if (!pcpSnap.exists) return null;

      await pcpSnap.reference.delete();
      final pcpIds = roomSnap.data!.participantIds;
      pcpIds.remove(participantId);

      if (pcpIds.isEmpty) {
        await roomSnap.reference.delete();
      } else {
        await roomSnap.reference.update(participantIds: pcpIds);
      }
      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }

  @override
  Future<DomainError?> setValue(
    String? value, {
    required String roomId,
    required String participantId,
  }) async {
    try {
      final roomSnap = await _roomsRef.doc(roomId).get();
      if (roomSnap.data == null) return DomainError.noData('No room found');

      final pcpSnap = await _participantsRef(roomId).doc(participantId).get();
      if (pcpSnap.data == null) return DomainError.noData('No user found');
      await pcpSnap.reference.update(selectedValue: value);

      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }

  void _validateDisplayName(UserEntity user) {
    if (user.displayName == null) {
      throw Exception('Display name cannot be empty.');
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
