import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mss_planning_poker/domain/auth/user_entity.dart';
import 'package:mss_planning_poker/presentation/common/max_width_container.dart';
import 'package:mss_planning_poker/presentation/extensions/build_context_ext_screen_size.dart';

import '../../domain/rooms/models/room_entity.dart';
import '../common/loading_scaffold.dart';
import '../room_selector/room_selector_dialog.dart';
import 'room_state_notifier.dart';
import 'widgets/poker_card_grid.dart';
import 'widgets/room_participants_list.dart';

class HomePage extends ConsumerStatefulWidget {
  final UserEntity user;

  const HomePage({required this.user, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    ref.read(roomStateProvider.notifier).fetchRoomForUserId(widget.user.id);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RoomState>(roomStateProvider, (_, state) {
      _showRoomSelectorIfNoRoomFound(state);
    });

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final state = ref.watch(roomStateProvider);
    return state.maybeWhen(
      orElse: () => LoadingScaffold(),
      completed: (room) {
        if (room == null) return Scaffold();

        final creator = Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4, right: 8),
            child: Text(
              'by roland tolnay',
              style: textTheme.overline?.copyWith(color: theme.disabledColor),
            ),
          ),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text('Room ${room.name} (${widget.user.displayName})'),
            leading: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => _onLeaveRoomPressed(room.id, ref),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(128),
                        child: Center(
                          child: Opacity(
                            opacity: 0.05,
                            child: SvgPicture.asset(
                              'assets/images/white_logo_no_background.svg',
                            ),
                          ),
                        ),
                      ),
                      RoomParticipantsList(roomId: room.id),
                    ],
                  ),
                ),
                MaxWidthContainer(
                  maxWidth: kPhoneWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildResetButton(context),
                      _buildShowEstimatesButton(room)
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                PokerCardGrid(),
                const SizedBox(height: 24.0),
                creator
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: () => ref.read(roomStateProvider.notifier).resetCards(),
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.resolveWith(
          (_) => Size.fromHeight(44),
        ),
        foregroundColor: MaterialStateProperty.resolveWith(
          // ignore: deprecated_member_use
          (_) => colorScheme.secondaryVariant,
        ),
      ),
      label: Text('RESET'),
      icon: Icon(Icons.restart_alt),
    );
  }

  Widget _buildShowEstimatesButton(RoomEntity room) {
    return Consumer(
      builder: (context, ref, __) {
        final colorScheme = Theme.of(context).colorScheme;

        final showing = ref.watch(roomUpdateNotifier(room.id)
            .select((room) => room.value?.showingCards));
        if (showing == null) return CircularProgressIndicator();

        final text = showing ? 'HIDE ESTIMATES' : 'SHOW ESTIMATES';
        return OutlinedButton.icon(
          onPressed: () {
            ref.read(roomStateProvider.notifier).showCards(!showing);
          },
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.resolveWith(
              (_) => Size.fromHeight(44),
            ),
            foregroundColor: MaterialStateProperty.resolveWith(
              // ignore: deprecated_member_use
              (_) => colorScheme.secondaryVariant,
            ),
          ),
          label: Text(text),
          icon: Icon(showing ? Icons.visibility_off : Icons.visibility),
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
    provider.leaveRoomWithId(roomId, userId: widget.user.id);
  }
}
