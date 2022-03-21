import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mss_planning_poker/presentation/common/max_width_container.dart';
import 'package:mss_planning_poker/presentation/extensions/build_context_ext_screen_size.dart';

import '../../../domain/rooms/models/room_entity.dart';
import '../../../domain/rooms/room_repository.dart';
import '../../../injectable/injectable.dart';

final roomUpdateNotifier =
    StreamProvider.autoDispose.family<RoomEntity?, String>(
  (_, roomId) => getIt<RoomRepository>().onRoomUpdated(id: roomId),
);

class RoomParticipantsList extends ConsumerWidget {
  final String roomId;

  const RoomParticipantsList({required this.roomId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onRoomUpdated = ref.watch(roomUpdateNotifier(roomId));
    return onRoomUpdated.maybeWhen(
      orElse: _buildSpinner,
      data: (room) {
        if (room == null) return _buildSpinner();
        return _buildListView(room, context);
      },
    );
  }

  Center _buildSpinner() => const Center(child: CircularProgressIndicator());

  Widget _buildListView(RoomEntity room, BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return MaxWidthContainer(
      maxWidth: kPhoneWidth,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16.0),
        itemCount: room.participants.length,
        itemBuilder: (_, index) {
          final user = room.participants[index];

          final valueWidget = room.showingCards
              ? Text(user.selectedCard ?? '-', style: textTheme.headline5)
              : SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                      user.selectedCard == null
                          ? Icons.question_mark
                          : Icons.done,
                      size: user.selectedCard == null ? 24 : 32),
                );
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
            title: Text(user.displayName, style: textTheme.headline6),
            trailing: valueWidget,
          );
        },
      ),
    );
  }
}
