import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/auth/user_entity.dart';
import '../common/max_width_container.dart';
import '../extensions/build_context_ext_screen_size.dart';

import '../../domain/rooms/models/room_entity.dart';
import '../common/accentuable_button.dart';
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

    final state = ref.watch(roomStateProvider);
    return state.maybeWhen(
      orElse: () => const LoadingScaffold(),
      completed: (roomId) {
        if (roomId == null) return const Scaffold();
        return _buildHomePage(roomId, context);
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

  Widget _buildHomePage(String roomId, BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final transparentLogo = Padding(
      padding: const EdgeInsets.all(128),
      child: Center(
        child: Opacity(
          opacity: 0.05,
          child: SvgPicture.asset(
            'assets/images/white_logo_no_background.svg',
          ),
        ),
      ),
    );
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
      appBar: _buildAppBar(roomId, context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  transparentLogo,
                  RoomParticipantsList(roomId: roomId),
                ],
              ),
            ),
            MaxWidthContainer(
              maxWidth: kPhoneWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResetButton(roomId),
                  _buildShowEstimatesButton(roomId)
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            PokerCardGrid(),
            const SizedBox(height: 16.0),
            creator
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(String roomId, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Consumer(builder: (_, ref, __) {
        final roomName = ref.watch(
            roomUpdateNotifier(roomId).select((room) => room.value?.name));
        return Text('Room ${roomName ?? ''} (${widget.user.displayName})');
      }),
      leadingWidth: 160,
      leading: TextButton.icon(
        onPressed: () => _onLeaveRoomPressed(roomId, ref),
        icon: Icon(Icons.logout),
        label: Text('LEAVE ROOM'),
        // ignore: deprecated_member_use
        style: TextButton.styleFrom(primary: colorScheme.secondaryVariant),
      ),
    );
  }

  Widget _buildResetButton(String roomId) {
    return Consumer(builder: (context, ref, __) {
      final showing = ref.watch(roomUpdateNotifier(roomId)
          .select((room) => room.value?.showingCards));
      if (showing == null) return CircularProgressIndicator();

      return AccentuableButton(
        label: 'RESET',
        icon: Icons.restart_alt,
        hasAccent: showing,
        onPressed: () => ref.read(roomStateProvider.notifier).resetCards(),
      );
    });
  }

  Widget _buildShowEstimatesButton(String roomId) {
    return Consumer(
      builder: (context, ref, __) {
        final room = ref
            .watch(roomUpdateNotifier(roomId))
            .mapOrNull(data: (data) => data.value);
        if (room == null) return Container();

        final showing = room.showingCards;
        final label = showing ? 'HIDE ESTIMATES' : 'SHOW ESTIMATES';
        final icon = showing ? Icons.visibility_off : Icons.visibility;
        final hasAccent =
            !showing && room.participants.every((p) => p.selectedCard != null);
        return AccentuableButton(
          label: label,
          icon: icon,
          hasAccent: hasAccent,
          onPressed: () {
            ref.read(roomStateProvider.notifier).showCards(!showing);
          },
        );
      },
    );
  }

  Future<void> _onLeaveRoomPressed(String roomId, WidgetRef ref) async {
    final provider = ref.read(roomStateProvider.notifier);
    provider.leaveRoomWithId(roomId, userId: widget.user.id);
  }
}
