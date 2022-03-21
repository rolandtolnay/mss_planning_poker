import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/rooms/models/room_entity.dart';
import '../auth/auth_provider.dart';
import '../common/common_dialog.dart';
import '../common/loadable_widget.dart';
import '../common/rectangular_button.dart';
import 'room_selector_provider.dart';

class RoomSelectorDialog extends ConsumerStatefulWidget {
  static Future<RoomEntity?> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RoomSelectorDialog(),
    );
  }

  RoomSelectorDialog({Key? key}) : super(key: key);

  final isLoading = StateProvider<bool>((ref) {
    final state = ref.watch(roomSelectorProvider);
    final loading = state.whenOrNull(loading: () => true);
    return loading ?? false;
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RoomSelectorDialogState();
}

class _RoomSelectorDialogState extends ConsumerState<RoomSelectorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _roomController;

  @override
  void initState() {
    super.initState();

    final displayName = ref.read(authProvider)?.displayName;
    _nameController = TextEditingController(text: displayName);
    _roomController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomSelectorProvider);

    final nameInput = TextField(
      controller: _nameController,
      decoration: InputDecoration(hintText: 'Display name'),
      onChanged: (_) => setState(() {}),
    );
    final newRoomButton = RectangularButton(
      title: 'Create new room',
      enabled: _createEnabled,
      onPressed: _onCreateRoomTapped,
    );
    final joinErrorText = state.mapOrNull(error: (s) => s.errorMessage);
    final joinRoomInput = SizedBox(
      width: 120,
      child: TextField(
        controller: _roomController,
        decoration: InputDecoration(
          hintText: 'Room number',
          errorText: joinErrorText,
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
    final joinRoomButton = RectangularButton(
      title: 'Join existing',
      enabled: _joinEnabled,
      onPressed: _onJoinRoomTapped,
    );

    return CommonDialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16.0),
            nameInput,
            const SizedBox(height: 16.0),
            LoadableWidget(
              loading: ref.watch(widget.isLoading),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      joinRoomInput,
                      const SizedBox(width: 16),
                      joinRoomButton,
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  const Text('or'),
                  const SizedBox(height: 8.0),
                  newRoomButton,
                ],
              ),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  bool get _createEnabled => _nameController.text.length >= 3;

  void _onCreateRoomTapped() async {
    await _updateDisplayName();

    final user = ref.read(authProvider);
    if (user == null) return;
    await ref.read(roomSelectorProvider.notifier).createRoom(user: user);

    final state = ref.read(roomSelectorProvider);
    state.whenOrNull(completed: (room) => Navigator.of(context).pop(room));
  }

  bool get _joinEnabled =>
      _nameController.text.length >= 3 && _roomController.text.length == 4;

  void _onJoinRoomTapped() async {
    await _updateDisplayName();

    final user = ref.read(authProvider);
    if (user == null) return;
    final roomName = _roomController.text;
    final notifier = ref.read(roomSelectorProvider.notifier);
    await notifier.joinRoomNamed(roomName, user: user);

    final state = ref.read(roomSelectorProvider);
    state.whenOrNull(completed: (room) => Navigator.of(context).pop(room));
  }

  Future<void> _updateDisplayName() async {
    final name = _nameController.text;
    ref.read(widget.isLoading.notifier).state = true;
    await ref.read(authProvider.notifier).updateDisplayName(name);
  }
}
