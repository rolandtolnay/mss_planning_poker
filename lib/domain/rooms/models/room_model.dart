import 'package:json_annotation/json_annotation.dart';

part 'room_model.g.dart';

@JsonSerializable()
class RoomModel {
  final String id;
  final String name;
  final DateTime lastUpdated;

  RoomModel(this.id, this.name, this.lastUpdated);

  factory RoomModel.fromJson(Map<String, dynamic> json) =>
      _$RoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoomModelToJson(this);
}
