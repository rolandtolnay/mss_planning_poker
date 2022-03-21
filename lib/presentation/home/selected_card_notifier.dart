import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../domain/rooms/models/poker_card.dart';
import '../../domain/rooms/participant_repository.dart';
import '../auth/user_state_notifier.dart';
import 'room_state_notifier.dart';

@Injectable()
class SelectedCardNotifier extends StateNotifier<PokerCard?> {
  final ParticipantRepository _repository;
  final Ref _ref;

  StreamSubscription? _listener;

  SelectedCardNotifier(this._repository, @factoryParam Ref? ref)
      : _ref = ref!,
        super(null);

  void listenOnChanges() {
    _listener?.cancel();

    final roomProvider = _ref.read(roomStateProvider);
    final room = roomProvider.mapOrNull(completed: ((s) => s.room));
    final userId = _ref.read(userProvider)?.id;
    if (room == null || userId == null) return;

    _listener = _repository
        .onParticipantChanged(userId, roomId: room.id)
        .listen((participant) {
      if (participant == null) return;
      state = participant.selectedCard;
    });
  }

  Future selectCard(PokerCard? card) async {
    final roomProvider = _ref.read(roomStateProvider);
    final room = roomProvider.mapOrNull(completed: ((s) => s.room));
    final userId = _ref.read(userProvider)?.id;
    if (room == null || userId == null) return;

    await _repository.selectCard(card, roomId: room.id, userId: userId);
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }
}
