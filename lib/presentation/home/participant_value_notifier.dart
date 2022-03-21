import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';
import 'package:mss_planning_poker/domain/rooms/participant_repository.dart';

import '../auth/auth_provider.dart';
import 'room_provider.dart';

@Injectable()
class ParticipantValueNotifier extends StateNotifier<String?> {
  final ParticipantRepository _repository;
  final Ref _ref;

  StreamSubscription? _listener;

  ParticipantValueNotifier(this._repository, @factoryParam Ref? ref)
      : _ref = ref!,
        super(null);

  void listenOnChanges() {
    _listener?.cancel();

    final room = _ref.read(roomProvider).mapOrNull(completed: ((s) => s.room));
    final userId = _ref.read(authProvider)?.id;
    if (room == null || userId == null) return;

    _listener = _repository
        .onParticipantChanged(userId, roomId: room.id)
        .listen((participant) {
      if (participant == null) return;
      state = participant.selectedValue;
    });
  }

  Future setValue(String? value) async {
    final room = _ref.read(roomProvider).mapOrNull(completed: ((s) => s.room));
    final userId = _ref.read(authProvider)?.id;
    if (room == null || userId == null) return;

    await _repository.setValue(value, roomId: room.id, participantId: userId);
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }
}
