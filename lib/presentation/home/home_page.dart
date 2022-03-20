import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mss_planning_poker/presentation/common/loading_scaffold.dart';

import '../../domain/rooms/participant_repository.dart';
import 'room_participants_list.dart';
import 'room_provider.dart';
import '../room_selector/room_selector_dialog.dart';

const List<String> _cards = ['?', '1', '2', '3', '5', '8', '13'];

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
    ref.read(roomProvider.notifier).fetchRoomForUserId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RoomProviderState>(roomProvider, (_, state) {
      _showRoomSelectorIfNoRoomFound(state);
    });

    final state = ref.watch(roomProvider);
    return state.maybeWhen(
        orElse: LoadingScaffold.new,
        completed: (room) {
          if (room == null) return Scaffold(body: Container());

          final cardRow = Row(
            children: _cards
                .map((e) => Consumer(builder: (context, ref, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: PokerCardWidget(
                          value: e,
                          onTapped: (value) {
                            pcpRepository.setValue(
                              value,
                              roomId: room.id,
                              participantId: widget.userId,
                            );
                          },
                        ),
                      );
                    }))
                .toList(),
          );

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
                SizedBox(
                  height: 100,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: cardRow,
                  ),
                )
              ],
            ),
          );
        });
  }

  void _showRoomSelectorIfNoRoomFound(RoomProviderState state) {
    state.whenOrNull(completed: (room) {
      if (room == null) {
        WidgetsBinding.instance?.addPostFrameCallback((_) async {
          final room = await RoomSelectorDialog.show(context);
          if (room != null) ref.read(roomProvider.notifier).joinRoom(room);
        });
      }
    });
  }

  Future<void> _onLeaveRoomPressed(String roomId, WidgetRef ref) async {
    ref.read(roomProvider.notifier).leaveRoomWithId(
          roomId,
          userId: widget.userId,
        );
  }
}

class PokerCardWidget extends StatelessWidget {
  final String value;
  final ValueChanged<String> onTapped;
  final bool highlighted;

  const PokerCardWidget({
    required this.value,
    required this.onTapped,
    this.highlighted = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 80,
      width: 56,
      child: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith(
            (_) => highlighted ? colorScheme.error : colorScheme.secondary,
          ),
        ),
        child: Text(
          value,
          style: textTheme.subtitle1?.copyWith(color: colorScheme.onSecondary),
        ),
        onPressed: () => onTapped(value),
      ),
    );
  }
}
