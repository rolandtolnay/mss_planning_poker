import 'package:json_annotation/json_annotation.dart';

part 'room_participant_model.g.dart';

@JsonSerializable()
class RoomParticipantModel {
  final String id;
  final String displayName;

  final String? selectedValue;
  final bool showingValue;

  RoomParticipantModel(
    this.id,
    this.displayName,
    this.selectedValue,
    this.showingValue,
  );

  factory RoomParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$RoomParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomParticipantModelToJson(this);
}
