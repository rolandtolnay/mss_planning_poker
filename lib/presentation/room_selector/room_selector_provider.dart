import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/auth/user_entity.dart';
import 'package:mss_planning_poker/domain/rooms/models/room_entity.dart';
import 'package:mss_planning_poker/domain/rooms/room_repository.dart';

import '../../domain/domain_error.dart';
import '../../injectable/injectable.dart';

part 'room_selector_provider.freezed.dart';

final roomSelectorProvider =
    StateNotifierProvider<RoomSelectorProvider, RoomSelectorProviderState>(
  (ref) => getIt<RoomSelectorProvider>(),
);

@Injectable()
class RoomSelectorProvider extends StateNotifier<RoomSelectorProviderState> {
  final RoomRepository _repository;

  RoomSelectorProvider(this._repository)
      : super(RoomSelectorProviderState.completed(null));

  Future createRoom({required UserEntity user}) async {
    state = RoomSelectorProviderState.loading();
    final result = await _repository.createRoom(admin: user);
    state = RoomSelectorProviderState.fromResult(result);
  }

  Future joinRoomNamed(String name, {required UserEntity user}) async {
    state = RoomSelectorProviderState.loading();
    final result = await _repository.joinRoomNamed(name, participant: user);
    state = RoomSelectorProviderState.fromResult(result);
  }
}

@freezed
class RoomSelectorProviderState with _$RoomSelectorProviderState {
  const RoomSelectorProviderState._();
  const factory RoomSelectorProviderState.loading() = _Loading;
  const factory RoomSelectorProviderState.error(String errorMessage) = _Error;
  const factory RoomSelectorProviderState.completed(RoomEntity? room) =
      _Completed;

  factory RoomSelectorProviderState.fromResult(
    Either<DomainError, RoomEntity> result,
  ) {
    return result.fold(
      (left) => RoomSelectorProviderState.error(left.errorMessage ?? ''),
      (right) => RoomSelectorProviderState.completed(right),
    );
  }
}
