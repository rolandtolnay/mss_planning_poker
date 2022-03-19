import 'package:json_annotation/json_annotation.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_participant_model.dart';

import 'room_entity.dart';

part 'room_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RoomModel {
  final String id;
  final String name;
  final DateTime lastUpdated;

  final List<RoomParticipantModel> participants;

  RoomModel(this.id, this.name, this.lastUpdated, this.participants);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromEntity(RoomEntity entity) => RoomModel(
        entity.id,
        entity.name,
        DateTime.now(),
        entity.participants.map(RoomParticipantModel.fromEntity).toList(),
      );
}
