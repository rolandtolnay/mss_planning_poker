import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/loading_scaffold.dart';
import '../room_selector/room_selector_dialog.dart';
import 'room_state_notifier.dart';
import 'widgets/poker_card_grid.dart';
import 'widgets/room_participants_list.dart';

class HomePage extends ConsumerStatefulWidget {
  final String userId;

  const HomePage({required this.userId, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(roomStateProvider.notifier).fetchRoomForUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RoomState>(roomStateProvider, (_, state) {
      _showRoomSelectorIfNoRoomFound(state);
    });

    final state = ref.watch(roomStateProvider);
    return state.maybeWhen(
      orElse: () => LoadingScaffold(),
      completed: (room) {
        if (room == null) return Scaffold();

        return Scaffold(
          appBar: AppBar(
            title: Text(room.name),
            leading: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () => _onLeaveRoomPressed(room.id, ref),
            ),
          ),
          body: Column(
            children: [
              Expanded(child: RoomParticipantsList(roomId: room.id)),
              PokerCardGrid()
            ],
          ),
        );
      },
    );
  }

  void _showRoomSelectorIfNoRoomFound(RoomState state) {
    state.whenOrNull(completed: (room) {
      if (room == null) {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          final room = await RoomSelectorDialog.show(context);
          if (room != null) ref.read(roomStateProvider.notifier).joinRoom(room);
        });
      }
    });
  }

  Future<void> _onLeaveRoomPressed(String roomId, WidgetRef ref) async {
    final provider = ref.read(roomStateProvider.notifier);
    provider.leaveRoomWithId(roomId, userId: widget.userId);
  }
}
