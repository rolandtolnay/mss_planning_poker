import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';

import '../domain_error.dart';
import '../fir_collection_reference.dart';
import 'models/room_participant_entity.dart';

abstract class ParticipantRepository {
  Stream<RoomParticipantEntity?> onParticipantChanged(
    String participantId, {
    required String roomId,
  });

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

@LazySingleton(as: ParticipantRepository)
class FirParticipantRepository implements ParticipantRepository {
  final FirCollectionReference _ref;

  FirParticipantRepository(this._ref);

  @override
  Stream<RoomParticipantEntity?> onParticipantChanged(
    String participantId, {
    required String roomId,
  }) =>
      _ref.participants(roomId).doc(participantId).snapshots().map((e) {
        if (e.data == null) return null;
        return e.data!.entity;
      });

  @override
  Future<DomainError?> leaveRoomWithId(
    String roomId, {
    required String participantId,
  }) async {
    try {
      final roomSnap = await _ref.rooms.doc(roomId).get();
      if (roomSnap.data == null) return DomainError.noData('No room found.');

      final pcpSnap = await _ref.participants(roomId).doc(participantId).get();
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
      final roomSnap = await _ref.rooms.doc(roomId).get();
      if (roomSnap.data == null) return DomainError.noData('No room found');

      final pcpSnap = await _ref.participants(roomId).doc(participantId).get();
      if (pcpSnap.data == null) return DomainError.noData('No user found');
      await pcpSnap.reference.update(selectedValue: value);

      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }
}
