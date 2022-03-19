import 'package:json_annotation/json_annotation.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_participant_entity.dart';

part 'room_participant_model.g.dart';

@JsonSerializable()
class RoomParticipantModel {
  final String id;
  final String displayName;

  final String? selectedValue;

  RoomParticipantModel(
    this.id,
    this.displayName,
    this.selectedValue,
  );

  factory RoomParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$RoomParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomParticipantModelToJson(this);

  factory RoomParticipantModel.fromEntity(RoomParticipantEntity entity) =>
      RoomParticipantModel(
        entity.id,
        entity.displayName,
        entity.selectedValue,
      );

  RoomParticipantEntity get entity => RoomParticipantEntity(
        id: id,
        displayName: displayName,
        selectedValue: selectedValue,
      );

  RoomParticipantModel copyWith({String? selectedValue}) =>
      RoomParticipantModel(id, displayName, selectedValue);
}
