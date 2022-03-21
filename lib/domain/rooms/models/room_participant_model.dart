import 'package:json_annotation/json_annotation.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_participant_entity.dart';

part 'room_participant_model.g.dart';

@JsonSerializable()
class RoomParticipantModel {
  final String userId;
  final String displayName;

  final String? selectedCard;

  RoomParticipantModel(
    this.userId,
    this.displayName,
    this.selectedCard,
  );

  factory RoomParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$RoomParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomParticipantModelToJson(this);

  factory RoomParticipantModel.fromEntity(RoomParticipantEntity entity) =>
      RoomParticipantModel(
        entity.userId,
        entity.displayName,
        entity.selectedCard,
      );

  RoomParticipantEntity get entity => RoomParticipantEntity(
        userId: userId,
        displayName: displayName,
        selectedCard: selectedCard,
      );

  RoomParticipantModel copyWith({String? selectedValue}) =>
      RoomParticipantModel(userId, displayName, selectedValue);
}

extension RoomParticipantEntityParsing on List<RoomParticipantEntity> {
  List<RoomParticipantModel> toModelList() =>
      map(RoomParticipantModel.fromEntity).toList();
}
