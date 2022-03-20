import 'package:flutter/material.dart';

import '../../domain/auth/auth_repository.dart';
import '../../domain/rooms/room_repository.dart';
import '../../injectable/injectable.dart';
import '../common/loadable_widget.dart';
import '../common/max_width_container.dart';
import '../common/rectangular_button.dart';
import '../extensions/build_context_ext_screen_size.dart';

class RoomSelectorDialog extends StatefulWidget {
  const RoomSelectorDialog({Key? key}) : super(key: key);

  @override
  State<RoomSelectorDialog> createState() => _RoomSelectorDialogState();
}

class _RoomSelectorDialogState extends State<RoomSelectorDialog> {
  final _roomRepository = getIt<RoomRepository>();
  final _authRepository = getIt<AuthRepository>();

  late final TextEditingController _nameController;
  late final TextEditingController _roomController;

  bool _loading = false;
  String? _nameErrorText;
  String? _roomErrorText;

  @override
  void initState() {
    super.initState();

    final user = _authRepository.currentUser;
    _nameController = TextEditingController(text: user?.displayName);
    _roomController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final nameInput = TextField(
      controller: _nameController,
      decoration: InputDecoration(
        hintText: 'Display name',
        errorText: _nameErrorText,
      ),
      onChanged: (_) => setState(() {}),
    );
    final newRoomButton = RectangularButton(
      title: 'Create new room',
      enabled: _nameController.text.length >= 3,
      onPressed: _onCreateRoomTapped,
    );
    final joinRoomButton = RectangularButton(
      title: 'Join existing',
      enabled:
          _nameController.text.length >= 3 && _roomController.text.length == 4,
      onPressed: _onJoinRoomTapped,
    );

    return MaxWidthContainer(
      maxWidth: kPhoneWidth,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 4,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 24,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16.0),
              nameInput,
              const SizedBox(height: 16.0),
              LoadableWidget(
                loading: _loading,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: _roomController,
                            decoration: InputDecoration(
                              hintText: 'Room number',
                              errorText: _roomErrorText,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
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
      ),
    );
  }

  void _onCreateRoomTapped() async {
    setState(() {
      _loading = true;
    });
    final name = _nameController.text;
    await _authRepository.updateDisplayName(name);

    final result = await _roomRepository.createRoom(
      admin: _authRepository.currentUser!,
    );
    if (result.isLeft) {
      setState(() {
        _loading = false;
        _nameErrorText = result.left.errorMessage;
      });
    } else {
      Navigator.of(context).pop(result.right);
    }
  }

  void _onJoinRoomTapped() async {
    setState(() {
      _loading = true;
    });
    final name = _nameController.text;
    await _authRepository.updateDisplayName(name);

    final result = await _roomRepository.joinRoom(
      roomName: _roomController.text,
      participant: _authRepository.currentUser!,
    );
    if (result.isLeft) {
      setState(() {
        _loading = false;
        _roomErrorText = result.left.errorMessage;
      });
    } else {
      Navigator.of(context).pop(result.right);
    }
  }
}