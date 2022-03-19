import 'package:flutter/material.dart';

import '../domain/auth/auth_repository.dart';
import '../domain/auth/user_entity.dart';
import '../domain/rooms/models/room_entity.dart';
import '../injectable/injectable.dart';
import 'room_selector_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _authRepository = getIt<AuthRepository>();

  RoomEntity? _currentRoom;

  @override
  void initState() {
    super.initState();

    _authRepository.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentRoom?.name ?? 'mssPlanningPoker')),
      body: Center(
        child: StreamBuilder<UserEntity?>(
          stream: _authRepository.onAuthStateChanged,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error occured');
            if (!snapshot.hasData) return CircularProgressIndicator();

            final user = snapshot.data!;

            if (_currentRoom == null) {
              WidgetsBinding.instance?.addPostFrameCallback((_) async {
                final room = await showDialog<RoomEntity>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => RoomSelectorDialog(),
                );
                setState(() {
                  _currentRoom = room;
                });
              });
            }

            return Column(
              children: [
                const Spacer(),
                Text('User id: ${user.id}'),
                const SizedBox(height: 16),
                if (user.displayName == null)
                  Text('User has no name.')
                else
                  Text('User display name: ${user.displayName}.'),
                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
