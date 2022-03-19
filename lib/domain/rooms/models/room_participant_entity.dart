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
}
