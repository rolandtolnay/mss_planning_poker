import 'package:mss_planning_poker/domain/auth/user_entity.dart';
import 'package:equatable/equatable.dart';

class RoomParticipantEntity extends Equatable {
  final String userId;
  final String displayName;

  final String? selectedCard;

  const RoomParticipantEntity({
    required this.userId,
    required this.displayName,
    required this.selectedCard,
  });

  factory RoomParticipantEntity.fromUser(UserEntity user) {
    assert(user.displayName != null);
    return RoomParticipantEntity(
      userId: user.id,
      displayName: user.displayName!,
      selectedCard: null,
    );
  }

  @override
  List<Object?> get props => [userId];
}
