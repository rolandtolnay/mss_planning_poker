import 'dart:math';

import 'package:mss_planning_poker/domain/rooms/models/room_participant_entity.dart';

class RoomEntity {
  final String id;
  final String name;

  final List<RoomParticipantEntity> participants;

  RoomEntity({
    required this.id,
    required this.participants,
    String? name,
  }) : name = name ?? _makeName();

  static String _makeName() {
    final random = Random();
    return '${1000 + random.nextInt(9000)}';
  }
}
