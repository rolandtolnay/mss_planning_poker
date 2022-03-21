import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../../domain/rooms/models/poker_card.dart';
import '../../domain/rooms/participant_repository.dart';
import '../auth/user_notifier.dart';
import 'room_state_notifier.dart';

@Injectable()
class SelectedCardNotifier extends StateNotifier<PokerCard?> {
  final ParticipantRepository _repository;

  StreamSubscription? _listener;

  SelectedCardNotifier(this._repository) : super(null);

  void listenOnChanges(Reader read) {
    _listener?.cancel();

    final roomProvider = read(roomStateProvider);
    final room = roomProvider.mapOrNull(completed: ((s) => s.room));
    final userId = read(userProvider)?.id;
    if (room == null || userId == null) return;

    _listener = _repository
        .onParticipantChanged(userId, roomId: room.id)
        .listen((participant) {
      if (participant == null) return;
      state = participant.selectedCard;
    });
  }

  Future selectCard(PokerCard? card, Reader read) async {
    final roomProvider = read(roomStateProvider);
    final room = roomProvider.mapOrNull(completed: ((s) => s.room));
    final userId = read(userProvider)?.id;
    if (room == null || userId == null) return;

    await _repository.selectCard(card, roomId: room.id, userId: userId);
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }
}
