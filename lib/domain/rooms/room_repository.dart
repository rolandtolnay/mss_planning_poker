import 'package:either_dart/either.dart';
import 'package:injectable/injectable.dart';

import '../auth/user_entity.dart';
import '../domain_error.dart';
import 'models/room_entity.dart';

abstract class RoomRepository {
  Future<Either<DomainError, RoomEntity>> createRoom({
    required UserEntity admin,
  });

  Future<Either<DomainError, RoomEntity>> joinRoom(
    RoomEntity room, {
    required UserEntity participant,
  });
}

@Injectable(as: RoomRepository)
class FirRoomRepository implements RoomRepository {
  @override
  Future<Either<DomainError, RoomEntity>> createRoom(
      {required UserEntity admin}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<DomainError, RoomEntity>> joinRoom(RoomEntity room,
      {required UserEntity participant}) {
    throw UnimplementedError();
  }
}
