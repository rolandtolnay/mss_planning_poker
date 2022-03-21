import 'dart:collection';
import 'dart:math';

import 'package:mss_planning_poker/domain/rooms/models/room_participant_entity.dart';

class RoomEntity {
  final String id;
  final String name;
  final bool showingCards;

  final UnmodifiableListView<RoomParticipantEntity> participants;

  RoomEntity({
    required this.id,
    Set<RoomParticipantEntity> participants = const {},
    this.showingCards = false,
    String? name,
  })  : name = name ?? _makeName(),
        participants = UnmodifiableListView(participants);

  static String _makeName() {
    final random = Random();
    return '${1000 + random.nextInt(9000)}';
  }
}
