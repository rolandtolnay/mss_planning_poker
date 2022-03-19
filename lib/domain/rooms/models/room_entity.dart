import 'package:mss_planning_poker/domain/rooms/models/room_participant_entity.dart';

class RoomEntity {
  final String id;
  final String name;

  final List<RoomParticipantEntity> participants;

  RoomEntity({
    required this.id,
    required this.name,
    required this.participants,
  });
}
