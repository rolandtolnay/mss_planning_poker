import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/domain_error.dart';
import '../../domain/rooms/models/room_entity.dart';
import '../../domain/rooms/participant_repository.dart';
import '../../domain/rooms/room_repository.dart';
import '../../injectable/injectable.dart';

part 'room_state_notifier.freezed.dart';

final roomStateProvider = StateNotifierProvider<RoomStateNotifier, RoomState>(
  (ref) => getIt<RoomStateNotifier>(),
);

@Injectable()
class RoomStateNotifier extends StateNotifier<RoomState> {
  final RoomRepository _roomRepository;
  final ParticipantRepository _pcpRepository;

  RoomStateNotifier(this._roomRepository, this._pcpRepository)
      : super(RoomState.completed(null));

  Future fetchRoomForUserId(String userId) async {
    state = RoomState.loading();
    final result = await _roomRepository.findRoomForUserId(userId);
    state = result.fold(
      (left) => RoomState.error(left.errorMessage ?? ''),
      (right) => RoomState.completed(right),
    );
  }

  Future leaveRoomWithId(String roomId, {required String userId}) async {
    state = RoomState.loading();
    final error = await _pcpRepository.leaveRoomWithId(
      roomId,
      userId: userId,
    );
    state = RoomState.fromError(error);
  }

  void joinRoom(RoomEntity entity) {
    state = RoomState.completed(entity);
  }

  void showCards(bool showingCards) async {
    final room = state.mapOrNull(completed: (state) => state.room);
    if (room == null) return;
    await _roomRepository.showCards(showingCards, roomId: room.id);
  }

  void resetCards() async {
    final room = state.mapOrNull(completed: (state) => state.room);
    if (room == null) return;
    await _pcpRepository.resetCards(roomId: room.id);
    await _roomRepository.showCards(false, roomId: room.id);
  }
}

@freezed
class RoomState with _$RoomState {
  const RoomState._();
  const factory RoomState.loading() = _Loading;
  const factory RoomState.error(String errorText) = _Error;
  const factory RoomState.completed(RoomEntity? room) = _Completed;

  factory RoomState.fromError(DomainError? error) {
    if (error == null) return RoomState.completed(null);
    return RoomState.error(error.errorMessage ?? '');
  }
}
