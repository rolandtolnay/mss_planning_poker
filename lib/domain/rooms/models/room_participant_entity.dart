import 'package:mss_planning_poker/domain/auth/user_entity.dart';

class RoomParticipantEntity {
  final String id;
  final String displayName;

  final String? selectedValue;
  final bool showingValue;

  RoomParticipantEntity({
    required this.id,
    required this.displayName,
    required this.selectedValue,
    required this.showingValue,
  });

  factory RoomParticipantEntity.fromUser(UserEntity user) {
    assert(user.displayName != null);
    return RoomParticipantEntity(
      id: user.id,
      displayName: user.displayName!,
      selectedValue: null,
      showingValue: false,
    );
  }
}
