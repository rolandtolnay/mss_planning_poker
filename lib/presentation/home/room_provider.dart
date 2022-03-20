import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../domain/domain_error.dart';
import '../../domain/rooms/models/room_entity.dart';
import '../../domain/rooms/participant_repository.dart';
import '../../domain/rooms/room_repository.dart';
import '../../injectable/injectable.dart';

part 'room_provider.freezed.dart';

final roomProvider = StateNotifierProvider<RoomProvider, RoomProviderState>(
  (ref) => getIt<RoomProvider>(),
);

@Injectable()
class RoomProvider extends StateNotifier<RoomProviderState> {
  final RoomRepository _roomRepository;
  final ParticipantRepository _pcpRepository;

  RoomProvider(this._roomRepository, this._pcpRepository)
      : super(RoomProviderState.completed(null));

  Future fetchRoomForUserId(String userId) async {
    state = RoomProviderState.loading();
    final result = await _roomRepository.findRoomForUserId(userId);
    state = result.fold(
      (left) => RoomProviderState.error(left.errorMessage ?? ''),
      (right) => RoomProviderState.completed(right),
    );
  }

  Future leaveRoomWithId(String roomId, {required String userId}) async {
    state = RoomProviderState.loading();
    final error = await _pcpRepository.leaveRoomWithId(
      roomId,
      participantId: userId,
    );
    state = RoomProviderState.fromError(error);
  }

  void joinRoom(RoomEntity entity) {
    state = RoomProviderState.completed(entity);
  }
}

@freezed
class RoomProviderState with _$RoomProviderState {
  const RoomProviderState._();
  const factory RoomProviderState.loading() = _Loading;
  const factory RoomProviderState.error(String errorText) = _Error;
  const factory RoomProviderState.completed(RoomEntity? room) = _Completed;

  factory RoomProviderState.fromError(DomainError? error) {
    if (error == null) return RoomProviderState.completed(null);
    return RoomProviderState.error(error.errorMessage ?? '');
  }
}
