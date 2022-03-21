import 'package:json_annotation/json_annotation.dart';

import 'room_entity.dart';
import 'room_participant_model.dart';

part 'room_model.g.dart';

@JsonSerializable(explicitToJson: true)
class RoomModel {
  final String id;
  final String name;

  final bool showingCards;
  final List<String> participantIds;

  RoomModel(this.id, this.name, this.showingCards, this.participantIds);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);

  factory RoomModel.fromEntity(RoomEntity entity) => RoomModel(
        entity.id,
        entity.name,
        entity.showingCards,
        entity.participants.map((e) => e.userId).toList(),
      );

  RoomEntity entity({required Iterable<RoomParticipantModel> participants}) =>
      RoomEntity(
        id: id,
        name: name,
        participants: participants.map((e) => e.entity).toSet(),
      );
}
