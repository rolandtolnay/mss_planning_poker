import 'package:json_annotation/json_annotation.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_participant_model.dart';

import 'room_entity.dart';

part 'room_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RoomModel {
  final String id;
  final String name;
  final DateTime lastUpdated;

  final bool showingValues;
  final List<RoomParticipantModel> participants;
  final List<String> participantIds;

  RoomModel(this.id, this.name, this.lastUpdated, this.showingValues,
      this.participants, this.participantIds);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromEntity(RoomEntity entity) => RoomModel(
        entity.id,
        entity.name,
        DateTime.now(),
        entity.showingValues,
        entity.participants.map(RoomParticipantModel.fromEntity).toList(),
        entity.participants.map((e) => e.id).toList(),
      );

  RoomEntity get entity => RoomEntity(
        id: id,
        name: name,
        participants: participants.map((e) => e.entity).toList(),
      );
}
