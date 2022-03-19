class UserEntity {
  final String id;
  final String? displayName;

  UserEntity({required this.id, this.displayName});

  UserEntity copyWith({required String displayName}) =>
      UserEntity(id: id, displayName: displayName);
}
