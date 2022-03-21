import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/rooms/models/room_entity.dart';
import '../../../domain/rooms/room_repository.dart';
import '../../../injectable/injectable.dart';

final _roomUpdateNotifier =
    StreamProvider.autoDispose.family<RoomEntity?, String>(
  (_, roomId) => getIt<RoomRepository>().onRoomUpdated(id: roomId),
);

class RoomParticipantsList extends ConsumerWidget {
  final String roomId;

  const RoomParticipantsList({required this.roomId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onRoomUpdated = ref.watch(_roomUpdateNotifier(roomId));
    return onRoomUpdated.maybeWhen(
      orElse: _buildSpinner,
      data: (room) {
        if (room == null) return _buildSpinner();
        return _buildListView(room, context);
      },
    );
  }

  Center _buildSpinner() => const Center(child: CircularProgressIndicator());

  ListView _buildListView(RoomEntity room, BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: room.participants.length,
      itemBuilder: (_, index) {
        final user = room.participants[index];

        final valueText =
            room.showingCards ? user.selectedCard ?? '-' : 'hidden';
        return ListTile(
          title: Text(user.displayName),
          trailing: Text(valueText, style: textTheme.headline6),
        );
      },
    );
  }
}
