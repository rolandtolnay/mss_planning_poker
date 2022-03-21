import 'dart:developer' as dev;

import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/rooms/models/poker_card.dart';

import '../domain_error.dart';
import '../fir_collection_reference.dart';
import 'models/room_participant_entity.dart';

abstract class ParticipantRepository {
  Stream<RoomParticipantEntity?> onParticipantChanged(
    String userId, {
    required String roomId,
  });

  Future<DomainError?> leaveRoomWithId(
    String roomId, {
    required String userId,
  });

  Future<DomainError?> selectCard(
    PokerCard? value, {
    required String roomId,
    required String userId,
  });
}

@LazySingleton(as: ParticipantRepository)
class FirParticipantRepository implements ParticipantRepository {
  final FirCollectionReference _ref;

  FirParticipantRepository(this._ref);

  @override
  Stream<RoomParticipantEntity?> onParticipantChanged(
    String userId, {
    required String roomId,
  }) =>
      _ref.participants(roomId).doc(userId).snapshots().map((e) {
        if (e.data == null) return null;
        return e.data!.entity;
      });

  @override
  Future<DomainError?> leaveRoomWithId(
    String roomId, {
    required String userId,
  }) async {
    try {
      final roomSnap = await _ref.rooms.doc(roomId).get();
      if (roomSnap.data == null) return DomainError.noData('No room found.');

      final pcpSnap = await _ref.participants(roomId).doc(userId).get();
      if (!pcpSnap.exists) return null;

      await pcpSnap.reference.delete();
      final pcpIds = roomSnap.data!.participantIds;
      pcpIds.remove(userId);

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
  Future<DomainError?> selectCard(
    PokerCard? value, {
    required String roomId,
    required String userId,
  }) async {
    try {
      final roomSnap = await _ref.rooms.doc(roomId).get();
      if (roomSnap.data == null) return DomainError.noData('No room found');

      final pcpSnap = await _ref.participants(roomId).doc(userId).get();
      if (pcpSnap.data == null) return DomainError.noData('No user found');
      await pcpSnap.reference.update(selectedCard: value);

      return null;
    } catch (e, st) {
      dev.log('[ERROR] ${e.toString()}', error: e, stackTrace: st);
      return DomainError.unexpected('$e');
    }
  }
}
