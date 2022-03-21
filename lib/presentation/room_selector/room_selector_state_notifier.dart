import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/auth/user_entity.dart';
import '../../domain/domain_error.dart';
import '../../domain/rooms/models/room_entity.dart';
import '../../domain/rooms/room_repository.dart';

part 'room_selector_state_notifier.freezed.dart';

@Injectable()
class RoomSelectorStateNotifier extends StateNotifier<RoomSelectorState> {
  final RoomRepository _repository;

  RoomSelectorStateNotifier(this._repository)
      : super(RoomSelectorState.completed(null));

  Future createRoom({required UserEntity user}) async {
    state = RoomSelectorState.loading();
    final result = await _repository.createRoom(admin: user);
    state = RoomSelectorState.fromResult(result);
  }

  Future joinRoomNamed(String name, {required UserEntity user}) async {
    state = RoomSelectorState.loading();
    final result = await _repository.joinRoomNamed(name, participant: user);
    state = RoomSelectorState.fromResult(result);
  }
}

@freezed
class RoomSelectorState with _$RoomSelectorState {
  const RoomSelectorState._();
  const factory RoomSelectorState.loading() = _Loading;
  const factory RoomSelectorState.error(String errorMessage) = _Error;
  const factory RoomSelectorState.completed(RoomEntity? room) = _Completed;

  factory RoomSelectorState.fromResult(
    Either<DomainError, RoomEntity> result,
  ) {
    return result.fold(
      (left) => RoomSelectorState.error(left.errorMessage ?? ''),
      (right) => RoomSelectorState.completed(right),
    );
  }
}
